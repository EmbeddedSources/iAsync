#import "JFFAsyncOperationHelpers.h"

#import "JFFAsyncOperationContinuity.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"
#import "JFFAsyncOperationBuilder.h"
#import "JFFAsyncOperationInterface.h"

#import <JFFScheduler/JFFScheduler.h>

@interface JFFAsyncOperationScheduler : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic ) NSTimeInterval duration;

@end

@implementation JFFAsyncOperationScheduler
{
    JFFScheduler* _scheduler;
}

@synthesize duration = _duration;

-(void)asyncOperationWithResultHandler:( void (^)( id, NSError* ) )handler_
                       progressHandler:( void (^)( id ) )progress_
{
    self->_scheduler = [ JFFScheduler new ];
    [ self->_scheduler addBlock: ^( JFFCancelScheduledBlock cancel_ )
    {
        cancel_();
        if ( progress_ )
            progress_( [ NSNull null ] );
        if ( handler_ )
            handler_( [ NSNull null ], nil );
    } duration: self.duration ];
}

-(void)cancel:( BOOL )canceled_
{
    self->_scheduler = nil;
}

@end

JFFAsyncOperation asyncOperationWithResult( id result_ )
{
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        if ( doneCallback_ )
            doneCallback_( result_, nil );
        return JFFStubCancelAsyncOperationBlock;
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
        return JFFStubCancelAsyncOperationBlock;
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

JFFAsyncOperation asyncOperationWithStartAndFinishBlocks( JFFAsyncOperation loader_
                                                         , JFFSimpleBlock startBlock_
                                                         , JFFDidFinishAsyncOperationHandler finishCallback_ )
{
    startBlock_     = [ startBlock_ copy ];
    finishCallback_ = [ finishCallback_ copy ];

    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        if ( startBlock_ )
            startBlock_();

        doneCallback_ = [ doneCallback_ copy ];
        JFFDidFinishAsyncOperationHandler doneCallback2_ = ^( id result_, NSError* error_ )
        {
            if ( finishCallback_ )
                finishCallback_( result_, error_ );
            if ( doneCallback_ )
                doneCallback_( result_, error_ );
        };
        return loader_( progressCallback_, cancelCallback_, doneCallback2_ );
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

        return JFFStubCancelAsyncOperationBlock;
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

JFFAsyncOperation asyncOperationResultAsProgress( JFFAsyncOperation loader_ )
{
    loader_ = [ loader_ copy ];
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        progressCallback_ = [ progressCallback_ copy ];
        doneCallback_     = [ doneCallback_     copy ];
        JFFDidFinishAsyncOperationHandler doneCallbackWrapper_ = ^( id result_, NSError* error_ )
        {
            if ( result_ && progressCallback_ )
                progressCallback_( result_ );

            if ( doneCallback_ )
                doneCallback_( result_, error_ );
        };
        return loader_( nil, cancelCallback_, doneCallbackWrapper_ );
    };
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
    JFFAsyncOperationScheduler* asyncObject_ = [ JFFAsyncOperationScheduler new ];
    asyncObject_.duration = delay_;
    return buildAsyncOperationWithInterface( asyncObject_ );
}

JFFAsyncOperationBinder bindSequenceOfBindersPair( JFFAsyncOperationBinder firstBinder_
                                                  , JFFAsyncOperationBinder secondBinder_ );

//!!! not tested yet
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

JFFAsyncOperation ignorePregressLoader( JFFAsyncOperation loader_ )
{
    loader_ = [ loader_ copy ];
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        return loader_( nil, cancelCallback_, doneCallback_ );
    };
}
