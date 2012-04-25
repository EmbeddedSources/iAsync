#import "JFFAsyncOperationLoadBalancer.h"

#import "JFFContextLoaders.h"
#import "JFFPedingLoaderData.h"
#import "JFFAsyncOperationLoadBalancerContexts.h"
#import "JFFAsyncOperationProgressBlockHolder.h"
#import "JFFCancelAsyncOperationBlockHolder.h"
#import "JFFDidFinishAsyncOperationBlockHolder.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"

static const NSUInteger max_operation_count_ = 5;
static const NSUInteger total_max_operation_count_ = 7;

static NSUInteger global_active_number_ = 0;

static JFFAsyncOperationLoadBalancerContexts* sharedBalancer()
{
    return [ JFFAsyncOperationLoadBalancerContexts sharedBalancer ];
}

static void setBalancerCurrentContextName( NSString* context_name_ )
{
    sharedBalancer().currentContextName = context_name_;
}

static BOOL canPeformAsyncOperationForContext( JFFContextLoaders* context_loaders_ );
static BOOL findAndTryToPerformNextNativeLoader( void );

void setBalancerActiveContextName( NSString* context_name_ )
{
   if ( [ sharedBalancer().activeContextName isEqualToString: context_name_ ] )
      return;

   NSLog( @"!!!SET ACTIVE CONTEXT NAME: %@", context_name_ );
   sharedBalancer().activeContextName = context_name_;
   setBalancerCurrentContextName( context_name_ );

   while ( findAndTryToPerformNextNativeLoader() );
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
      JFFPedingLoaderData* pending_loader_data_ = [ context_loaders_ popPendingLoaderData ];
      performInBalancerPedingLoaderData( pending_loader_data_, context_loaders_ );
      //JTODO remove empty context_loaders_ (without tasks)
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
      --global_active_number_;
      logBalancerState();
   }
}

