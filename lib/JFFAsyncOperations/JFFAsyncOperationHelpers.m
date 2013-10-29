#import "JFFAsyncOperationHelpers.h"

#import "JFFAsyncOperationContinuity.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"
#import "JFFAsyncOperationBuilder.h"
#import "JFFAsyncOperationInterface.h"

JFFAsyncOperation asyncOperationWithResult(id result)
{
    NSCParameterAssert(result);
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        if (doneCallback)
            doneCallback(result, nil);
        return JFFStubCancelAsyncOperationBlock;
    };
}

JFFAsyncOperation asyncOperationWithError(NSError *error)
{
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        if (doneCallback)
            doneCallback(nil, error);
        return JFFStubCancelAsyncOperationBlock;
    };
}

JFFAsyncOperation asyncOperationWithCancelFlag(BOOL canceled)
{
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        if (cancelCallback)
            cancelCallback(canceled);
        return JFFStubCancelAsyncOperationBlock;
    };
}

JFFAsyncOperation neverFinishAsyncOperation(void)
{
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
    
        __block BOOL wasCanceled = NO;
        
        cancelCallback = [cancelCallback copy];
        
        return ^(BOOL canceled) {
        
            if (wasCanceled)
                return;
            
            wasCanceled = YES;
            if (cancelCallback)
                cancelCallback(canceled);
        };
    };
}

JFFAsyncOperation asyncOperationWithSyncOperationInCurrentQueue(JFFSyncOperation block)
{
    NSCParameterAssert(block);
    block = [block copy];
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        NSError *error;
        id result = block(&error);
        NSCAssert(((result != nil) ^ (error != nil)), @"result xor error expected");
        
        if (doneCallback)
            doneCallback(result, error);
        
        return JFFStubCancelAsyncOperationBlock;
    };
}

JFFAsyncOperation asyncOperationWithFinishCallbackBlock(JFFAsyncOperation loader,
                                                        JFFDidFinishAsyncOperationHandler finishCallbackBlock)
{
    NSCParameterAssert(loader);
    finishCallbackBlock = [finishCallbackBlock copy];
    loader              = [loader copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        doneCallback = [doneCallback copy];
        return loader(progressCallback, cancelCallback, ^void(id result, NSError *error) {
            if (finishCallbackBlock)
                finishCallbackBlock(result, error);
            if (doneCallback)
                doneCallback(result, error);
       });
    };
}

JFFAsyncOperation asyncOperationWithFinishHookBlock(JFFAsyncOperation loader,
                                                    JFFDidFinishAsyncOperationHook finishCallbackHook)
{
    NSCParameterAssert(loader            );// should not be nil"
    NSCParameterAssert(finishCallbackHook);// should not be nil"
    finishCallbackHook = [finishCallbackHook copy];
    loader             = [loader             copy];
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        doneCallback = [doneCallback copy];
        return loader(progressCallback, cancelCallback, ^void(id result, NSError *error) {
            finishCallbackHook(result, error, doneCallback);
        });
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

JFFAsyncOperation asyncOperationWithOptionalStartAndFinishBlocks(JFFAsyncOperation loader,
                                                                 JFFSimpleBlock startBlock,
                                                                 JFFDidFinishAsyncOperationHandler finishCallback)
{
    loader         = [loader         copy];
    startBlock     = [startBlock     copy];
    finishCallback = [finishCallback copy];
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        __block BOOL loading = YES;
        
        cancelCallback = [cancelCallback copy];
        JFFCancelAsyncOperationHandler wrappedCancelCallback = ^(BOOL canceled) {
            
            loading = NO;
            
            if (cancelCallback)
                cancelCallback(canceled);
        };
        
        doneCallback = [doneCallback copy];
        JFFDidFinishAsyncOperationHandler wrappedDoneCallback = ^(id result, NSError *error) {
            
            loading = NO;
            
            if (finishCallback)
                finishCallback(result, error);
            if (doneCallback)
                doneCallback(result, error);
        };
        
        JFFCancelAsyncOperation cancel = loader(progressCallback, wrappedCancelCallback, wrappedDoneCallback);
        
        if (loading) {
            
            if (startBlock)
                startBlock();
            
            return cancel;
        }
        
        return JFFStubCancelAsyncOperationBlock;
    };
}

