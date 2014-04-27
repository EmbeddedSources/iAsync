#import "JFFAsyncOperationLoadBalancer.h"

#import "JFFContextLoaders.h"
#import "JFFPedingLoaderData.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"
#import "JFFAsyncOperationHandlerBlockHolder.h"
#import "JFFAsyncOperationProgressBlockHolder.h"
#import "JFFAsyncOperationLoadBalancerContexts.h"
#import "JFFDidFinishAsyncOperationBlockHolder.h"

#import "JFFAsyncOpFinishedByCancellationError.h"
#import "JFFAsyncOpFinishedByUnsubscriptionError.h"

static const NSUInteger maxOperationCount = 5;
static const NSUInteger totalMaxBackgroundCount = 2;

static NSUInteger totalActiveNumber = 0;

static JFFAsyncOperationLoadBalancerContexts *sharedBalancer()
{
    return [JFFAsyncOperationLoadBalancerContexts sharedBalancer];
}

static void setBalancerCurrentContextName( NSString *contextName)
{
    sharedBalancer().currentContextName = contextName;
}

static BOOL canPeformAsyncOperationForContext(JFFContextLoaders *contextLoaders);
static BOOL findAndTryToPerformNextNativeLoader(void);

void setBalancerActiveContextName(NSString *contextName)
{
    if ([sharedBalancer().activeContextName isEqualToString:contextName])
        return;
    
    //NSLog( @"!!!SET ACTIVE CONTEXT NAME: %@", context_name_ );
    sharedBalancer().activeContextName = contextName;
    setBalancerCurrentContextName(contextName);
    
    while (findAndTryToPerformNextNativeLoader());
}

NSString *balancerActiveContextName(void)
{
    return sharedBalancer().activeContextName;
}

NSString *balancerCurrentContextName(void)
{
    return sharedBalancer().currentContextName;
}

static void peformBlockWithinContext(JFFSimpleBlock block, JFFContextLoaders *contextLoaders)
{
    NSString *currentContextName = sharedBalancer().currentContextName;
    sharedBalancer().currentContextName = contextLoaders.name;
    
    block();
    
    sharedBalancer().currentContextName = currentContextName;
}

static JFFAsyncOperation wrappedAsyncOperationWithContext(JFFAsyncOperation nativeLoader,
                                                          JFFContextLoaders *contextLoaders);

static void performInBalancerPedingLoaderData(JFFPedingLoaderData *pendingLoaderData,
                                              JFFContextLoaders   *contextLoaders)
{
    JFFAsyncOperation balancedLoader = wrappedAsyncOperationWithContext(pendingLoaderData.nativeLoader, contextLoaders);
    
    balancedLoader(pendingLoaderData.progressCallback,
                   pendingLoaderData.stateCallback,
                   pendingLoaderData.doneCallback);
}

static BOOL performLoaderFromContextIfPossible(JFFContextLoaders *contextLoaders)
{
    BOOL havePendingLoaders = contextLoaders.hasReadyToStartPendingLoaders;
    if (havePendingLoaders
        && canPeformAsyncOperationForContext(contextLoaders)) {
        
        JFFPedingLoaderData *pendingLoaderData = [contextLoaders popNotSuspendedPendingLoaderData];
        performInBalancerPedingLoaderData(pendingLoaderData, contextLoaders);
        return YES;
    }
    return NO;
}

static BOOL findAndTryToPerformNextNativeLoader(void)
{
    JFFAsyncOperationLoadBalancerContexts *balancer = sharedBalancer();
    
    JFFContextLoaders *activeLoaders = [balancer activeContextLoaders];
    if (performLoaderFromContextIfPossible(activeLoaders))
        return YES;
    
    __block BOOL result = NO;
    
    [balancer.contextLoadersByName enumerateKeysAndObjectsUsingBlock:^void(id key,
                                                                           id contextLoaders,
                                                                           BOOL *stop) {
        if (performLoaderFromContextIfPossible(contextLoaders)) {
            *stop  = YES;
            result = YES;
        }
    }];
    
    return NO;
}

