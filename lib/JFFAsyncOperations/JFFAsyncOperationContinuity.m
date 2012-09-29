#import "JFFAsyncOperationContinuity.h"

#import "JFFCancelAsyncOperationBlockHolder.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"
#import "NSError+ResultOwnerships.h"

#include <assert.h>

#import "JFFAsyncOperationHelpers.h"

typedef JFFAsyncOperationBinder (*MergeTwoBindersPtr)( JFFAsyncOperationBinder, JFFAsyncOperationBinder );
typedef JFFAsyncOperation (*MergeTwoLoadersPtr)( JFFAsyncOperation, JFFAsyncOperation );

static JFFAsyncOperationBinder MergeBinders(MergeTwoBindersPtr merger, NSArray *blocks)
{
    assert([blocks lastObject]);// should not be empty
    
    JFFAsyncOperationBinder firstBinder = blocks[0];
    
    for (NSUInteger index = 1; index < [blocks count]; ++index) {
        JFFAsyncOperationBinder secondBinder = blocks[index];
        firstBinder = merger(firstBinder, secondBinder);
    }
    
    return firstBinder;
}

JFFAsyncOperationBinder bindSequenceOfBindersPair(JFFAsyncOperationBinder firstBinder,
                                                  JFFAsyncOperationBinder secondBinder);

JFFAsyncOperationBinder bindSequenceOfBindersPair(JFFAsyncOperationBinder firstBinder,
                                                  JFFAsyncOperationBinder secondBinder)
{
    assert(firstBinder); // should not be nil;
    
    firstBinder  = [firstBinder  copy];
    secondBinder = [secondBinder copy];
    
    if (!secondBinder)
        return firstBinder;
    
    return ^JFFAsyncOperation(id bindResult)
    {
        JFFAsyncOperation firstLoader = firstBinder(bindResult);
        assert(firstLoader);//expected loader
        return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                        JFFCancelAsyncOperationHandler cancelCallback,
                                        JFFDidFinishAsyncOperationHandler doneCallback)
        {
            __block JFFCancelAsyncOperation cancelBlockHolder;
            
            progressCallback = [progressCallback copy];
            doneCallback     = [doneCallback     copy];
            
            JFFCancelAsyncOperation firstCancel = firstLoader(progressCallback,
                                                              cancelCallback,
                                                              ^void(id result, NSError *error)
            {
                if (error)
                {
                    if (doneCallback)
                        doneCallback(nil, error);
                }
                else
                {
                    JFFAsyncOperation secondLoader = secondBinder(result);
                    assert(secondLoader);//result loader should not be nil
                    cancelBlockHolder = secondLoader(progressCallback,
                                                     cancelCallback,
                                                     doneCallback);
                }
            } );
            if (!cancelBlockHolder)
                cancelBlockHolder = firstCancel;
            
            return ^(BOOL canceled)
            {
                if (!cancelBlockHolder)
                    return;
                cancelBlockHolder(canceled);
                cancelBlockHolder = nil;
            };
        };
    };
}

JFFAsyncOperation sequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                            JFFAsyncOperation secondLoader,
                                            ...)
{
    firstLoader = [firstLoader copy];
    JFFAsyncOperationBinder firstBlock = ^JFFAsyncOperation(id result)
    {
        return firstLoader;
    };
    
    va_list args;
    va_start(args, secondLoader);
    for (JFFAsyncOperation secondBlock = secondLoader;
         secondBlock != nil;
         secondBlock = va_arg(args, JFFAsyncOperation))
    {
        secondBlock = [secondBlock copy];
        JFFAsyncOperationBinder secondBlockBinder = ^JFFAsyncOperation(id result)
        {
            return secondBlock;
        };
        firstBlock = bindSequenceOfBindersPair(firstBlock, secondBlockBinder);
    }
    va_end(args);
    
    return firstBlock(nil);
}

JFFAsyncOperation sequenceOfAsyncOperationsArray(NSArray *loaders)
{
    assert(loaders.lastObject); //should not be empty
    loaders = [loaders map: ^id(id object)
    {
        JFFAsyncOperation loader = [object copy];
        return ^JFFAsyncOperation( id result_ )
        {
            return loader;
        };
    } ];
    return MergeBinders(bindSequenceOfBindersPair, loaders)(nil);
}

