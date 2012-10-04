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

static void performInBalancerPedingLoaderData( JFFPedingLoaderData* pending_loader_data_
                                              , JFFContextLoaders* context_loaders_ )
{
    JFFAsyncOperation balanced_loader_ = wrappedAsyncOperationWithContext( pending_loader_data_.nativeLoader, context_loaders_ );

    balanced_loader_( pending_loader_data_.progressCallback
                     , pending_loader_data_.cancelCallback
                     , pending_loader_data_.doneCallback );
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
    JFFAsyncOperationLoadBalancerContexts* balancer_ = sharedBalancer();

    JFFContextLoaders* active_loaders_ = [ balancer_ activeContextLoaders ];
    if ( performLoaderFromContextIfPossible( active_loaders_ ) )
        return YES;

    __block BOOL result_ = NO;

    [ balancer_.contextLoadersByName enumerateKeysAndObjectsUsingBlock: ^void( id key_
                                                                              , id contextLoaders_
                                                                              , BOOL* stop_ )
    {
        if ( performLoaderFromContextIfPossible( contextLoaders_ ) )
        {
            *stop_ = YES;
            result_ = YES;
        }
    } ];

    return NO;
}

static void logBalancerState()
{
    return;
    NSLog( @"|||||LOAD BALANCER|||||" );
    JFFAsyncOperationLoadBalancerContexts* balancer_ = sharedBalancer();
    JFFContextLoaders* active_loaders_ = [ balancer_ activeContextLoaders ];
    NSLog( @"Active context name: %@", active_loaders_.name );
    NSLog( @"pending count: %d", active_loaders_.pendingLoadersNumber );
    NSLog( @"active  count: %d", active_loaders_.activeLoadersNumber );

    [ balancer_.contextLoadersByName enumerateKeysAndObjectsUsingBlock: ^( id name_
                                                                          , JFFContextLoaders* contextLoaders_
                                                                          , BOOL* stop_ )
    {
        if ( ![ name_ isEqualToString: active_loaders_.name ] )
        {
            NSLog( @"context name: %@", contextLoaders_.name );
            NSLog( @"pending count: %d", contextLoaders_.pendingLoadersNumber );
            NSLog( @"active  count: %d", contextLoaders_.activeLoadersNumber );
        }
    } ];
    NSLog( @"|||||END LOG|||||" );
}

static void finishExecuteOfNativeLoader( JFFAsyncOperation native_loader_
                                        , JFFContextLoaders* context_loaders_ )
{
    if ( [ context_loaders_ removeActiveNativeLoader: native_loader_ ] )
    {
        --globalActiveNumber;
        logBalancerState();
    }
}

static JFFCancelAsyncOperationHandler cancelCallbackWrapper( JFFCancelAsyncOperationHandler nativeCancelCallback_
                                                            , JFFAsyncOperation native_loader_
                                                            , JFFContextLoaders* context_loaders_ )
{
    nativeCancelCallback_ = [ [ nativeCancelCallback_ copy ] autorelease ];
    return [ [ ^void( BOOL canceled_ )
    {
        if ( !canceled_ )
        {
            assert( NO );// @"balanced loaders should not be unsubscribed from native loader"
        }

        [ [ nativeCancelCallback_ copy ] autorelease ];

        finishExecuteOfNativeLoader( native_loader_, context_loaders_ );

        if ( nativeCancelCallback_ )
        {
            peformBlockWithinContext( ^
            {
                nativeCancelCallback_( canceled_ );
         }, context_loaders_ );
      }

      findAndTryToPerformNextNativeLoader();
   } copy ] autorelease ];
}

