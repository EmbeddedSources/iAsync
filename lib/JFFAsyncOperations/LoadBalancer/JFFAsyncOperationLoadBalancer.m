#import "JFFAsyncOperationLoadBalancer.h"

#import "JFFContextLoaders.h"
#import "JFFPedingLoaderData.h"
#import "JFFAsyncOperationLoadBalancerContexts.h"
#import "JFFAsyncOperationProgressBlockHolder.h"
#import "JFFCancelAsyncOperationBlockHolder.h"
#import "JFFDidFinishAsyncOperationBlockHolder.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"

static const NSUInteger maxOperationCount = 5;
static const NSUInteger totalMaxOperationCount = 7;

static NSUInteger globalActiveNumber = 0;

//JTODO test this

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

static void peformBlockWithinContext( JFFSimpleBlock block_, JFFContextLoaders* context_loaders_ )
{
    NSString* current_context_name_ = sharedBalancer().currentContextName;
    sharedBalancer().currentContextName = context_loaders_.name;

    block_();

    sharedBalancer().currentContextName = current_context_name_;
}

static JFFAsyncOperation wrappedAsyncOperationWithContext( JFFAsyncOperation native_loader_
                                                          , JFFContextLoaders* context_loaders_ );

static void performInBalancerPedingLoaderData(JFFPedingLoaderData *pendingLoaderData,
                                              JFFContextLoaders   *contextLoaders)
{
    JFFAsyncOperation balancedLoader = wrappedAsyncOperationWithContext(pendingLoaderData.nativeLoader, contextLoaders);
    
    balancedLoader(pendingLoaderData.progressCallback,
                   pendingLoaderData.cancelCallback,
                   pendingLoaderData.doneCallback);
}

