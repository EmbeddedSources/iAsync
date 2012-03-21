#import "JFFAsyncOperationHelpers.h"

#import "JFFAsyncOperationContinuity.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"

#import <JFFScheduler/JFFScheduler.h>

JFFAsyncOperation asyncOperationWithResult( id result_ )
{
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        if ( doneCallback_ )
            doneCallback_( result_, nil );
        return JFFEmptyCancelAsyncOperationBlock;
    };
}

JFFAsyncOperation asyncOperationWithError( NSError* error_ )
{
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        if ( doneCallback_ )
            doneCallback_( nil, error_ );
        return JFFEmptyCancelAsyncOperationBlock;
    };
}

JFFAsyncOperation asyncOperationWithFinishCallbackBlock( JFFAsyncOperation loader_
                                                        , JFFDidFinishAsyncOperationHandler finishCallbackBlock_ )
{
    finishCallbackBlock_ = [ finishCallbackBlock_ copy ];
    loader_ = [ loader_ copy ];
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        doneCallback_ = [ doneCallback_ copy ];
        return loader_( progressCallback_, cancelCallback_, ^void( id result_, NSError* error_ )
        {
            if ( finishCallbackBlock_ )
                finishCallbackBlock_( result_, error_ );
            if ( doneCallback_ )
                doneCallback_( result_, error_ );
       } );
    };
}

JFFAsyncOperation asyncOperationWithFinishHookBlock( JFFAsyncOperation loader_
                                                    , JFFDidFinishAsyncOperationHook finishCallbackHook_ )
{
    assert( finishCallbackHook_ );// should not be nil"
    finishCallbackHook_ = [ finishCallbackHook_ copy ];
    loader_ = [ loader_ copy ];
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        doneCallback_ = [ doneCallback_ copy ];
        return loader_( progressCallback_, cancelCallback_, ^void( id result_, NSError* error_ )
        {
            finishCallbackHook_( result_, error_, doneCallback_ );
        } );
    };
}

JFFAsyncOperation asyncOperationWithAnalyzer( id data_, JFFAnalyzer analyzer_ )
{
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        NSError* localError_;
        id localResult_ = analyzer_( data_, &localError_ );

        if ( doneCallback_ )
            doneCallback_( localError_ ? nil : localResult_, localError_ );

        return JFFEmptyCancelAsyncOperationBlock;
    };
}

JFFAsyncOperationBinder asyncOperationBinderWithAnalyzer( JFFAnalyzer analyzer_ )
{
    analyzer_ = [ analyzer_ copy ];
    return ^( id result_ )
    {
        return asyncOperationWithAnalyzer( result_, analyzer_ );
    };
}

JFFAsyncOperation asyncOperationWithChangedResult( JFFAsyncOperation loader_
                                                  , JFFChangedResultBuilder resultBuilder_ )
{
    resultBuilder_ = [ resultBuilder_ copy ];
    JFFAsyncOperationBinder secondLoaderBinder_ = asyncOperationBinderWithAnalyzer( ^id( id result_
                                                                                        , NSError **error_ )
    {
        assert( result_ );//@"can not be nil";
        id newResult_ = resultBuilder_ ? resultBuilder_( result_ ) : result_;
        assert( newResult_ );//@"can not be nil";
        return newResult_;
    } );

    return bindSequenceOfAsyncOperations( loader_, secondLoaderBinder_, nil );
}

JFFAsyncOperation asyncOperationWithChangedError( JFFAsyncOperation loader_
                                                 , JFFChangedErrorBuilder errorBuilder_ )
{
    if ( !errorBuilder_ )
        return loader_;
    errorBuilder_ = [ errorBuilder_ copy ];
    JFFDidFinishAsyncOperationHook finishCallbackHook_ = ^( id result_
                                                           , NSError* error_
                                                           , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        if ( doneCallback_ )
            doneCallback_( result_, error_ ? errorBuilder_( error_ ) : nil );
    };
    return asyncOperationWithFinishHookBlock( loader_, finishCallbackHook_ );
}

JFFAsyncOperation asyncOperationWithResultOrError( JFFAsyncOperation loader_
                                                  , id result_
                                                  , NSError* error_ )
{
    return asyncOperationWithFinishHookBlock( loader_
                                             , ^( id localResult_
                                                 , NSError* localError_
                                                 , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        if ( doneCallback_ )
            doneCallback_( result_, error_ );
    } );
}

JFFAsyncOperation asyncOperationWithDelay( NSTimeInterval delay_ )
{
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        __block JFFScheduler* scheduler_ = [ JFFScheduler new ];

        [ scheduler_ addBlock: ^( JFFCancelScheduledBlock cancel_ )
        {
            #pragma GCC diagnostic push
            #pragma GCC diagnostic ignored "-Warc-retain-cycles"
            scheduler_ = nil;
            #pragma GCC diagnostic pop

            if ( progressCallback_ )
                progressCallback_( [ NSNull null ] );

            if ( doneCallback_ )
                doneCallback_( [ NSNull null ], nil );
        } duration: delay_ ];

        __block JFFCancelAsyncOperationHandler cancelCallbackHandler_ = [ cancelCallback_ copy ];
        return ^( BOOL canceled_ )
        {
            if ( !scheduler_ )
                return;

            scheduler_ = nil;

            if ( cancelCallbackHandler_ )
            {
                cancelCallbackHandler_( canceled_ );
                cancelCallbackHandler_ = nil;
            }
        };
    };
}

JFFAsyncOperationBinder bindSequenceOfBindersPair( JFFAsyncOperationBinder firstBinder_
                                                  , JFFAsyncOperationBinder secondBinder_ );

//JTODO test it
JFFAnalyzer analyzerAsSequenceOfAnalyzers( JFFAnalyzer firstAnalyzer_, ... )
{
    JFFAsyncOperationBinder firstBinder_ = asyncOperationBinderWithAnalyzer( firstAnalyzer_ );

    va_list args;
    va_start( args, firstAnalyzer_ );
    for ( JFFAnalyzer nextAnalyzer_ = va_arg( args, JFFAnalyzer );
         nextAnalyzer_ != nil;
         nextAnalyzer_ = va_arg( args, JFFAnalyzer ) )
    {
        JFFAsyncOperationBinder nextBinder_ = asyncOperationBinderWithAnalyzer( nextAnalyzer_ );
        firstBinder_ = bindSequenceOfBindersPair( firstBinder_, nextBinder_ );
    }
    va_end( args );

    return ^id(id dataToAnalyze_, NSError** outError_)
    {
        JFFAsyncOperation loader_ = firstBinder_( dataToAnalyze_ );
        __block id finalResult_ = nil;
        loader_( nil, nil, ^( id loaderResult_, NSError* error_ )
        {
            [ error_ setToPointer: outError_ ];
            finalResult_ = loaderResult_; 
        } );
        return finalResult_;
    };
}