static JFFDidFinishAsyncOperationHandler doneCallbackWrapper( JFFDidFinishAsyncOperationHandler native_done_callback_
                                                             , JFFAsyncOperation native_loader_
                                                             , JFFContextLoaders* context_loaders_ )
{
    native_done_callback_ = [ [ native_done_callback_ copy ] autorelease ];
    return [ [ ^void( id result_, NSError* error_ )
    {
        [ [ native_done_callback_ copy ] autorelease ];

        finishExecuteOfNativeLoader( native_loader_, context_loaders_ );

        if ( native_done_callback_ )
        {
            peformBlockWithinContext( ^
            {
                native_done_callback_( result_, error_ );
            }, context_loaders_ );
        }

        findAndTryToPerformNextNativeLoader();
    } copy ] autorelease ];
}

static JFFAsyncOperation wrappedAsyncOperationWithContext( JFFAsyncOperation nativeLoader
                                                          , JFFContextLoaders* contextLoaders )
{
    nativeLoader = [ [ nativeLoader copy ] autorelease ];
    return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler nativeProgressCallback_
                                        , JFFCancelAsyncOperationHandler nativeCancelCallback_
                                        , JFFDidFinishAsyncOperationHandler nativeDoneCallback_ )
    {
        //progress holder for unsubscribe
        JFFAsyncOperationProgressBlockHolder* progressBlockHolder_ = [ [ JFFAsyncOperationProgressBlockHolder new ] autorelease ];
        progressBlockHolder_.progressBlock = nativeProgressCallback_;
        JFFAsyncOperationProgressHandler wrappedProgressCallback = ^void( id progress_info_ )
        {
            peformBlockWithinContext( ^
            {
                [ progressBlockHolder_ performProgressBlockWithArgument: progress_info_ ];
            }, contextLoaders );
        };

        __block BOOL done_ = NO;

        //cancel holder for unsubscribe
        JFFCancelAsyncOperationBlockHolder* cancel_callback_block_holder_ = [ [ JFFCancelAsyncOperationBlockHolder new ] autorelease ];
        cancel_callback_block_holder_.cancelBlock = nativeCancelCallback_;
        JFFCancelAsyncOperation wrappedCancelCallback = ^void( BOOL canceled_ )
        {
            done_ = YES;
            cancel_callback_block_holder_.onceCancelBlock( canceled_ );
        };

        //finish holder for unsubscribe
        JFFDidFinishAsyncOperationBlockHolder* finish_block_holder_ = [ [ JFFDidFinishAsyncOperationBlockHolder new ] autorelease ];
        finish_block_holder_.didFinishBlock = nativeDoneCallback_;
        JFFDidFinishAsyncOperationHandler wrappedDoneCallback = ^void( id result_, NSError* error_ )
        {
            done_ = YES;
            finish_block_holder_.onceDidFinishBlock( result_, error_ );
        };

        wrappedCancelCallback = cancelCallbackWrapper( wrappedCancelCallback
                                                         , nativeLoader
                                                         , contextLoaders );

        wrappedDoneCallback = doneCallbackWrapper(wrappedDoneCallback,
                                                  nativeLoader,
                                                  contextLoaders);

        // TODO check native loader no within balancer !!!
        JFFCancelAsyncOperation cancelBlock = nativeLoader(wrappedProgressCallback,
                                                            wrappedCancelCallback,
                                                            wrappedDoneCallback);
        
        if ( done_ ) {
            return JFFStubCancelAsyncOperationBlock;
        }
        
        ++globalActiveNumber;
        
        JFFCancelAsyncOperation wrapped_cancel_block_ = [ [ ^void( BOOL canceled_ ) {
            if ( canceled_ ) {
                cancelBlock( YES );
            } else {
                cancel_callback_block_holder_.onceCancelBlock( NO );
                
                progressBlockHolder_.progressBlock = nil;
                finish_block_holder_.didFinishBlock = nil;
            }
        } copy] autorelease];
        
        [contextLoaders addActiveNativeLoader: nativeLoader
                                wrappedCancel: wrapped_cancel_block_ ];
        logBalancerState();
        
        return wrapped_cancel_block_;
    } copy ] autorelease ];
}

static BOOL canPeformAsyncOperationForContext(JFFContextLoaders *contextLoaders )
{
    // TODO check condition yet
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