static void logBalancerState(JFFContextLoaders* originContextLoaders)
{
    return;
    NSLog(@"|||||LOAD BALANCER|||||");
    JFFAsyncOperationLoadBalancerContexts *balancer = sharedBalancer();
    JFFContextLoaders* activeLoaders = [balancer activeContextLoaders];
    NSLog(@"Active context name: %@", activeLoaders.name);
    NSLog(@"pending count: %lu", (unsigned long)activeLoaders.pendingLoadersNumber);
    NSLog(@"active  count: %lu", (unsigned long)activeLoaders.activeLoadersNumber);
    
    [balancer.contextLoadersByName enumerateKeysAndObjectsUsingBlock:^(id name,
                                                                       JFFContextLoaders *contextLoaders,
                                                                       BOOL *stop) {
        
        if (activeLoaders != contextLoaders) {
            NSLog(@"context name: %@", contextLoaders.name );
            NSLog(@"pending count: %lu", (unsigned long)contextLoaders.pendingLoadersNumber );
            NSLog(@"active  count: %lu", (unsigned long)contextLoaders.activeLoadersNumber );
        }
    }];
    NSLog(@"|||||END LOG|||||");
}

static void finishExecuteOfNativeLoader( JFFAsyncOperation nativeLoader
                                        , JFFContextLoaders* contextLoaders )
{
    if ([contextLoaders removeActiveNativeLoader:nativeLoader]) {
        --totalActiveNumber;
        logBalancerState(contextLoaders);
    }
}

static JFFDidFinishAsyncOperationCallback doneCallbackWrapper(JFFDidFinishAsyncOperationCallback nativeDoneCallback,
                                                              JFFAsyncOperation nativeLoader,
                                                              JFFContextLoaders* contextLoaders)
{
    nativeDoneCallback = [nativeDoneCallback copy];
    
    return ^void(id result, NSError *error) {
        
        finishExecuteOfNativeLoader(nativeLoader, contextLoaders);
        
        if (nativeDoneCallback) {
            
            peformBlockWithinContext(^{
                
                nativeDoneCallback(result, error);
            }, contextLoaders);
        }
        
        findAndTryToPerformNextNativeLoader();
    };
}

static JFFAsyncOperation wrappedAsyncOperationWithContext(JFFAsyncOperation nativeLoader,
                                                          JFFContextLoaders *contextLoaders)
{
    NSCParameterAssert(nativeLoader);
    nativeLoader = [nativeLoader copy];
    
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback nativeProgressCallback,
                                     JFFAsyncOperationChangeStateCallback nativeStateCallback,
                                     JFFDidFinishAsyncOperationCallback nativeDoneCallback) {
        
        //progress holder for unsubscribe
        JFFAsyncOperationProgressBlockHolder *progressBlockHolder = [JFFAsyncOperationProgressBlockHolder new];
        progressBlockHolder.progressBlock = nativeProgressCallback;
        JFFAsyncOperationProgressCallback wrappedProgressCallback = ^void(id progressInfo) {
            peformBlockWithinContext( ^ {
                [progressBlockHolder performProgressBlockWithArgument:progressInfo];
            }, contextLoaders);
        };
        
        __block BOOL done = NO;
        
        __block JFFAsyncOperationChangeStateCallback nativeStateCallbackHolder = nativeStateCallback;
        JFFAsyncOperationChangeStateCallback wrappedStateCallback = ^void(JFFAsyncOperationState state) {
            
            if (nativeStateCallbackHolder)
                nativeStateCallbackHolder(state);
        };
        
        //finish holder for unsubscribe
        JFFDidFinishAsyncOperationBlockHolder *finishBlockHolder = [JFFDidFinishAsyncOperationBlockHolder new];
        finishBlockHolder.didFinishBlock = nativeDoneCallback;
        JFFDidFinishAsyncOperationCallback wrappedDoneCallback = ^void(id result, NSError *error) {
            done = YES;
            finishBlockHolder.onceDidFinishBlock(result, error);
        };
        
        wrappedDoneCallback = doneCallbackWrapper(wrappedDoneCallback,
                                                  nativeLoader,
                                                  contextLoaders);
        
        // JTODO check native loader no within balancer !!!
        JFFAsyncOperationHandler nativeHandler = nativeLoader(wrappedProgressCallback,
                                                              wrappedStateCallback,
                                                              wrappedDoneCallback);
        
        if (done) {
            return JFFStubHandlerAsyncOperationBlock;
        }
        
        ++totalActiveNumber;
        
        JFFAsyncOperationHandler wrappedCancelBlock = [^void(JFFAsyncOperationHandlerTask task) {
            
            if (JFFAsyncOperationHandlerTaskUnSubscribe == task) {
                
                finishBlockHolder.onceDidFinishBlock(nil, [JFFAsyncOpFinishedByUnsubscriptionError new]);
                
                nativeStateCallbackHolder          = nil;
                progressBlockHolder.progressBlock  = nil;
            } else {
                
                nativeHandler(task);
            }
        } copy];
        
        [contextLoaders addActiveNativeLoader:nativeLoader
                                wrappedCancel:wrappedCancelBlock];
        logBalancerState(contextLoaders);
        
        return wrappedCancelBlock;
    };
}