JFFAsyncOperationBinder binderAsSequenceOfBinders(JFFAsyncOperationBinder firstBinder, ...)
{
    va_list args;
    va_start(args, firstBinder);
    for (JFFAsyncOperationBinder secondBinder = va_arg(args, JFFAsyncOperationBinder);
         secondBinder != nil;
         secondBinder = va_arg(args, JFFAsyncOperationBinder))
    {
        firstBinder = bindSequenceOfBindersPair(firstBinder, secondBinder);
    }
    va_end(args);
    
    return firstBinder;
}

JFFAsyncOperationBinder binderAsSequenceOfBindersArray(NSArray *binders)
{
    binders = [binders map:^id(id object)
    {
        return [object copy];
    } ];
    return MergeBinders(bindSequenceOfBindersPair, binders);
}

JFFAsyncOperation bindSequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                                JFFAsyncOperationBinder secondLoaderBinder, ... )
{
    NSMutableArray *binders = [NSMutableArray new];
    
    firstLoader = [firstLoader copy];
    JFFAsyncOperationBinder firstBinder = ^JFFAsyncOperation(id nilResult)
    {
        return firstLoader;
    };
    [binders addObject:[firstBinder copy]];
    
    va_list args;
    va_start(args, secondLoaderBinder);
    for (JFFAsyncOperationBinder nextBinder = secondLoaderBinder;
         nextBinder != nil;
         nextBinder = va_arg(args, JFFAsyncOperationBinder))
    {
        [binders addObject:[nextBinder copy]];
    }
    va_end(args);
    
    return binderAsSequenceOfBindersArray(binders)(nil);
}

JFFAsyncOperation bindSequenceOfAsyncOperationsArray(JFFAsyncOperation firstLoader,
                                                     NSArray *loadersBinders)
{
    NSUInteger size = [loadersBinders count] + 1;
    NSMutableArray *binders = [[NSMutableArray alloc]initWithCapacity:size];
    
    firstLoader = [firstLoader copy];
    JFFAsyncOperationBinder firstBinder = ^JFFAsyncOperation(id nilResult)
    {
        return firstLoader;
    };
    [binders addObject:[firstBinder copy]];
    
    for (JFFAsyncOperation binder in loadersBinders)
    {
        [binders addObject:[binder copy]];
    }
    
    return binderAsSequenceOfBindersArray(binders)(nil);
}

static JFFAsyncOperationBinder bindTrySequenceOfBindersPair(JFFAsyncOperationBinder firstBinder,
                                                            JFFAsyncOperationBinder secondBinder)
{
    assert(firstBinder); // firstLoader_ should not be nil
    
    firstBinder  = [firstBinder  copy];
    secondBinder = [secondBinder copy];
    
    if (secondBinder == nil)
        return firstBinder;
    
    return ^JFFAsyncOperation(id data)
    {
        JFFAsyncOperation firstLoader = firstBinder(data);
        
        return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                        JFFCancelAsyncOperationHandler cancelCallback,
                                        JFFDidFinishAsyncOperationHandler doneCallback)
        {
            __block JFFCancelAsyncOperation cancelBlockHolder;
            
            doneCallback = [doneCallback copy];
            
            JFFCancelAsyncOperation firstCancel = firstLoader(progressCallback,
                                                              cancelCallback,
                                                              ^void(id result, NSError *error)
            {
                if (error)
                {
                    JFFAsyncOperation secondLoader = secondBinder(error);
                    cancelBlockHolder = secondLoader(progressCallback, cancelCallback, doneCallback);
                }
                else
                {
                    if (doneCallback)
                        doneCallback(result, nil);
                }
            } );
            if (!cancelBlockHolder)
                cancelBlockHolder = firstCancel;
            
            return ^(BOOL canceled)
            {
                if (!cancelBlockHolder)
                    return;
                cancelBlockHolder(canceled);
                cancelBlockHolder = nil;
            };
        };
    };
}