static JFFCancelAsyncOperationHandler cancelCallbackWrapper( JFFCancelAsyncOperationHandler native_cancel_callback_
                                                            , JFFAsyncOperation native_loader_
                                                            , JFFContextLoaders* context_loaders_ )
{
   native_cancel_callback_ = [ [ native_cancel_callback_ copy ] autorelease ];
   return [ [ ^void( BOOL canceled_ )
   {
      if ( !canceled_ )
      {
         assert( NO );// @"balanced loaders should not be unsubscribed from native loader"
      }

      [ [ native_cancel_callback_ copy ] autorelease ];

      finishExecuteOfNativeLoader( native_loader_, context_loaders_ );

      if ( native_cancel_callback_ )
      {
         peformBlockWithinContext( ^
         {
            native_cancel_callback_( canceled_ );
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

static JFFAsyncOperation wrappedAsyncOperationWithContext( JFFAsyncOperation nativeLoader_
                                                          , JFFContextLoaders* context_loaders_ )
{
    nativeLoader_ = [ [ nativeLoader_ copy ] autorelease ];
    return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler nativeProgressCallback_
                                        , JFFCancelAsyncOperationHandler native_cancel_callback_
                                        , JFFDidFinishAsyncOperationHandler native_done_callback_ )
    {
        //progress holder for unsubscribe
        JFFAsyncOperationProgressBlockHolder* progressBlockHolder_ = [ [ JFFAsyncOperationProgressBlockHolder new ] autorelease ];
        progressBlockHolder_.progressBlock = nativeProgressCallback_;
        JFFAsyncOperationProgressHandler wrapped_progress_callback_ = ^void( id progress_info_ )
        {
            peformBlockWithinContext( ^
            {
                [ progressBlockHolder_ performProgressBlockWithArgument: progress_info_ ];
            }, context_loaders_ );
        };

        __block BOOL done_ = NO;

        //cancel holder for unsubscribe
        JFFCancelAsyncOperationBlockHolder* cancel_callback_block_holder_ = [ [ JFFCancelAsyncOperationBlockHolder new ] autorelease ];
        cancel_callback_block_holder_.cancelBlock = native_cancel_callback_;
        JFFCancelAsyncOperation wrapped_cancel_callback_ = ^void( BOOL canceled_ )
        {
            done_ = YES;
            cancel_callback_block_holder_.onceCancelBlock( canceled_ );
        };

        //finish holder for unsubscribe
        JFFDidFinishAsyncOperationBlockHolder* finish_block_holder_ = [ [ JFFDidFinishAsyncOperationBlockHolder new ] autorelease ];
        finish_block_holder_.didFinishBlock = native_done_callback_;
        JFFDidFinishAsyncOperationHandler wrapped_done_callback_ = ^void( id result_, NSError* error_ )
        {
            done_ = YES;
            finish_block_holder_.onceDidFinishBlock( result_, error_ );
        };

        wrapped_cancel_callback_ = cancelCallbackWrapper( wrapped_cancel_callback_
                                                         , nativeLoader_
                                                         , context_loaders_ );

        wrapped_done_callback_ = doneCallbackWrapper( wrapped_done_callback_
                                                     , nativeLoader_
                                                     , context_loaders_ );

        //JTODO check native loader no within balancer !!!
        JFFCancelAsyncOperation cancel_block_ = nativeLoader_( wrapped_progress_callback_
                                                              , wrapped_cancel_callback_
                                                              , wrapped_done_callback_ );

        if ( done_ )
        {
            return JFFStubCancelAsyncOperationBlock;
        }

        ++global_active_number_;

        JFFCancelAsyncOperation wrapped_cancel_block_ = [ [ ^void( BOOL canceled_ )
        {
            if ( canceled_ )
            {
                cancel_block_( YES );
            }
            else
            {
                cancel_callback_block_holder_.onceCancelBlock( NO );

                progressBlockHolder_.progressBlock = nil;
                finish_block_holder_.didFinishBlock = nil;
            }
        } copy ] autorelease ];

        [ context_loaders_ addActiveNativeLoader: nativeLoader_
                                   wrappedCancel: wrapped_cancel_block_ ];
        logBalancerState();

        return wrapped_cancel_block_;
    } copy ] autorelease ];
}

static BOOL canPeformAsyncOperationForContext( JFFContextLoaders* contextLoaders_ )
{
    //JTODO check condition yet
    BOOL isActiveContext_ = [ sharedBalancer().activeContextName isEqualToString: contextLoaders_.name ];
    return ( ( isActiveContext_ && contextLoaders_.activeLoadersNumber < max_operation_count_ )
            || 0 == global_active_number_ )
        && global_active_number_ <= total_max_operation_count_;
}

JFFAsyncOperation balancedAsyncOperation( JFFAsyncOperation native_loader_ )
{
    JFFContextLoaders* contextLoaders_ = [ sharedBalancer() currentContextLoaders ];

    native_loader_ = [ [ native_loader_ copy ] autorelease ];
    return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                        , JFFCancelAsyncOperationHandler cancel_callback_
                                        , JFFDidFinishAsyncOperationHandler done_callback_ )
    {
        if ( canPeformAsyncOperationForContext( contextLoaders_ ) )
        {
            JFFAsyncOperation context_loader_ = wrappedAsyncOperationWithContext( native_loader_
                                                                                 , contextLoaders_ );
            return context_loader_( progress_callback_, cancel_callback_, done_callback_ );
        }

        cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
        [ contextLoaders_ addPendingNativeLoader: native_loader_
                                progressCallback: progress_callback_
                                  cancelCallback: cancel_callback_
                                    doneCallback: done_callback_ ];

        logBalancerState();

        JFFCancelAsyncOperation cancel_ = [ [ ^void( BOOL canceled_ )
        {
            if ( ![ contextLoaders_ containsPendingNativeLoader: native_loader_ ] )
            {
                //cancel only wrapped cancel block
                [ contextLoaders_ cancelActiveNativeLoader: native_loader_ cancel: canceled_ ];
                return;
            }

            if ( canceled_ )
            {
                [ contextLoaders_ removePendingNativeLoader: native_loader_ ];
                cancel_callback_( YES );
            }
            else
            {
                cancel_callback_( NO );

                [ contextLoaders_ unsubscribePendingNativeLoader: native_loader_ ];
            }
        } copy ] autorelease ];

        return cancel_;
    } copy ] autorelease ];
}
