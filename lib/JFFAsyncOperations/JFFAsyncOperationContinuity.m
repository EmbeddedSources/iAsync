#import "JFFAsyncOperationContinuity.h"

#import "JFFCancelAyncOperationBlockHolder.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"
#import "NSError+ResultOwnerships.h"

#include <assert.h>

#import "JFFAsyncOperationHelpers.h"

typedef JFFAsyncOperationBinder (*MergeTwoBindersPtr)( JFFAsyncOperationBinder, JFFAsyncOperationBinder );
//JTODO remove
typedef JFFAsyncOperation (*MergeTwoLoadersPtr)( JFFAsyncOperation, JFFAsyncOperation );
//JTODO remove
typedef JFFAsyncOperation (*MergeLoaderWithBinderPtr)( JFFAsyncOperation, JFFAsyncOperationBinder );

static JFFAsyncOperationBinder MergeBinders( MergeTwoBindersPtr merger_, NSArray* blocks_ )
{
    assert( [ blocks_ lastObject ] );// should not be empty

    JFFAsyncOperationBinder firstBinder_ = [ blocks_ objectAtIndex: 0 ];

    for ( NSUInteger index_ = 1; index_ < [ blocks_ count ]; ++index_ )
    {
        JFFAsyncOperationBinder secondBinder_ = [ blocks_ objectAtIndex: index_ ];
        firstBinder_ = merger_( firstBinder_, secondBinder_ );
    }

    return firstBinder_;
}

//JTODO remove
static JFFAsyncOperation MergeLoaderWithBinders( MergeLoaderWithBinderPtr merger_, NSArray* blocks_ )
{
    assert( [ blocks_ lastObject ] ); //array should not be empty

    JFFAsyncOperation firstBlock_ = [ blocks_ objectAtIndex: 0 ];

    if ( [ blocks_ count ] == 1 )
        return firstBlock_;

    for ( NSUInteger index_ = 1; index_ < [ blocks_ count ]; ++index_ )
    {
        JFFAsyncOperationBinder secondBlock_ = [ blocks_ objectAtIndex: index_ ];

        firstBlock_ = merger_( firstBlock_, secondBlock_ );
    }

    return firstBlock_;
}

JFFAsyncOperationBinder bindSequenceOfBindersPair( JFFAsyncOperationBinder firstBinder_
                                                  , JFFAsyncOperationBinder secondBinder_ );

JFFAsyncOperationBinder bindSequenceOfBindersPair( JFFAsyncOperationBinder firstBinder_
                                                  , JFFAsyncOperationBinder secondBinder_ )
{
    assert( firstBinder_ ); // should not be nil;

    firstBinder_  = [ firstBinder_  copy ];
    secondBinder_ = [ secondBinder_ copy ];

    if ( !secondBinder_ )
        return secondBinder_;

    return ^JFFAsyncOperation( id bindResult_ )
    {
        JFFAsyncOperation firstLoader_ = firstBinder_( bindResult_ );
        return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                        , JFFCancelAsyncOperationHandler cancelCallback_
                                        , JFFDidFinishAsyncOperationHandler doneCallback_ )
        {
            JFFCancelAyncOperationBlockHolder* cancelBlockHolder_ = [ JFFCancelAyncOperationBlockHolder new ];

            doneCallback_ = [ doneCallback_ copy ];
            JFFCancelAsyncOperation firstCancel_ = firstLoader_( progressCallback_
                                                                , cancelCallback_
                                                                , ^void( id result_, NSError* error_ )
            {
                if ( error_ )
                {
                    if ( doneCallback_ )
                        doneCallback_( nil, error_ );
                }
                else
                {
                    JFFAsyncOperation secondLoader_ = secondBinder_( result_ );
                    assert( secondLoader_ );//result loader should not be nil
                    cancelBlockHolder_.cancelBlock = secondLoader_( progressCallback_
                                                                   , cancelCallback_
                                                                   , doneCallback_ );
                }
            } );
            if ( !cancelBlockHolder_.cancelBlock )
                cancelBlockHolder_.cancelBlock = firstCancel_;

            return cancelBlockHolder_.onceCancelBlock;
        };
    };
}