JFFAsyncOperation trySequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                               JFFAsyncOperation secondLoader, ...)
{
    firstLoader = [firstLoader copy];
    JFFAsyncOperationBinder firstBlock = ^JFFAsyncOperation(id data)
    {
        return firstLoader;
    };
    
    va_list args;
    va_start(args, secondLoader);
    for ( JFFAsyncOperation secondBlock = secondLoader;
         secondBlock != nil;
         secondBlock = va_arg(args, JFFAsyncOperation) )
    {
        secondBlock = [secondBlock copy];
        JFFAsyncOperationBinder secondBlockBinder = ^JFFAsyncOperation(id result)
        {
            return secondBlock;
        };
        firstBlock = bindTrySequenceOfBindersPair(firstBlock, secondBlockBinder);
    }
    va_end(args);
    
    return firstBlock(nil);
}

JFFAsyncOperation trySequenceOfAsyncOperationsArray(NSArray *loaders)
{
    assert([loaders hasElements]);
    
    NSArray *binders = [loaders map:^id(id loader) {
        loader = [loader copy];
        return ^JFFAsyncOperation(id data) {
            return loader;
        };
    } ];
    
    return MergeBinders(bindTrySequenceOfBindersPair, binders)(nil);
}

JFFAsyncOperation bindTrySequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                                   JFFAsyncOperationBinder secondLoaderBinder, ...)
{
    firstLoader = [firstLoader copy];
    JFFAsyncOperationBinder firstBlock = ^JFFAsyncOperation(id data)
    {
        return firstLoader;
    };
    
    va_list args;
    va_start(args, secondLoaderBinder);
    for ( JFFAsyncOperationBinder secondBlockBinder = secondLoaderBinder;
         secondBlockBinder != nil;
         secondBlockBinder = va_arg(args, JFFAsyncOperationBinder))
    {
        firstBlock = bindTrySequenceOfBindersPair(firstBlock, secondBlockBinder);
    }
    va_end(args);
    
    return firstBlock(nil);
}

JFFAsyncOperation bindTrySequenceOfAsyncOperationsArray(JFFAsyncOperation firstLoader, NSArray *loadersBinders)
{
    NSMutableArray *binders = [[NSMutableArray alloc]initWithCapacity:[loadersBinders count]];
    
    firstLoader = [firstLoader copy];
    JFFAsyncOperationBinder firstBinder = ^JFFAsyncOperation(id data)
    {
        return firstLoader;
    };
    [binders addObject:[firstBinder copy]];
    
    for (JFFAsyncOperation binder in loadersBinders)
    {
        [binders addObject:[binder copy]];
    }
    
    return MergeBinders(bindTrySequenceOfBindersPair, binders)(nil);
}

static void notifyGroupResult(JFFDidFinishAsyncOperationHandler doneCallback,
                              NSArray *complexResult,
                              NSError *error)
{
    if (!doneCallback)
        return;
    
    NSMutableArray *finalResult;
    if (!error)
    {
        NSArray *firstResult = complexResult[0];
        finalResult = [[NSMutableArray alloc]initWithCapacity:[firstResult count] + 1];
        [finalResult addObjectsFromArray:firstResult];
        [finalResult addObject:complexResult[1]];
    }
    doneCallback(finalResult, error);
}