static BOOL canPeformAsyncOperationForContext(JFFContextLoaders *contextLoaders)
{
    BOOL isActiveContext = [sharedBalancer().activeContextName isEqualToString:contextLoaders.name];
    BOOL result = isActiveContext && (contextLoaders.activeLoadersNumber < maxOperationCount);
    
    if (!isActiveContext) {
        
        JFFContextLoaders *activeContextLoaders = [sharedBalancer() contextLoadersForName:sharedBalancer().activeContextName];
        NSUInteger activeLoadersInInactiveContexts = totalActiveNumber - activeContextLoaders.activeLoadersNumber;
        
        result = (activeLoadersInInactiveContexts < totalMaxBackgroundCount);
    }
    
    return result;
}

JFFAsyncOperation balancedAsyncOperation(JFFAsyncOperation nativeLoader)
{
    NSString *contextName = [sharedBalancer() currentContextName];
    return balancedAsyncOperationInContext(nativeLoader, contextName);
}

JFFAsyncOperation balancedAsyncOperationInContext(JFFAsyncOperation nativeLoader, NSString *contextName)
{
    NSCParameterAssert(nativeLoader);
    nativeLoader = [nativeLoader copy];
    
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback hendlerCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        JFFContextLoaders *contextLoaders = [sharedBalancer() contextLoadersForName:contextName];
        
        if (canPeformAsyncOperationForContext(contextLoaders)) {
            
            JFFAsyncOperation contextLoader = wrappedAsyncOperationWithContext(nativeLoader,
                                                                               contextLoaders);
            return contextLoader(progressCallback, hendlerCallback, doneCallback);
        }
        
        hendlerCallback = [hendlerCallback copy];
        [contextLoaders addPendingNativeLoader:nativeLoader
                              progressCallback:progressCallback
                                 stateCallback:hendlerCallback
                                  doneCallback:doneCallback];
        
        logBalancerState(contextLoaders);
        
        JFFAsyncOperationHandler cancel = ^void(JFFAsyncOperationHandlerTask task) {
            
            JFFPedingLoaderData *pedingLoaderData = [contextLoaders pendingLoaderDataForNativeLoader:nativeLoader];
            
            if (!pedingLoaderData) {
                //cancel only wrapped cancel block
                [contextLoaders handleActiveNativeLoader:nativeLoader withTask:task];
                return;
            }
            
            switch (task) {
                case JFFAsyncOperationHandlerTaskUnSubscribe:
                {
                    [pedingLoaderData unsubscribe];
                    if (doneCallback)
                        doneCallback(nil, [JFFAsyncOpFinishedByUnsubscriptionError new]);
                    break;
                }
                case JFFAsyncOperationHandlerTaskCancel:
                {
                    [contextLoaders removePedingLoaderData:pedingLoaderData];
                    if (doneCallback)
                        doneCallback(nil, [JFFAsyncOpFinishedByCancellationError new]);
                    break;
                }
                case JFFAsyncOperationHandlerTaskResume:
                {
                    pedingLoaderData.suspended = NO;
                    findAndTryToPerformNextNativeLoader();
                    break;
                }
                case JFFAsyncOperationHandlerTaskSuspend:
                {
                    pedingLoaderData.suspended = YES;
                    break;
                }
                default:
                {
                    NSCAssert1(NO, @"balancer not implemeted for handler task: %lu", (unsigned long)task);
                    break;
                }
            }
        };
        
        return cancel;
    };
}