JFFAsyncOperation sequenceOfAsyncOperations( JFFAsyncOperation first_loader_
                                            , JFFAsyncOperation second_loader_
                                            , ... )
{
    JFFAsyncOperationBinder firstBlock_ = ^JFFAsyncOperation( id result_ )
    {
        return first_loader_;
    };

    va_list args;
    va_start( args, second_loader_ );
    for ( JFFAsyncOperation second_block_ = second_loader_;
         second_block_ != nil;
         second_block_ = va_arg( args, JFFAsyncOperation ) )
    {
        second_block_ = [ second_block_ copy ];
        JFFAsyncOperationBinder secondBlockBinder_ = ^JFFAsyncOperation( id result_ )
        {
            return second_block_;
        };
        firstBlock_ = bindSequenceOfBindersPair( firstBlock_, secondBlockBinder_ );
    }
    va_end( args );

    return firstBlock_( nil );
}

static JFFAsyncOperation mergeAsyncOperationsArrayWithMerger( NSArray* loaders_, MergeLoaderWithBinderPtr merger_ )
{
    NSArray* loaderWithBinders_ = [ loaders_ count ] > 0
        ? [ NSArray arrayWithObject: [ [ loaders_ objectAtIndex: 0 ] copy ] ]
        : nil;

    NSArray* binders_ = [ loaders_ count ] > 1
        ? [ loaders_ subarrayWithRange: NSMakeRange( 1, [ loaders_ count ] - 1 ) ]
        : [ NSArray array ];
    binders_ = [ binders_ map: ^id(id object_)
    {
        object_ = [ object_ copy ];
        return ^JFFAsyncOperation( id result_ )
        {
            return object_;
        };
    } ];

    loaderWithBinders_ = [ loaderWithBinders_ arrayByAddingObjectsFromArray: binders_ ];

    return MergeLoaderWithBinders( merger_, loaderWithBinders_ );
}

//JTODO test it
JFFAsyncOperation sequenceOfAsyncOperationsArray( NSArray* loaders_ )
{
    loaders_ = [ loaders_ map: ^id( id object_ )
    {
        JFFAsyncOperation loader_ = object_;
        return ^JFFAsyncOperation( id result_ )
        {
            return [ loader_ copy ];
        };
    } ];
    return MergeBinders( bindSequenceOfBindersPair, loaders_ )( nil );
}

JFFAsyncOperationBinder binderAsSequenceOfBinders( JFFAsyncOperationBinder firstBinder_, ... )
{
    va_list args;
    va_start( args, firstBinder_ );
    for ( JFFAsyncOperationBinder secondBinder_ = va_arg( args, JFFAsyncOperationBinder );
         secondBinder_ != nil;
         secondBinder_ = va_arg( args, JFFAsyncOperationBinder ) )
    {
        firstBinder_ = bindSequenceOfBindersPair( firstBinder_, secondBinder_ );
    }
    va_end( args );

    return firstBinder_;
}

JFFAsyncOperationBinder binderAsSequenceOfBindersArray( NSArray* binders_ )
{
    binders_ = [ binders_ map: ^id( id object_ )
    {
        return [ object_ copy ];
    } ];
    return MergeBinders( bindSequenceOfBindersPair, binders_ );
}

JFFAsyncOperation bindSequenceOfAsyncOperations( JFFAsyncOperation firstLoader_
                                                , JFFAsyncOperationBinder secondLoaderBinder_, ... )
{
    NSMutableArray* binders_ = [ NSMutableArray new ];

    firstLoader_ = [ firstLoader_ copy ];
    JFFAsyncOperationBinder firstBinder_ = ^JFFAsyncOperation( id nilResult_ )
    {
        return firstLoader_;
    };
    [ binders_ addObject: firstBinder_ ];

    va_list args;
    va_start( args, secondLoaderBinder_ );
    for ( JFFAsyncOperationBinder nextBinder_ = secondLoaderBinder_;
         nextBinder_ != nil;
         nextBinder_ = va_arg( args, JFFAsyncOperationBinder ) )
    {
        [ binders_ addObject: nextBinder_ ];
    }
    va_end( args );

    return binderAsSequenceOfBindersArray( binders_ )( nil );
}