static JFFAsyncOperation groupOfAsyncOperationsPair(JFFAsyncOperation firstLoader,
                                                    JFFAsyncOperation secondLoader)
{
    assert(firstLoader);//do not pass nil
    
    firstLoader  = [firstLoader  copy];
    secondLoader = [secondLoader copy];
    
    if (secondLoader == nil)
        return firstLoader;
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback)
    {
        __block BOOL loaded = NO;
        __block NSError *errorHolder;
        
        NSMutableArray *complexResult = [@[[NSNull null], [NSNull null]] mutableCopy];
        
        doneCallback = [doneCallback copy];
        
        JFFDidFinishAsyncOperationHandler (^makeResultHandler)(NSUInteger) =
            ^JFFDidFinishAsyncOperationHandler(NSUInteger index)
        {
            return ^void(id result, NSError *error)
            {
                if (result)
                    complexResult[index] = result;
                
                if (loaded)
                {
                    error = error?error:errorHolder;
                    
                    if (result)
                        [error.lazyResultOwnerships addObject:result];
                    
                    if (errorHolder && error != errorHolder && errorHolder.resultOwnerships)
                    {
                        [error.lazyResultOwnerships addObject:errorHolder.resultOwnerships];
                        errorHolder.resultOwnerships = nil;
                    }
                    
                    notifyGroupResult(doneCallback, complexResult, error);
                    error.resultOwnerships = nil;
                    
                    return;
                }
                loaded = YES;
                
                errorHolder = [error copy];
                errorHolder.resultOwnerships = error.resultOwnerships;
            };
        };
        
        __block BOOL blockCanceled = NO;
        
        cancelCallback = [cancelCallback copy];
        JFFCancelAsyncOperationHandler (^makeCancelHandler)(JFFCancelAsyncOperationBlockHolder *) =
            ^(JFFCancelAsyncOperationBlockHolder *cancelHolder)
        {
            return ^void(BOOL canceled)
            {
                if (!blockCanceled)
                {
                    blockCanceled = YES;
                    cancelHolder.onceCancelBlock(canceled);
                    if (cancelCallback)
                        cancelCallback(canceled);
                }
            };
        };
        
        JFFDidFinishAsyncOperationHandler (^makeFinishHandler)(JFFCancelAsyncOperationBlockHolder*, NSUInteger) =
            ^JFFDidFinishAsyncOperationHandler(JFFCancelAsyncOperationBlockHolder *cancelHolder,
                                               NSUInteger index)
        {
            JFFDidFinishAsyncOperationHandler handler = makeResultHandler(index);
            return ^void(id result, NSError *error )
            {
                cancelHolder.cancelBlock = nil;
                handler(result, error );
            };
        };

        JFFCancelAsyncOperationBlockHolder *cancelHolder1 = [JFFCancelAsyncOperationBlockHolder new];
        JFFCancelAsyncOperationBlockHolder *cancelHolder2 = [JFFCancelAsyncOperationBlockHolder new];
        
        cancelHolder1.cancelBlock = firstLoader(progressCallback,
                                                makeCancelHandler(cancelHolder2),
                                                makeFinishHandler(cancelHolder1, 0));
        cancelHolder2.cancelBlock = secondLoader(progressCallback,
                                                 makeCancelHandler(cancelHolder1),
                                                 makeFinishHandler(cancelHolder2, 1));
        
        return ^void(BOOL cancel)
        {
            if (!blockCanceled)
            {
                blockCanceled = YES;
                cancelHolder1.onceCancelBlock(cancel);
                cancelHolder2.onceCancelBlock(cancel);
                if (cancelCallback)
                    cancelCallback(cancel);
            }
        };
    };
}

static JFFAsyncOperation resultToArrayForLoader(JFFAsyncOperation loader)
{
    JFFAnalyzer analyzer = ^(id result, NSError **error)
    {
        return @[result];
    };
    JFFAsyncOperationBinder secondLoaderBinder = asyncOperationBinderWithAnalyzer(analyzer);
    return bindSequenceOfAsyncOperations(loader, secondLoaderBinder, nil);
}

static JFFAsyncOperation MergeGroupLoaders(MergeTwoLoadersPtr merger, NSArray *blocks)
{
    if (![blocks lastObject])
        return asyncOperationWithResult(@[]);
    
    JFFAsyncOperation firstBlock = blocks[0];
    JFFAsyncOperation arrayFirstBlock = resultToArrayForLoader(firstBlock);
    
    for (NSUInteger index = 1; index < [blocks count]; ++index)
    {
        arrayFirstBlock = merger(arrayFirstBlock, blocks[index]);
    }
    
    return arrayFirstBlock;
}

JFFAsyncOperation groupOfAsyncOperationsArray(NSArray *blocks)
{
    return MergeGroupLoaders(groupOfAsyncOperationsPair, blocks);
}

JFFAsyncOperation groupOfAsyncOperations(JFFAsyncOperation firstLoader, ...)
{
    NSMutableArray *loaders = [NSMutableArray new];
    
    va_list args;
    va_start(args, firstLoader);
    for (JFFAsyncOperation nextBlock = firstLoader;
         nextBlock != nil;
         nextBlock = va_arg(args, JFFAsyncOperation))
    {
        [loaders addObject:[nextBlock copy]];
    }
    va_end(args);
    
    return groupOfAsyncOperationsArray(loaders);
}

