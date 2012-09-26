#import "JFFAsyncOperationHelpers.h"

#import "JFFAsyncOperationContinuity.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"
#import "JFFAsyncOperationBuilder.h"
#import "JFFAsyncOperationInterface.h"

#import <JFFScheduler/JFFScheduler.h>

@implementation JFFAsyncTimerResult : NSObject
@end

@interface JFFAsyncOperationScheduler : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic ) NSTimeInterval duration;

@end

@implementation JFFAsyncOperationScheduler
{
    JFFScheduler* _scheduler;
}

- (void)asyncOperationWithResultHandler:(void(^)(id, NSError *))handler
                        progressHandler:(void(^)(id))progress
{
    handler  = [handler  copy];
    progress = [progress copy];

    self->_scheduler = [JFFScheduler new];
    [self->_scheduler addBlock:^(JFFCancelScheduledBlock cancel)
    {
        cancel();
        if (progress)
            progress([JFFAsyncTimerResult new]);
        if (handler)
            handler([JFFAsyncTimerResult new], nil);
    }duration:self.duration];
}

- (void)cancel:(BOOL)canceled
{
    self->_scheduler = nil;
}

@end

JFFAsyncOperation asyncOperationWithResult(id result)
{
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback)
    {
        if (doneCallback)
            doneCallback(result, nil);
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

JFFAsyncOperation currentQeueAsyncOpWithResult( JFFSyncOperation block )
{
    assert( block );
    block = [block copy];

    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        NSError* error_;
        id result_;
        if ( block )
        {
            result_ = block( &error_ );
        }
        else
        {
            error_ = [ JFFError newErrorWithDescription: NSLocalizedString( @"NOT_SPECIFIED_BLOCK_ERROR", nil ) ];
        }

        if ( doneCallback_ )
            doneCallback_( result_, error_ );

        return JFFStubCancelAsyncOperationBlock;
    };
}

JFFAsyncOperation asyncOperationWithFinishCallbackBlock( JFFAsyncOperation loader_
                                                        , JFFDidFinishAsyncOperationHandler finishCallbackBlock_ )
{
    assert( loader_ );
    finishCallbackBlock_ = [ finishCallbackBlock_ copy ];
    loader_              = [ loader_ copy ];
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
    assert( loader_ );// should not be nil"
    assert( finishCallbackHook_ );// should not be nil"
    finishCallbackHook_ = [ finishCallbackHook_ copy ];
    loader_             = [ loader_             copy ];
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

JFFAsyncOperation asyncOperationWithStartAndFinishBlocks(JFFAsyncOperation loader,
                                                         JFFSimpleBlock startBlock,
                                                         JFFDidFinishAsyncOperationHandler finishCallback)
{
    startBlock     = [startBlock     copy];
    finishCallback = [finishCallback copy];
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        if (startBlock)
            startBlock();
        
        doneCallback = [doneCallback copy];
        JFFDidFinishAsyncOperationHandler wrappedDoneCallback = ^(id result, NSError *error) {
            if (finishCallback)
                finishCallback(result, error);
            if (doneCallback)
                doneCallback(result, error);
        };
        return loader(progressCallback, cancelCallback, wrappedDoneCallback);
    };
}

JFFAsyncOperation asyncOperationWithAnalyzer(id data, JFFAnalyzer analyzer)
{
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        NSError *localError;
        id localResult = analyzer(data, &localError);
        
        if (doneCallback)
            doneCallback(localError?nil:localResult, localError);
        
        return JFFStubCancelAsyncOperationBlock;
    };
}

JFFAsyncOperationBinder asyncOperationBinderWithAnalyzer(JFFAnalyzer analyzer)
{
    analyzer = [analyzer copy];
    return ^(id result)
    {
        return asyncOperationWithAnalyzer(result, analyzer);
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

JFFAsyncOperation asyncOperationWithDelay(NSTimeInterval delay)
{
    JFFAsyncOperationScheduler *asyncObject = [JFFAsyncOperationScheduler new];
    asyncObject.duration = delay;
    return buildAsyncOperationWithInterface(asyncObject);
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

JFFAsyncOperation ignorePregressLoader(JFFAsyncOperation loader)
{
    loader = [loader copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback)
    {
        return loader(nil, cancelCallback, doneCallback);
    };
}

JFFAsyncOperationBinder ignorePregressBinder(JFFAsyncOperationBinder binder)
{
    binder = [binder copy];
    return ^JFFAsyncOperation(id data)
    {
        JFFAsyncOperation loader = binder(data);
        return ignorePregressLoader(loader);
    };
}