JFFAsyncOperation bindSequenceOfAsyncOperationsArray( JFFAsyncOperation firstLoader_
                                                     , NSArray* loadersBinders_ )
{
    NSUInteger size_ = [ loadersBinders_ count ] + 1;
    NSMutableArray* binders_ = [ [ NSMutableArray alloc ] initWithCapacity: size_ ];

    firstLoader_ = [ firstLoader_ copy ];
    JFFAsyncOperationBinder firstBinder_ = ^JFFAsyncOperation( id nilResult_ )
    {
        return firstLoader_;
    };
    [ binders_ addObject: firstBinder_ ];

    [ binders_ addObjectsFromArray: loadersBinders_ ];

    return binderAsSequenceOfBindersArray( binders_ )( nil );
}

static JFFAsyncOperation bindTrySequenceOfAsyncOperationsPair( JFFAsyncOperation firstLoader_
                                                              , JFFAsyncOperationBinder secondLoaderBinder_ )
{
    assert( firstLoader_ ); // firstLoader_ should not be nil

    firstLoader_        = [ firstLoader_ copy ];
    secondLoaderBinder_ = [ secondLoaderBinder_ copy ];

    if ( secondLoaderBinder_ == nil )
        return firstLoader_;

    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        JFFCancelAyncOperationBlockHolder* blockHolder_ = [ JFFCancelAyncOperationBlockHolder new ];

        doneCallback_ = [ doneCallback_ copy ];

        JFFCancelAsyncOperation firstCancel_ = firstLoader_( progressCallback_
                                                             , cancelCallback_
                                                             , ^void( id result_, NSError* error_ )
        {
            if ( error_ )
            {
                JFFAsyncOperation secondLoader_ = secondLoaderBinder_( error_ );
                blockHolder_.cancelBlock = secondLoader_( progressCallback_, cancelCallback_, doneCallback_ );
            }
            else
            {
                if ( doneCallback_ )
                    doneCallback_( result_, nil );
            }
        } );
        if ( !blockHolder_.cancelBlock )
            blockHolder_.cancelBlock = firstCancel_;

        return blockHolder_.onceCancelBlock;
    };
}

JFFAsyncOperation trySequenceOfAsyncOperations( JFFAsyncOperation firstLoader_
                                               , JFFAsyncOperation secondLoader_, ... )
{
    JFFAsyncOperation firstBlock_ = firstLoader_;

    va_list args;
    va_start( args, secondLoader_ );
    for ( JFFAsyncOperation secondBlock_ = secondLoader_;
         secondBlock_ != nil;
         secondBlock_ = va_arg( args, JFFAsyncOperation ) )
    {
        secondBlock_ = [ secondBlock_ copy ];
        JFFAsyncOperationBinder secondBlockBinder_ = ^JFFAsyncOperation( id result_ )
        {
            return secondBlock_;
        };
        firstBlock_ = bindTrySequenceOfAsyncOperationsPair( firstBlock_, secondBlockBinder_ );
    }
    va_end( args );

    return firstBlock_;
}

JFFAsyncOperation trySequenceOfAsyncOperationsArray( NSArray* loaders_ )
{
    return mergeAsyncOperationsArrayWithMerger( loaders_, bindTrySequenceOfAsyncOperationsPair );
}

//JTODO test it
JFFAsyncOperation bindTrySequenceOfAsyncOperations( JFFAsyncOperation firstLoader_
                                                   , JFFAsyncOperationBinder secondLoaderBinder_, ... )
{
    JFFAsyncOperation firstBlock_ = firstLoader_;

    va_list args;
    va_start( args, secondLoaderBinder_ );
    for ( JFFAsyncOperationBinder secondBlockBinder_ = secondLoaderBinder_;
         secondBlockBinder_ != nil;
         secondBlockBinder_ = va_arg( args, JFFAsyncOperationBinder ) )
    {
        firstBlock_ = bindTrySequenceOfAsyncOperationsPair( firstBlock_, secondBlockBinder_ );
    }
    va_end( args );

    return firstBlock_;
}