JFFAsyncOperation asyncOperationWithStartAndDoneBlocks(JFFAsyncOperation loader,
                                                       JFFSimpleBlock startBlock,
                                                       JFFSimpleBlock doneBlock)
{
    NSCParameterAssert(loader);
    startBlock = [startBlock copy];
    doneBlock  = [doneBlock  copy];
    
    loader = [loader copy];
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        if (startBlock)
            startBlock();
        
        cancelCallback = [cancelCallback copy];
        JFFCancelAsyncOperationHandler wrappedCancelCallback = ^(BOOL canceled) {
            
            if (doneBlock)
                doneBlock();
            
            if (cancelCallback)
                cancelCallback(canceled);
        };
        
        doneCallback = [doneCallback copy];
        JFFDidFinishAsyncOperationHandler wrappedDoneCallback = ^(id result, NSError *error) {
            
            if (doneBlock)
                doneBlock();
            
            if (doneCallback)
                doneCallback(result, error);
        };
        return loader(progressCallback, wrappedCancelCallback, wrappedDoneCallback);
    };
}

JFFAsyncOperation asyncOperationWithAnalyzer(id data, JFFAnalyzer analyzer)
{
    analyzer = [analyzer copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        NSError *localError;
        id localResult = analyzer(data, &localError);
        NSCAssert(((localResult != nil) ^ (localError != nil)), @"localResult xor localError expected");
        
        if (doneCallback)
            doneCallback(localError?nil:localResult, localError);
        
        return JFFStubCancelAsyncOperationBlock;
    };
}

JFFAsyncOperationBinder asyncOperationBinderWithAnalyzer(JFFAnalyzer analyzer)
{
    analyzer = [analyzer copy];
    return ^(id result) {
        return asyncOperationWithAnalyzer(result, analyzer);
    };
}

JFFAsyncOperation asyncOperationWithChangedResult(JFFAsyncOperation loader,
                                                  JFFChangedResultBuilder resultBuilder)
{
    resultBuilder = [resultBuilder copy];
    JFFAsyncOperationBinder secondLoaderBinder = asyncOperationBinderWithAnalyzer(^id(id result,
                                                                                      NSError **error) {
        NSCAssert(result, @"result can not be nil");
        id newResult = resultBuilder?resultBuilder(result):result;
        NSCAssert(newResult, @"newResult can not be nil");
        return newResult;
    });
    
    return bindSequenceOfAsyncOperations(loader, secondLoaderBinder, nil);
}

JFFAsyncOperation asyncOperationWithChangedProgress(JFFAsyncOperation loader,
                                                    JFFChangedResultBuilder resultBuilder)
{
    if (!resultBuilder)
        return loader;
    
    loader        = [loader        copy];
    resultBuilder = [resultBuilder copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        JFFAsyncOperationProgressHandler progressCallbackWrapper = ^(id info) {
            
            if (progressCallback) {
                info = resultBuilder(info);
                progressCallback(info);
            }
        };
        
        return loader(progressCallbackWrapper, cancelCallback, doneCallback);
    };
}

JFFAsyncOperation asyncOperationResultAsProgress(JFFAsyncOperation loader)
{
    loader = [loader copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback)
    {
        progressCallback = [progressCallback copy];
        doneCallback     = [doneCallback     copy];
        JFFDidFinishAsyncOperationHandler doneCallbackWrapper = ^(id result, NSError *error) {
            if (result && progressCallback)
                progressCallback(result);
            
            if (doneCallback)
                doneCallback(result, error);
        };
        return loader(nil, cancelCallback, doneCallbackWrapper);
    };
}

