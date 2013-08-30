#import "JFFAsyncOperationLoadBalancer.h"

#import "JFFContextLoaders.h"
#import "JFFPedingLoaderData.h"
#import "JFFAsyncOperationLoadBalancerContexts.h"
#import "JFFAsyncOperationProgressBlockHolder.h"
#import "JFFCancelAsyncOperationBlockHolder.h"
#import "JFFDidFinishAsyncOperationBlockHolder.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"

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

NSString * balancerActiveContextName(void)
{
    return sharedBalancer().activeContextName;
}

NSString * balancerCurrentContextName(void)
{
    return sharedBalancer().currentContextName;
}

static void peformBlockWithinContext(JFFSimpleBlock block, JFFContextLoaders *contextLoaders)
{
    NSString* currentContextName = sharedBalancer().currentContextName;
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
                   pendingLoaderData.cancelCallback,
                   pendingLoaderData.doneCallback);
}

static BOOL performLoaderFromContextIfPossible(JFFContextLoaders *contextLoaders)
{
    BOOL have_pending_loaders_ = (contextLoaders.pendingLoadersNumber > 0);
    if ( have_pending_loaders_
        && canPeformAsyncOperationForContext(contextLoaders))
    {
        JFFPedingLoaderData* pendingLoaderData_ = [ contextLoaders popPendingLoaderData ];
        performInBalancerPedingLoaderData( pendingLoaderData_, contextLoaders );
        return YES;
    }
    return NO;
}

static BOOL findAndTryToPerformNextNativeLoader( void )
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
    NSLog(@"pending count: %d", activeLoaders.pendingLoadersNumber);
    NSLog(@"active  count: %d", activeLoaders.activeLoadersNumber);
    
    [balancer.contextLoadersByName enumerateKeysAndObjectsUsingBlock:^(id name,
                                                                       JFFContextLoaders *contextLoaders,
                                                                       BOOL *stop) {
        
        if (activeLoaders != contextLoaders) {
            NSLog(@"context name: %@", contextLoaders.name );
            NSLog(@"pending count: %d", contextLoaders.pendingLoadersNumber );
            NSLog(@"active  count: %d", contextLoaders.activeLoadersNumber );
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

static JFFCancelAsyncOperationHandler cancelCallbackWrapper(JFFCancelAsyncOperationHandler nativeCancelCallback,
                                                            JFFAsyncOperation nativeLoader,
                                                            JFFContextLoaders *contextLoaders)
{
    nativeCancelCallback = [nativeCancelCallback copy];
    return ^void(BOOL canceled) {
        
        if (!canceled) {
            NSCAssert(NO, @"balanced loaders should not be unsubscribed from native loader not supported yet");
            return;
        }
        
        finishExecuteOfNativeLoader(nativeLoader, contextLoaders);
        
        if (nativeCancelCallback) {
            peformBlockWithinContext(^{
                nativeCancelCallback(canceled);
            }, contextLoaders);
        }
        
        findAndTryToPerformNextNativeLoader();
   };
}

static JFFDidFinishAsyncOperationHandler doneCallbackWrapper(JFFDidFinishAsyncOperationHandler nativeDoneCallback,
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
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler nativeProgressCallback,
                                    JFFCancelAsyncOperationHandler nativeCancelCallback,
                                    JFFDidFinishAsyncOperationHandler nativeDoneCallback) {
        
        //progress holder for unsubscribe
        JFFAsyncOperationProgressBlockHolder *progressBlockHolder = [JFFAsyncOperationProgressBlockHolder new];
        progressBlockHolder.progressBlock = nativeProgressCallback;
        JFFAsyncOperationProgressHandler wrappedProgressCallback = ^void(id progressInfo) {
            peformBlockWithinContext( ^ {
                [progressBlockHolder performProgressBlockWithArgument:progressInfo];
            }, contextLoaders);
        };
        
        __block BOOL done = NO;
        
        //cancel holder for unsubscribe
        JFFCancelAsyncOperationBlockHolder *cancelCallbackBlockHolder = [JFFCancelAsyncOperationBlockHolder new];
        cancelCallbackBlockHolder.cancelBlock = nativeCancelCallback;
        JFFCancelAsyncOperation wrappedCancelCallback = ^void(BOOL canceled) {
            done = YES;
            cancelCallbackBlockHolder.onceCancelBlock(canceled);
        };
        
        //finish holder for unsubscribe
        JFFDidFinishAsyncOperationBlockHolder *finishBlockHolder = [JFFDidFinishAsyncOperationBlockHolder new];
        finishBlockHolder.didFinishBlock = nativeDoneCallback;
        JFFDidFinishAsyncOperationHandler wrappedDoneCallback = ^void(id result, NSError *error) {
            done = YES;
            finishBlockHolder.onceDidFinishBlock(result, error);
        };
        
        wrappedCancelCallback = cancelCallbackWrapper(wrappedCancelCallback,
                                                      nativeLoader,
                                                      contextLoaders);
        
        wrappedDoneCallback = doneCallbackWrapper(wrappedDoneCallback,
                                                  nativeLoader,
                                                  contextLoaders);
        
        // JTODO check native loader no within balancer !!!
        JFFCancelAsyncOperation cancelBlock = nativeLoader(wrappedProgressCallback,
                                                           wrappedCancelCallback,
                                                           wrappedDoneCallback);
        
        if (done) {
            return JFFStubCancelAsyncOperationBlock;
        }
        
        ++totalActiveNumber;
        
        JFFCancelAsyncOperation wrappedCancelBlock = [^void(BOOL canceled) {
            if (canceled) {
                cancelBlock(YES);
            } else {
                cancelCallbackBlockHolder.onceCancelBlock(NO);
                
                progressBlockHolder.progressBlock = nil;
                finishBlockHolder.didFinishBlock  = nil;
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
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        JFFContextLoaders *contextLoaders = [sharedBalancer() contextLoadersForName:contextName];
        
        if (canPeformAsyncOperationForContext(contextLoaders)) {
            
            JFFAsyncOperation contextLoader = wrappedAsyncOperationWithContext(nativeLoader,
                                                                               contextLoaders);
            return contextLoader(progressCallback, cancelCallback, doneCallback);
        }
        
        cancelCallback = [cancelCallback copy];
        [contextLoaders addPendingNativeLoader:nativeLoader
                              progressCallback:progressCallback
                                cancelCallback:cancelCallback
                                  doneCallback:doneCallback];
        
        logBalancerState(contextLoaders);
        
        JFFCancelAsyncOperation cancel = ^void(BOOL canceled) {
            
            if (![contextLoaders containsPendingNativeLoader:nativeLoader]) {
                //cancel only wrapped cancel block
                [contextLoaders cancelActiveNativeLoader:nativeLoader cancel:canceled];
                return;
            }
            
            if (canceled) {
                [contextLoaders removePendingNativeLoader:nativeLoader];
                cancelCallback(YES);
            } else {
                cancelCallback(NO);
                
                [contextLoaders unsubscribePendingNativeLoader:nativeLoader];
            }
        };
        
        return cancel;
    };
}