//JTODO test it
JFFAsyncOperation bindTrySequenceOfAsyncOperationsArray( JFFAsyncOperation firstLoader_, NSArray* loadersBinders_ )
{
    loadersBinders_ = [ loadersBinders_ map: ^id( id object_ )
    {
        return [ object_ copy ];
    } ];
    NSArray* loaders_ = [ NSArray arrayWithObject: [ firstLoader_ copy ] ];
    loaders_ = [ loaders_ arrayByAddingObjectsFromArray: loadersBinders_ ];
    return MergeLoaderWithBinders( bindTrySequenceOfAsyncOperationsPair, loaders_ );
}

static void notifyGroupResult( JFFDidFinishAsyncOperationHandler doneCallback_
                              , NSArray* complexResult_
                              , NSError* error_ )
{
    if ( !doneCallback_ )
        return;

    NSMutableArray* finalResult_ = nil;
    if ( !error_ )
    {
        NSArray* firstResult_ = [ complexResult_ objectAtIndex: 0 ];
        finalResult_ = [ [ NSMutableArray alloc ] initWithCapacity: [ firstResult_ count ] + 1 ];
        [ finalResult_ addObjectsFromArray: firstResult_ ];
        [ finalResult_ addObject: [ complexResult_ objectAtIndex: 1 ] ];
    }
    doneCallback_( finalResult_, error_ );
}

static JFFAsyncOperation groupOfAsyncOperationsPair( JFFAsyncOperation firstLoader_
                                                    , JFFAsyncOperation secondLoader_ )
{
    assert( firstLoader_ );//do not pass nil

    firstLoader_  = [ firstLoader_  copy ];
    secondLoader_ = [ secondLoader_ copy ];

    if ( secondLoader_ == nil )
        return firstLoader_;

    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        __block BOOL loaded_ = NO;
        __block NSError* errorHolder_;

        NSMutableArray* complexResult_ = [ [ NSMutableArray alloc ] initWithObjects:
                                          [ NSNull null ]
                                          , [ NSNull null ]
                                          , nil ];

        doneCallback_ = [ doneCallback_ copy ];

        JFFDidFinishAsyncOperationHandler (^makeResultHandler_)( NSUInteger ) =
            ^JFFDidFinishAsyncOperationHandler( NSUInteger index_ )
        {
            return ^void( id result_, NSError* error_ )
            {
                if ( result_ )
                    [ complexResult_ replaceObjectAtIndex: index_ withObject: result_ ];

                if ( loaded_ )
                {
                    error_ = error_ ? error_ : errorHolder_;

                    if ( result_ )
                        [ error_.lazyResultOwnerships addObject: result_ ];

                    if ( errorHolder_ && error_ != errorHolder_ && errorHolder_.resultOwnerships )
                    {
                        [ error_.lazyResultOwnerships addObject: errorHolder_.resultOwnerships ];
                        errorHolder_.resultOwnerships = nil;
                    }

                    notifyGroupResult( doneCallback_, complexResult_, error_ );
                    error_.resultOwnerships = nil;

                    return;
                }
                loaded_ = YES;

                errorHolder_ = [ error_ copy ];
                errorHolder_.resultOwnerships = error_.resultOwnerships;
            };
        };

        __block BOOL blockCanceled_ = NO;

        cancelCallback_ = [ cancelCallback_ copy ];
        JFFCancelAsyncOperationHandler (^makeCancelHandler_)( JFFCancelAyncOperationBlockHolder* ) =
            ^( JFFCancelAyncOperationBlockHolder* cancelHolder_ )
        {
            return ^void( BOOL canceled_ )
            {
                if ( !blockCanceled_ )
                {
                    blockCanceled_ = YES;
                    cancelHolder_.onceCancelBlock( canceled_ );
                    if ( cancelCallback_ )
                        cancelCallback_( canceled_ );
                }
            };
        };

        JFFDidFinishAsyncOperationHandler (^makeFinishHandler_)( JFFCancelAyncOperationBlockHolder*, NSUInteger ) =
            ^JFFDidFinishAsyncOperationHandler( JFFCancelAyncOperationBlockHolder* cancelHolder_
                                               , NSUInteger index_ )
        {
            JFFDidFinishAsyncOperationHandler handler_ = makeResultHandler_( index_ );
            return ^void( id result_, NSError* error_ )
            {
                cancelHolder_.cancelBlock = nil;
                handler_( result_, error_ );
            };
        };

        JFFCancelAyncOperationBlockHolder* cancelHolder1_ = [ JFFCancelAyncOperationBlockHolder new ];
        JFFCancelAyncOperationBlockHolder* cancelHolder2_ = [ JFFCancelAyncOperationBlockHolder new ];

        cancelHolder1_.cancelBlock = firstLoader_( progressCallback_
                                                   , makeCancelHandler_( cancelHolder2_ )
                                                   , makeFinishHandler_( cancelHolder1_, 0 ) );
        cancelHolder2_.cancelBlock = secondLoader_( progressCallback_
                                                    , makeCancelHandler_( cancelHolder1_ )
                                                    , makeFinishHandler_( cancelHolder2_, 1 ) );

        return ^void( BOOL cancel_ )
        {
            if ( !blockCanceled_ )
            {
                blockCanceled_ = YES;
                cancelHolder1_.onceCancelBlock( cancel_ );
                cancelHolder2_.onceCancelBlock( cancel_ );
                if ( cancelCallback_ )
                    cancelCallback_( cancel_ );
            }
        };
    };
}