static JFFDidFinishAsyncOperationHandler cancelSafeResultBlock(JFFDidFinishAsyncOperationHandler resultBlock,
                                                               JFFCancelAsyncOperationBlockHolder *cancelHolder)
{
    resultBlock = [resultBlock copy];
    return ^void(id result, NSError *error)
    {
        cancelHolder.cancelBlock = nil;
        resultBlock(result, error);
    };
}

static JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperationsPair(JFFAsyncOperation firstLoader,
                                                                    JFFAsyncOperation secondLoader)
{
    assert(firstLoader);//do not pass nil
    
    firstLoader  = [firstLoader  copy];
    secondLoader = [secondLoader copy];
    
    if (secondLoader == nil)
        return firstLoader;
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback)
    {
        __block BOOL loaded = NO;
        
        JFFCancelAsyncOperationBlockHolder *cancelHolder1 = [JFFCancelAsyncOperationBlockHolder new];
        JFFCancelAsyncOperationBlockHolder *cancelHolder2 = [JFFCancelAsyncOperationBlockHolder new];
        
        cancelCallback = [cancelCallback copy];
        __block JFFCancelAsyncOperationHandler cancelCallbackHolder = [^(BOOL canceled)
        {
            if (cancelCallback)
                cancelCallback(canceled);
        }copy];// "cancelCallbackHolder" used as flag for done
        
        NSMutableArray *complexResult = [@[[NSNull null], [NSNull null]] mutableCopy];
        
        doneCallback = [doneCallback copy];
        JFFDidFinishAsyncOperationHandler (^makeResultHandler)(NSUInteger) =
            ^JFFDidFinishAsyncOperationHandler(NSUInteger index)
        {
            return ^void(id result, NSError *error)
            {
                if (result)
                    complexResult[index] = result;
                BOOL firstError = error && cancelCallbackHolder;
                if (loaded || firstError)
                {
                    cancelCallbackHolder = nil;
                    
                    if (firstError)
                    {
                        cancelHolder1.onceCancelBlock(YES);
                        cancelHolder2.onceCancelBlock(YES);
                    }
                    
                    notifyGroupResult(doneCallback, complexResult, error);
                    return;
                }
                loaded = YES;
            };
        };
        
        JFFCancelAsyncOperationHandler (^makeCancelCallback)(JFFCancelAsyncOperationBlockHolder *) =
        ^(JFFCancelAsyncOperationBlockHolder *cancelHolder)
        {
            return ^void(BOOL canceled)
            {
                if (cancelCallbackHolder)
                {
                    cancelHolder.onceCancelBlock(canceled);
                    if (cancelCallbackHolder)
                    {
                        cancelCallbackHolder(canceled);
                        cancelCallbackHolder = nil;
                    }
                }
            };
        };
        
        JFFCancelAsyncOperation cancel1 = firstLoader(progressCallback,
                                                      makeCancelCallback(cancelHolder2),
                                                      cancelSafeResultBlock(makeResultHandler(0),
                                                                            cancelHolder1));
        
        cancelHolder1.cancelBlock = !cancelCallbackHolder?JFFStubCancelAsyncOperationBlock:cancel1;
        
        JFFCancelAsyncOperation cancel2 = cancelCallbackHolder == nil
            ? JFFStubCancelAsyncOperationBlock
            : secondLoader(progressCallback,
                           makeCancelCallback(cancelHolder1),
                           cancelSafeResultBlock(makeResultHandler(1),
                                                 cancelHolder2));
        
        cancelHolder2.cancelBlock = !cancelCallbackHolder?JFFStubCancelAsyncOperationBlock:cancel2;
        
        return ^void(BOOL cancel)
        {
            if (cancelCallbackHolder)
            {
                JFFCancelAsyncOperationHandler tmpCancelCallback = [cancelCallbackHolder copy];
                cancelCallbackHolder = nil;
                
                cancelHolder1.onceCancelBlock(cancel);
                cancelHolder2.onceCancelBlock(cancel);
                
                tmpCancelCallback(cancel);
            }
        };
    };
}

JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperations(JFFAsyncOperation firstLoader,
                                                         ...)
{
    NSMutableArray *loaders = [NSMutableArray new];
    
    va_list args;
    va_start(args, firstLoader);
    for (JFFAsyncOperation nextBlock = firstLoader;
         nextBlock != nil;
         nextBlock = va_arg(args, JFFAsyncOperation))
    {
        [loaders addObject:[nextBlock copy]];
    }
    va_end( args );
    
    return failOnFirstErrorGroupOfAsyncOperationsArray(loaders);
}

JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperationsArray(NSArray *blocks)
{
    return MergeGroupLoaders(failOnFirstErrorGroupOfAsyncOperationsPair, blocks);
}

JFFAsyncOperation asyncOperationWithDoneBlock(JFFAsyncOperation loader,
                                              JFFSimpleBlock doneCallbackHook)
{
    loader = [loader copy];
    if (nil == doneCallbackHook)
        return loader;
    
    doneCallbackHook = [doneCallbackHook copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback)
    {
        cancelCallback = [cancelCallback copy];
        JFFCancelAsyncOperationHandler wrappedCancelCallback = ^void(BOOL canceled)
        {
            doneCallbackHook();
            
            if (cancelCallback)
                cancelCallback(canceled);
        };
        
        doneCallback = [doneCallback copy];
        JFFDidFinishAsyncOperationHandler wrappedDoneCallback = ^void(id result, NSError *error)
        {
            doneCallbackHook();
            
            if (doneCallback)
                doneCallback(result, error);
        };
        return loader(progressCallback, wrappedCancelCallback, wrappedDoneCallback);
    };
}

JFFAsyncOperation repeatAsyncOperation(JFFAsyncOperation nativeLoader,
                                       JFFResultPredicateBlock continuePredicate,
                                       NSTimeInterval delay,
                                       NSInteger maxRepeatCount)
{
    assert(nativeLoader);// can not be nil
    assert(continuePredicate   );// can not be nil
    
    nativeLoader      = [nativeLoader      copy];
    continuePredicate = [continuePredicate copy];
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback)
    {
        progressCallback = [progressCallback copy];
        cancelCallback   = [cancelCallback   copy];
        doneCallback     = [doneCallback     copy];
        
        __block JFFCancelAsyncOperation cancelBlockHolder;
        
        __block JFFDidFinishAsyncOperationHook finishHookHolder;
        
        __block NSInteger currentLeftCount = maxRepeatCount;
        
        JFFDidFinishAsyncOperationHook finishCallbackHook = ^(id result,
                                                              NSError *error,
                                                              JFFDidFinishAsyncOperationHandler doneCallback)
        {
            if (!continuePredicate(result, error) || currentLeftCount == 0)
            {
                finishHookHolder = nil;
                if (doneCallback)
                    doneCallback(result, error);
            }
            else
            {
                currentLeftCount = currentLeftCount > 0
                ?currentLeftCount - 1
                :currentLeftCount;

                JFFAsyncOperation loader = asyncOperationWithFinishHookBlock(nativeLoader,
                                                                             finishHookHolder);
                loader = asyncOperationAfterDelay(delay, loader);
                
                cancelBlockHolder = loader(progressCallback, cancelCallback, doneCallback);
            }
        };
        
        finishHookHolder = [finishCallbackHook copy];
        
        JFFAsyncOperation loader = asyncOperationWithFinishHookBlock(nativeLoader,
                                                                     finishHookHolder);
        
        cancelBlockHolder = loader(progressCallback, cancelCallback, doneCallback);
        
        return ^(BOOL canceled)
        {
            finishHookHolder = nil;
            
            if (!cancelBlockHolder)
                return;
            cancelBlockHolder(canceled);
            cancelBlockHolder = nil;
        };
    };
}

JFFAsyncOperation asyncOperationAfterDelay(NSTimeInterval delay,
                                           JFFAsyncOperation loader)
{
    return sequenceOfAsyncOperations(asyncOperationWithDelay(delay),
                                     loader,
                                     nil );
}