static BOOL performLoaderFromContextIfPossible( JFFContextLoaders* context_loaders_ )
{
    BOOL have_pending_loaders_ = ( context_loaders_.pendingLoadersNumber > 0 );
    if ( have_pending_loaders_
        && canPeformAsyncOperationForContext( context_loaders_ ) )
    {
        JFFPedingLoaderData* pendingLoaderData_ = [ context_loaders_ popPendingLoaderData ];
        performInBalancerPedingLoaderData( pendingLoaderData_, context_loaders_ );
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

static void logBalancerState()
{
    return;
    NSLog( @"|||||LOAD BALANCER|||||" );
    JFFAsyncOperationLoadBalancerContexts* balancer_ = sharedBalancer();
    JFFContextLoaders* activeLoaders = [ balancer_ activeContextLoaders ];
    NSLog(@"Active context name: %@", activeLoaders.name);
    NSLog(@"pending count: %d", activeLoaders.pendingLoadersNumber);
    NSLog(@"active  count: %d", activeLoaders.activeLoadersNumber);
    
    [balancer_.contextLoadersByName enumerateKeysAndObjectsUsingBlock:^(id name,
                                                                        JFFContextLoaders *contextLoaders,
                                                                        BOOL *stop) {
        if (![name isEqualToString: activeLoaders.name ]) {
            NSLog( @"context name: %@", contextLoaders.name );
            NSLog( @"pending count: %d", contextLoaders.pendingLoadersNumber );
            NSLog( @"active  count: %d", contextLoaders.activeLoadersNumber );
        }
    }];
    NSLog( @"|||||END LOG|||||" );
}

static void finishExecuteOfNativeLoader( JFFAsyncOperation nativeLoader
                                        , JFFContextLoaders* contextLoaders )
{
    if ([contextLoaders removeActiveNativeLoader:nativeLoader]) {
        --globalActiveNumber;
        logBalancerState();
    }
}

static JFFCancelAsyncOperationHandler cancelCallbackWrapper( JFFCancelAsyncOperationHandler nativeCancelCallback
                                                            , JFFAsyncOperation native_loader_
                                                            , JFFContextLoaders* context_loaders_ )
{
    nativeCancelCallback = [[nativeCancelCallback copy] autorelease];
    return [[^void(BOOL canceled_) {
        if ( !canceled_ ) {
            assert( NO );// @"balanced loaders should not be unsubscribed from native loader"
        }
        
        [[nativeCancelCallback copy] autorelease];
        
        finishExecuteOfNativeLoader( native_loader_, context_loaders_ );
        
        if (nativeCancelCallback) {
            peformBlockWithinContext( ^{
                nativeCancelCallback( canceled_ );
            }, context_loaders_ );
      }
        
      findAndTryToPerformNextNativeLoader();
   } copy] autorelease];
}

static JFFDidFinishAsyncOperationHandler doneCallbackWrapper( JFFDidFinishAsyncOperationHandler native_done_callback_
                                                             , JFFAsyncOperation native_loader_
                                                             , JFFContextLoaders* context_loaders_ )
{
    native_done_callback_ = [ [ native_done_callback_ copy ] autorelease ];
    return [ [ ^void(id result, NSError *error) {
        [ [ native_done_callback_ copy ] autorelease ];

        finishExecuteOfNativeLoader( native_loader_, context_loaders_ );

        if ( native_done_callback_ )
        {
            peformBlockWithinContext( ^ {
                native_done_callback_(result, error);
            }, context_loaders_ );
        }

        findAndTryToPerformNextNativeLoader();
    } copy ] autorelease ];
}

static JFFAsyncOperation wrappedAsyncOperationWithContext( JFFAsyncOperation nativeLoader
                                                          , JFFContextLoaders* contextLoaders )
{
    nativeLoader = [ [ nativeLoader copy ] autorelease ];
    return [[^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler nativeProgressCallback,
                                      JFFCancelAsyncOperationHandler nativeCancelCallback,
                                      JFFDidFinishAsyncOperationHandler nativeDoneCallback) {
        //progress holder for unsubscribe
        JFFAsyncOperationProgressBlockHolder *progressBlockHolder = [[JFFAsyncOperationProgressBlockHolder new] autorelease];
        progressBlockHolder.progressBlock = nativeProgressCallback;
        JFFAsyncOperationProgressHandler wrappedProgressCallback = ^void(id progressInfo) {
            peformBlockWithinContext( ^ {
                [progressBlockHolder performProgressBlockWithArgument:progressInfo];
            }, contextLoaders);
        };
        
        __block BOOL done = NO;
        
        //cancel holder for unsubscribe
        JFFCancelAsyncOperationBlockHolder *cancelCallbackBlockHolder = [[JFFCancelAsyncOperationBlockHolder new] autorelease];
        cancelCallbackBlockHolder.cancelBlock = nativeCancelCallback;
        JFFCancelAsyncOperation wrappedCancelCallback = ^void(BOOL canceled) {
            done = YES;
            cancelCallbackBlockHolder.onceCancelBlock(canceled);
        };
        
        //finish holder for unsubscribe
        JFFDidFinishAsyncOperationBlockHolder *finishBlockHolder = [[JFFDidFinishAsyncOperationBlockHolder new] autorelease];
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
        
        ++globalActiveNumber;
        
        JFFCancelAsyncOperation wrappedCancelBlock = [[^void(BOOL canceled) {
            if (canceled) {
                cancelBlock( YES );
            } else {
                cancelCallbackBlockHolder.onceCancelBlock(NO);
                
                progressBlockHolder.progressBlock = nil;
                finishBlockHolder.didFinishBlock  = nil;
            }
        } copy] autorelease];
        
        [contextLoaders addActiveNativeLoader: nativeLoader
                                wrappedCancel: wrappedCancelBlock ];
        logBalancerState();
        
        return wrappedCancelBlock;
    } copy] autorelease];
}

static BOOL canPeformAsyncOperationForContext(JFFContextLoaders *contextLoaders )
{
    // JTODO check condition yet
    BOOL isActiveContext = [sharedBalancer().activeContextName isEqualToString:contextLoaders.name];
    return ((isActiveContext && contextLoaders.activeLoadersNumber < maxOperationCount )
            || 0 == globalActiveNumber )
        && globalActiveNumber <= totalMaxOperationCount;
}

JFFAsyncOperation balancedAsyncOperation(JFFAsyncOperation nativeLoader)
{
    JFFContextLoaders *contextLoaders = [sharedBalancer() currentContextLoaders];
    
    nativeLoader = [[nativeLoader copy]autorelease];
    return [[^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                      JFFCancelAsyncOperationHandler cancelCallback,
                                      JFFDidFinishAsyncOperationHandler doneCallback) {
        if (canPeformAsyncOperationForContext(contextLoaders)) {
            JFFAsyncOperation contextLoader_ = wrappedAsyncOperationWithContext(nativeLoader,
                                                                                contextLoaders);
            return contextLoader_(progressCallback, cancelCallback, doneCallback);
        }
        
        cancelCallback = [[cancelCallback copy]autorelease];
        [contextLoaders addPendingNativeLoader:nativeLoader
                              progressCallback:progressCallback
                                cancelCallback:cancelCallback
                                  doneCallback:doneCallback];
        
        logBalancerState();
        
        JFFCancelAsyncOperation cancel = [[^void(BOOL canceled) {
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
        }copy]autorelease];
        
        return cancel;
    }copy]autorelease];
}