static JFFAsyncOperation resultToArrayForLoader( JFFAsyncOperation loader_ )
{
    JFFAsyncOperationBinder secondLoaderBinder_ = asyncOperationBinderWithAnalyzer( ^( id result_, NSError** error_ )
    {
        return [ NSArray arrayWithObject: result_ ];
    } );
    return bindSequenceOfAsyncOperations( loader_, secondLoaderBinder_, nil );
}

static JFFAsyncOperation MergeGroupLoaders( MergeTwoLoadersPtr merger_, NSArray* blocks_ )
{
    if ( ![ blocks_ lastObject ] )
        return asyncOperationWithResult( [ NSArray array ] );

    JFFAsyncOperation firstBlock_ = [ blocks_ objectAtIndex: 0 ];
    JFFAsyncOperation arrayFirstBlock_ = resultToArrayForLoader( firstBlock_ );

    for ( JFFAsyncOperation second_block_ in blocks_ )
    {
        if ( second_block_ == firstBlock_ )
            continue;

        arrayFirstBlock_ = merger_( arrayFirstBlock_, second_block_ );
    }

    return arrayFirstBlock_;
}

JFFAsyncOperation groupOfAsyncOperationsArray( NSArray* blocks_ )
{
    return MergeGroupLoaders( groupOfAsyncOperationsPair, blocks_ );
}

JFFAsyncOperation groupOfAsyncOperations( JFFAsyncOperation first_loader_, ... )
{
    NSMutableArray* loaders_ = [ NSMutableArray new ];

    va_list args;
    va_start( args, first_loader_ );
    for ( JFFAsyncOperation next_block_ = first_loader_;
         next_block_ != nil;
         next_block_ = va_arg( args, JFFAsyncOperation ) )
    {
        next_block_ = [ next_block_ copy ];
        [ loaders_ addObject: next_block_ ];
    }
    va_end( args );

    return groupOfAsyncOperationsArray( loaders_ );
}

static JFFDidFinishAsyncOperationHandler cancelSafeResultBlock( JFFDidFinishAsyncOperationHandler resultBlock_
                                                               , JFFCancelAyncOperationBlockHolder* cancelHolder_ )
{
    resultBlock_ = [ resultBlock_ copy ];
    return ^void( id result_, NSError* error_ )
    {
        cancelHolder_.cancelBlock = nil;
        resultBlock_( result_, error_ );
    };
}

static JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperationsPair( JFFAsyncOperation firstLoader_
                                                                    , JFFAsyncOperation secondLoader_ )
{
    assert( firstLoader_ );//do not pass nil

    firstLoader_  = [ firstLoader_  copy ];
    secondLoader_ = [ secondLoader_ copy ];

    if ( secondLoader_ == nil )
        return firstLoader_;

    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        __block BOOL loaded_ = NO;
        __block BOOL done_ = NO;

        JFFCancelAyncOperationBlockHolder* cancelHolder1_ = [ JFFCancelAyncOperationBlockHolder new ];
        JFFCancelAyncOperationBlockHolder* cancelHolder2_ = [ JFFCancelAyncOperationBlockHolder new ];

        NSMutableArray* complexResult_ = [ NSMutableArray arrayWithObjects:
                                          [ NSNull null ]
                                          , [ NSNull null ]
                                          , nil ];

        doneCallback_ = [ doneCallback_ copy ];
        JFFDidFinishAsyncOperationHandler (^makeResultHandler_)( NSUInteger ) =
            ^JFFDidFinishAsyncOperationHandler( NSUInteger index_ )
        {
            return ^void( id result_, NSError* error_ )
            {
                if ( result_ )
                    [ complexResult_ replaceObjectAtIndex: index_ withObject: result_ ];
                BOOL firstError_ = error_ && !done_;
                if ( loaded_ || firstError_ )
                {
                    if ( firstError_ )
                    {
                        cancelHolder1_.onceCancelBlock( YES );
                        cancelHolder2_.onceCancelBlock( YES );
                    }

                    done_ = YES;
                    notifyGroupResult( doneCallback_, complexResult_, error_ );
                    return;
                }
                loaded_ = YES;
            };
        };

        __block BOOL blockCanceled_ = NO;

        cancelCallback_ = [ cancelCallback_ copy ];
        JFFCancelAsyncOperationHandler (^makeCancelCallback_)( JFFCancelAyncOperationBlockHolder* ) =
        ^( JFFCancelAyncOperationBlockHolder* cancelHolder_ )
        {
            return ^void( BOOL canceled_ )
            {
                if ( !blockCanceled_ )
                {
                    blockCanceled_ = YES;
                    cancelHolder_.onceCancelBlock( canceled_ );
                    if ( cancelCallback_ )
                        cancelCallback_( canceled_ );
                }
            };
        };

        JFFCancelAsyncOperation cancel1_ = firstLoader_( progressCallback_
                                                        , makeCancelCallback_( cancelHolder2_ )
                                                        , cancelSafeResultBlock( makeResultHandler_( 0 )
                                                                                , cancelHolder1_ ) );

        cancelHolder1_.cancelBlock = done_ ? JFFStubCancelAsyncOperationBlock : cancel1_;

        JFFCancelAsyncOperation cancel2_ = done_
            ? JFFStubCancelAsyncOperationBlock
            : secondLoader_( progressCallback_
                             , makeCancelCallback_( cancelHolder1_ )
                             , cancelSafeResultBlock( makeResultHandler_( 1 )
                                                     , cancelHolder2_ ) );

        cancelHolder2_.cancelBlock = done_ ? JFFStubCancelAsyncOperationBlock : cancel2_;

        return ^void( BOOL cancel_ )
        {
            if ( !blockCanceled_ )
            {
                blockCanceled_ = YES;
                cancelHolder1_.onceCancelBlock( cancel_ );
                cancelHolder2_.onceCancelBlock( cancel_ );
                if ( cancelCallback_ )
                    cancelCallback_( cancel_ );
            }
        };
    };
}

JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperations( JFFAsyncOperation firstLoader_
                                                         , ... )
{
    NSMutableArray* loaders_ = [ NSMutableArray new ];

    va_list args;
    va_start( args, firstLoader_ );
    for ( JFFAsyncOperation next_block_ = firstLoader_;
         next_block_ != nil;
         next_block_ = va_arg( args, JFFAsyncOperation ) )
    {
        next_block_ = [ next_block_ copy ];
        [ loaders_ addObject: next_block_ ];
    }
    va_end( args );

    return failOnFirstErrorGroupOfAsyncOperationsArray( loaders_ );
}

JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperationsArray( NSArray* blocks_ )
{
    return MergeGroupLoaders( failOnFirstErrorGroupOfAsyncOperationsPair, blocks_ );
}

JFFAsyncOperation asyncOperationWithDoneBlock( JFFAsyncOperation loader_
                                              , JFFSimpleBlock doneCallbackHook_ )
{
    loader_ = [ loader_ copy ];
    if ( nil == doneCallbackHook_ )
        return loader_;

    doneCallbackHook_ = [ doneCallbackHook_ copy ];
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        cancelCallback_ = [ cancelCallback_ copy ];
        JFFCancelAsyncOperationHandler wrappedCancelCallback_ = ^void( BOOL canceled_ )
        {
            doneCallbackHook_();

            if ( cancelCallback_ )
                cancelCallback_( canceled_ );
        };

        doneCallback_ = [ doneCallback_ copy ];
        JFFDidFinishAsyncOperationHandler wrappedDoneCallback_ = ^void( id result_, NSError* error_ )
        {
            doneCallbackHook_();

            if ( doneCallback_ )
                doneCallback_( result_, error_ );
        };
        return loader_( progressCallback_, wrappedCancelCallback_, wrappedDoneCallback_ );
    };
}

JFFAsyncOperation repeatAsyncOperation( JFFAsyncOperation nativeLoader_
                                       , JFFPredicateBlock predicate_
                                       , NSTimeInterval delay_
                                       , NSInteger maxRepeatCount_ )
{
    assert( nativeLoader_ );// can not be nil
    assert( predicate_    );// can not be nil

    nativeLoader_ = [ nativeLoader_ copy ];
    predicate_    = [ predicate_    copy ];

    return ^( JFFAsyncOperationProgressHandler progressCallback_
             , JFFCancelAsyncOperationHandler cancelCallback_
             , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        progressCallback_ = [ progressCallback_ copy ];
        cancelCallback_   = [ cancelCallback_   copy ];
        doneCallback_     = [ doneCallback_     copy ];

        JFFCancelAyncOperationBlockHolder* holder_ = [ JFFCancelAyncOperationBlockHolder new ];

        __block JFFDidFinishAsyncOperationHook finishHookHolder_ = nil;

        __block NSInteger currentLeftCount = maxRepeatCount_;

        JFFDidFinishAsyncOperationHook finish_callback_hook_ = ^( id result_
                                                                 , NSError* error_
                                                                 , JFFDidFinishAsyncOperationHandler doneCallback_ )
        {
            JFFResultContext* context_ = [ JFFResultContext new ];
            context_.result = result_;
            context_.error  = error_ ;
            if ( !predicate_( context_ ) || currentLeftCount == 0 )
            {
                finishHookHolder_ = nil;
                if ( doneCallback_ )
                    doneCallback_( result_, error_ );
            }
            else
            {
                currentLeftCount = currentLeftCount > 0
                    ? currentLeftCount - 1
                    : currentLeftCount;

                JFFAsyncOperation loader_ = asyncOperationWithFinishHookBlock( nativeLoader_
                                                                              , finishHookHolder_ );
                loader_ = asyncOperationAfterDelay( delay_, loader_ );

                holder_.cancelBlock = loader_( progressCallback_, cancelCallback_, doneCallback_ );
            }
        };

        finishHookHolder_ = [ finish_callback_hook_ copy ];

        JFFAsyncOperation loader_ = asyncOperationWithFinishHookBlock( nativeLoader_
                                                                      , finishHookHolder_ );

        holder_.cancelBlock = loader_( progressCallback_, cancelCallback_, doneCallback_ );

        return ^( BOOL canceled_ )
        {
            finishHookHolder_ = nil;
            holder_.onceCancelBlock( canceled_ );
        };
    };
}

JFFAsyncOperation asyncOperationAfterDelay( NSTimeInterval delay_
                                           , JFFAsyncOperation loader_ )
{
    return sequenceOfAsyncOperations( asyncOperationWithDelay( delay_ )
                                     , loader_
                                     , nil );
}