JFFAsyncOperation asyncOperationWithChangedError(JFFAsyncOperation loader,
                                                 JFFChangedErrorBuilder errorBuilder)
{
    if (!errorBuilder)
        return loader;
    
    errorBuilder = [errorBuilder copy];
    JFFDidFinishAsyncOperationHook finishCallbackHook = ^(id result,
                                                          NSError *error,
                                                          JFFDidFinishAsyncOperationHandler doneCallback) {
        if (doneCallback)
            doneCallback(result, error?errorBuilder(error) : nil);
    };
    return asyncOperationWithFinishHookBlock(loader, finishCallbackHook);
}

JFFAsyncOperation asyncOperationWithResultOrError(JFFAsyncOperation loader,
                                                  id result,
                                                  NSError *error)
{
    return asyncOperationWithFinishHookBlock(loader,
                                             ^(id localResult,
                                               NSError *localError,
                                               JFFDidFinishAsyncOperationHandler doneCallback) {
        if (doneCallback)
            doneCallback(result, error);
    });
}

JFFAsyncOperation loaderWithAdditionalParalelLoaders(JFFAsyncOperation original, JFFAsyncOperation additionalLoader, ...)
{
    NSCParameterAssert(original);
    
    NSMutableArray *loaders = [[NSMutableArray alloc] initWithObjects:original, nil];
    
    va_list args;
    va_start(args, additionalLoader);
    for (JFFAsyncOperation nextLoader = additionalLoader;
         nextLoader != nil;
         nextLoader = va_arg(args, JFFAsyncOperation)) {
        
        [loaders addObject:nextLoader];
    }
    va_end(args);
    
    JFFAsyncOperation groupLoader = groupOfAsyncOperationsArray(loaders);
    
    JFFAsyncOperationBinder getResult = ^JFFAsyncOperation(NSArray *results) {
        
        return asyncOperationWithResult(results[0]);
    };
    
    return bindSequenceOfAsyncOperations(groupLoader, getResult, nil);
}

JFFAsyncOperationBinder bindSequenceOfBindersPair(JFFAsyncOperationBinder firstBinder,
                                                  JFFAsyncOperationBinder secondBinder);

//!!! not tested yet
JFFAnalyzer analyzerAsSequenceOfAnalyzers(JFFAnalyzer firstAnalyzer, ...)
{
    JFFAsyncOperationBinder firstBinder = asyncOperationBinderWithAnalyzer(firstAnalyzer);
    
    va_list args;
    va_start(args, firstAnalyzer);
    for ( JFFAnalyzer nextAnalyzer = va_arg(args, JFFAnalyzer);
         nextAnalyzer != nil;
         nextAnalyzer = va_arg(args, JFFAnalyzer)) {
        JFFAsyncOperationBinder nextBinder = asyncOperationBinderWithAnalyzer(nextAnalyzer);
        firstBinder = bindSequenceOfBindersPair(firstBinder, nextBinder);
    }
    va_end(args);
    
    return ^id(id dataToAnalyze, NSError **outError) {
        JFFAsyncOperation loader = firstBinder(dataToAnalyze);
        __block id finalResult = nil;
        //loader called immediately here
        loader(nil, nil, ^(id loaderResult, NSError *error) {
            [error setToPointer:outError];
            finalResult = loaderResult;
        });
        return finalResult;
    };
}

JFFAsyncOperation ignorePregressLoader(JFFAsyncOperation loader)
{
    loader = [loader copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        return loader(nil, cancelCallback, doneCallback);
    };
}

JFFAsyncOperationBinder ignorePregressBinder(JFFAsyncOperationBinder binder)
{
    binder = [binder copy];
    return ^JFFAsyncOperation(id data) {
        JFFAsyncOperation loader = binder(data);
        return ignorePregressLoader(loader);
    };
}
