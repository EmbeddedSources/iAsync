#import "JFFAsyncOperationContinuity.h"

#import "NSError+ResultOwnerships.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"
#import "JFFAsyncOperationHandlerBlockHolder.h"

#import "JFFAsyncOpFinishedByCancellationError.h"
#import "JFFAsyncOpFinishedByUnsubscriptionError.h"

#import "JFFAsyncOperationHelpers.h"

@interface JFFWaterwallFirstObject : NSObject
@end

@implementation JFFWaterwallFirstObject

+ (instancetype)sharedWaterwallFirstObject
{
    static id instance;
    
    if (!instance) {
        
        instance = [JFFWaterwallFirstObject new];
    }
    
    return instance;
}

@end

typedef JFFAsyncOperationBinder (*MergeTwoBindersPtr)(JFFAsyncOperationBinder, JFFAsyncOperationBinder);
typedef JFFAsyncOperation (*MergeTwoLoadersPtr)(JFFAsyncOperation, JFFAsyncOperation);

static JFFAsyncOperationBinder MergeBinders(MergeTwoBindersPtr merger, NSArray *blocks)
{
    NSCParameterAssert([blocks lastObject]);
    
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
    NSCParameterAssert(firstBinder);
    
    firstBinder  = [firstBinder  copy];
    secondBinder = [secondBinder copy];
    
    if (!secondBinder)
        return firstBinder;
    
    return ^JFFAsyncOperation(id bindResult) {
        
        JFFAsyncOperation firstLoader = firstBinder(bindResult);
        NSCAssert(firstLoader, @"firstLoader should not be nil");
        return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                         JFFAsyncOperationChangeStateCallback stateCallback,
                                         JFFDidFinishAsyncOperationCallback doneCallback) {
            
            __block JFFAsyncOperationHandler handlerBlockHolder;
            
            __block JFFAsyncOperationProgressCallback    progressCallbackHolder = [progressCallback copy];
            __block JFFAsyncOperationChangeStateCallback stateCallbackHolder    = [stateCallback    copy];
            __block JFFDidFinishAsyncOperationCallback   doneCallbackHolder     = [doneCallback     copy];
            
            JFFAsyncOperationProgressCallback progressCallbackWrapper = ^(id progressInfo) {
                
                if (progressCallbackHolder)
                    progressCallbackHolder(progressInfo);
            };
            JFFAsyncOperationChangeStateCallback stateCallbackWrapper = ^(JFFAsyncOperationState state) {
                
                if (stateCallbackHolder)
                    stateCallbackHolder(state);
            };
            JFFDidFinishAsyncOperationCallback doneCallbackWrapper = ^(id result, NSError *error) {
                
                if (doneCallbackHolder) {
                    
                    doneCallbackHolder(result, error);
                    doneCallbackHolder = nil;
                }
                
                progressCallbackHolder = nil;
                stateCallbackHolder    = nil;
                handlerBlockHolder     = nil;
            };
            
            __block BOOL finished = NO;
            
            JFFDidFinishAsyncOperationCallback fistLoaderDoneCallback = ^void(id result, NSError *error) {
                
                if (error) {
                    
                    finished = YES;
                    doneCallbackWrapper(nil, error);
                } else {
                    JFFAsyncOperation secondLoader = secondBinder(result);
                    NSCAssert(secondLoader, @"secondLoader should not be nil");//result loader should not be nil
                    handlerBlockHolder = secondLoader(progressCallbackWrapper,
                                                      stateCallbackWrapper,
                                                      doneCallbackWrapper);
                }
            };
            
            JFFAsyncOperationHandler firstCancel = firstLoader(progressCallbackWrapper,
                                                               stateCallbackWrapper,
                                                               fistLoaderDoneCallback);
            
            if (finished)
                return JFFStubHandlerAsyncOperationBlock;
            
            if (!handlerBlockHolder)
                handlerBlockHolder = firstCancel;
            
            return ^(JFFAsyncOperationHandlerTask task) {
                
                JFFAsyncOperationHandler currentHandler = handlerBlockHolder;
                
                if (!currentHandler)
                    return;
                
                if (task <= JFFAsyncOperationHandlerTaskCancel) {
                    
                    handlerBlockHolder = nil;
                }
                
                if (task != JFFAsyncOperationHandlerTaskUnSubscribe) {
                    currentHandler(task);
                } else {
                    if (doneCallbackHolder) {
                        doneCallbackHolder(nil, [JFFAsyncOpFinishedByUnsubscriptionError new]);
                    }
                }
                
                if (task <= JFFAsyncOperationHandlerTaskCancel) {
                    
                    progressCallbackHolder = nil;
                    stateCallbackHolder    = nil;
                    doneCallbackHolder    = nil;
                }
            };
        };
    };
}

JFFAsyncOperation sequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                            JFFAsyncOperation secondLoader,
                                            ...)
{
    NSCParameterAssert(firstLoader);
    firstLoader = [firstLoader copy];
    JFFAsyncOperationBinder firstBlock = ^JFFAsyncOperation(id result) {
        return firstLoader;
    };
    
    va_list args;
    va_start(args, secondLoader);
    for (JFFAsyncOperation secondBlock = secondLoader;
         secondBlock != nil;
         secondBlock = va_arg(args, JFFAsyncOperation)) {
        
        secondBlock = [secondBlock copy];
        JFFAsyncOperationBinder secondBlockBinder = ^JFFAsyncOperation(id result) {
            return secondBlock;
        };
        firstBlock = bindSequenceOfBindersPair(firstBlock, secondBlockBinder);
    }
    va_end(args);
    
    return firstBlock(nil);
}

JFFAsyncOperation sequenceOfAsyncOperationsArray(NSArray *loaders)
{
    NSCParameterAssert(loaders.lastObject);
    loaders = [loaders map:^id(id object) {
        JFFAsyncOperation loader = [object copy];
        return ^JFFAsyncOperation(id result) {
            return loader;
        };
    }];
    return MergeBinders(bindSequenceOfBindersPair, loaders)(nil);
}

JFFAsyncOperation accumulateSequenceResult(NSArray *loaders, JFFSequenceResultAccumulator resultAccumulator)
{
    NSCParameterAssert([loaders count] > 0);
    
    resultAccumulator = [resultAccumulator copy];
    
    NSArray *binders = [NSArray arrayWithSize:[loaders count] producer:^id(NSInteger index) {
        
        JFFAsyncOperation loader = loaders[index];
        
        JFFAsyncOperationBinder binder = [^JFFAsyncOperation(id waterfallResult) {
            
            return asyncOperationWithFinishHookBlock(loader, ^void(id result, NSError *error, JFFDidFinishAsyncOperationCallback doneCallback) {
                
                id currWaterfallResult = [waterfallResult isKindOfClass:[JFFWaterwallFirstObject class]]
                ?nil
                :waterfallResult;
                
                id newResult = resultAccumulator(currWaterfallResult, result, error);
                error = newResult?nil:error;
                NSCAssert((newResult != nil) ^ (error != nil), nil);
                
                doneCallback(newResult, error);
            });
        } copy];
        
        return binder;
    }];
    
    JFFWaterwallFirstObject *instance = [JFFWaterwallFirstObject sharedWaterwallFirstObject];
    return bindSequenceOfAsyncOperationsArray(asyncOperationWithResult(instance), binders);
}

JFFAsyncOperation sequenceOfAsyncOperationsWithAllResults(NSArray *blocks)
{
    return accumulateSequenceResult(blocks, ^id(id waterfallResult, id loaderResult, NSError *loaderError) {
        
        waterfallResult = loaderResult
        ?waterfallResult?:@[]
        :nil;
        
        return [waterfallResult arrayByAddingObject:loaderResult];
    });
}

JFFAsyncOperation sequenceOfAsyncOperationsWithSuccessfullResults(NSArray *blocks)
{
    return accumulateSequenceResult(blocks, ^id(id waterfallResult, id loaderResult, NSError *loaderError) {
        
        waterfallResult = waterfallResult?:@[];
        
        return loaderResult
        ?[waterfallResult arrayByAddingObject:loaderResult]
        :waterfallResult;
    });
}

JFFAsyncOperationBinder binderAsSequenceOfBinders(JFFAsyncOperationBinder firstBinder, ...)
{
    va_list args;
    va_start(args, firstBinder);
    for (JFFAsyncOperationBinder secondBinder = va_arg(args, JFFAsyncOperationBinder);
         secondBinder != nil;
         secondBinder = va_arg(args, JFFAsyncOperationBinder)) {
        firstBinder = bindSequenceOfBindersPair(firstBinder, secondBinder);
    }
    va_end(args);
    
    return firstBinder;
}

JFFAsyncOperationBinder binderAsSequenceOfBindersArray(NSArray *binders)
{
    binders = [binders map:^id(id object) {
        return [object copy];
    }];
    return MergeBinders(bindSequenceOfBindersPair, binders);
}

JFFAsyncOperation bindSequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                                JFFAsyncOperationBinder secondLoaderBinder, ... )
{
    NSCParameterAssert(firstLoader);
    NSMutableArray *binders = [NSMutableArray new];
    
    firstLoader = [firstLoader copy];
    JFFAsyncOperationBinder firstBinder = ^JFFAsyncOperation(id nilResult) {
        return firstLoader;
    };
    [binders addObject:[firstBinder copy]];
    
    va_list args;
    va_start(args, secondLoaderBinder);
    for (JFFAsyncOperationBinder nextBinder = secondLoaderBinder;
         nextBinder != nil;
         nextBinder = va_arg(args, JFFAsyncOperationBinder)) {
        
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
    JFFAsyncOperationBinder firstBinder = ^JFFAsyncOperation(id nilResult) {
        return firstLoader;
    };
    [binders addObject:[firstBinder copy]];
    
    for (JFFAsyncOperation binder in loadersBinders) {
        [binders addObject:[binder copy]];
    }
    
    return binderAsSequenceOfBindersArray(binders)(nil);
}

static JFFAsyncOperationBinder bindTrySequenceOfBindersPair(JFFAsyncOperationBinder firstBinder,
                                                            JFFAsyncOperationBinder secondBinder)
{
    NSCParameterAssert(firstBinder);
    
    firstBinder  = [firstBinder  copy];
    secondBinder = [secondBinder copy];
    
    if (secondBinder == nil)
        return firstBinder;
    
    return ^JFFAsyncOperation(id binderResult) {
        
        JFFAsyncOperation firstLoader = firstBinder(binderResult);
        NSCAssert(firstLoader, @"expected loader");
        
        __block JFFAsyncOperationHandler handlerBlockHolder;
        
        return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                         JFFAsyncOperationChangeStateCallback stateCallback,
                                         JFFDidFinishAsyncOperationCallback doneCallback) {
            
            __block JFFAsyncOperationProgressCallback    progressCallbackHolder = [progressCallback copy];
            __block JFFAsyncOperationChangeStateCallback stateCallbackHolder    = [stateCallback    copy];
            __block JFFDidFinishAsyncOperationCallback   doneCallbackHolder     = [doneCallback     copy];
            
            JFFAsyncOperationProgressCallback progressCallbackWrapper = ^(id progressInfo) {
                
                if (progressCallbackHolder)
                    progressCallbackHolder(progressInfo);
            };
            JFFAsyncOperationChangeStateCallback stateCallbackWrapper = ^(JFFAsyncOperationState state) {
                
                if (stateCallbackHolder)
                    stateCallbackHolder(state);
            };
            JFFDidFinishAsyncOperationCallback doneCallbackWrapper = ^(id result, NSError *error) {
                
                if (doneCallbackHolder) {
                    
                    doneCallbackHolder(result, error);
                    doneCallbackHolder = nil;
                }
                
                progressCallbackHolder = nil;
                stateCallbackHolder    = nil;
                handlerBlockHolder     = nil;
            };
            
            JFFAsyncOperationHandler firstHandler = firstLoader(progressCallbackWrapper,
                                                                stateCallbackWrapper,
                                                                ^void(id result, NSError *error) {
                                                                   
                if (error) {
                    
                    if ([error isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]]) {
                        
                        doneCallbackWrapper(nil, error);
                        return;
                    }
                    
                    JFFAsyncOperation secondLoader = secondBinder(error);
                    handlerBlockHolder = secondLoader(progressCallbackWrapper, stateCallbackWrapper, doneCallbackWrapper);
                } else {
                    
                    doneCallbackWrapper(result, nil);
                }
            });
            
            if (!handlerBlockHolder)
                handlerBlockHolder = firstHandler;
            
            return ^(JFFAsyncOperationHandlerTask task) {
                
                if (!handlerBlockHolder)
                    return;
                
                JFFAsyncOperationHandler currentHandler = handlerBlockHolder;
                
                if (task <= JFFAsyncOperationHandlerTaskCancel)
                    handlerBlockHolder = nil;
                
                if (task != JFFAsyncOperationHandlerTaskUnSubscribe) {
                    currentHandler(task);
                } else {
                    if (doneCallbackHolder) {
                        doneCallbackHolder(nil, [JFFAsyncOpFinishedByUnsubscriptionError new]);
                    }
                }
                
                if (task <= JFFAsyncOperationHandlerTaskCancel) {
                    
                    progressCallbackHolder = nil;
                    stateCallbackHolder    = nil;
                    doneCallbackHolder     = nil;
                }
            };
        };
    };
}

JFFAsyncOperation trySequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                               JFFAsyncOperation secondLoader, ...)
{
    firstLoader = [firstLoader copy];
    JFFAsyncOperationBinder firstBlock = ^JFFAsyncOperation(id data) {
        return firstLoader;
    };
    
    va_list args;
    va_start(args, secondLoader);
    for (JFFAsyncOperation secondBlock = secondLoader;
         secondBlock != nil;
         secondBlock = va_arg(args, JFFAsyncOperation)) {
        secondBlock = [secondBlock copy];
        JFFAsyncOperationBinder secondBlockBinder = ^JFFAsyncOperation(id result) {
            return secondBlock;
        };
        firstBlock = bindTrySequenceOfBindersPair(firstBlock, secondBlockBinder);
    }
    va_end(args);
    
    return firstBlock(nil);
}

JFFAsyncOperation trySequenceOfAsyncOperationsArray(NSArray *loaders)
{
    NSCParameterAssert([loaders count] > 0);
    
    NSArray *binders = [loaders map:^id(id loader) {
        loader = [loader copy];
        return ^JFFAsyncOperation(id data) {
            return loader;
        };
    }];
    
    return MergeBinders(bindTrySequenceOfBindersPair, binders)(nil);
}

JFFAsyncOperation bindTrySequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                                   JFFAsyncOperationBinder secondLoaderBinder, ...)
{
    firstLoader = [firstLoader copy];
    JFFAsyncOperationBinder firstBlock = ^JFFAsyncOperation(id data) {
        return firstLoader;
    };
    
    va_list args;
    va_start(args, secondLoaderBinder);
    for (JFFAsyncOperationBinder secondBlockBinder = secondLoaderBinder;
         secondBlockBinder != nil;
         secondBlockBinder = va_arg(args, JFFAsyncOperationBinder)) {
        
        firstBlock = bindTrySequenceOfBindersPair(firstBlock, secondBlockBinder);
    }
    va_end(args);
    
    return firstBlock(nil);
}

JFFAsyncOperation bindTrySequenceOfAsyncOperationsArray(JFFAsyncOperation firstLoader, NSArray *loadersBinders)
{
    NSMutableArray *binders = [[NSMutableArray alloc]initWithCapacity:[loadersBinders count]];
    
    firstLoader = [firstLoader copy];
    JFFAsyncOperationBinder firstBinder = ^JFFAsyncOperation(id data) {
        return firstLoader;
    };
    [binders addObject:[firstBinder copy]];
    
    for (JFFAsyncOperation binder in loadersBinders) {
        [binders addObject:[binder copy]];
    }
    
    return MergeBinders(bindTrySequenceOfBindersPair, binders)(nil);
}

static void notifyGroupResult(JFFDidFinishAsyncOperationCallback doneCallback,
                              NSArray *complexResult,
                              NSError *error)
{
    if (!doneCallback)
        return;
    
    NSMutableArray *finalResult;
    if (!error) {
        NSArray *firstResult = complexResult[0];
        finalResult = [[NSMutableArray alloc] initWithCapacity:[firstResult count] + 1];
        [finalResult addObjectsFromArray:firstResult];
        [finalResult addObject:complexResult[1]];
    }
    doneCallback(finalResult, error);
}

static JFFAsyncOperation groupOfAsyncOperationsPair(JFFAsyncOperation firstLoader,
                                                    JFFAsyncOperation secondLoader)
{
    NSCParameterAssert(firstLoader);//do not pass nil
    
    firstLoader  = [firstLoader  copy];
    secondLoader = [secondLoader copy];
    
    if (secondLoader == nil)
        return firstLoader;
    
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        __block BOOL loaded = NO;
        __block NSError *errorHolder;
        
        NSMutableArray *complexResult = [@[[NSNull null], [NSNull null]] mutableCopy];
        
        doneCallback = [doneCallback copy];
        
        __block BOOL blockCanceledOrUnsubscribed = NO;
        __block JFFAsyncOperationHandlerTask finishTask = JFFAsyncOperationHandlerTaskUndefined;
        
        __block JFFAsyncOperationHandlerBlockHolder *handlerHolder1 = [JFFAsyncOperationHandlerBlockHolder new];
        __block JFFAsyncOperationHandlerBlockHolder *handlerHolder2 = [JFFAsyncOperationHandlerBlockHolder new];
        
        JFFDidFinishAsyncOperationCallback (^makeResultHandler)(NSUInteger) =
        ^JFFDidFinishAsyncOperationCallback(NSUInteger index) {
            
            return ^void(id result, NSError *error) {
                
                BOOL cancellation = [error isKindOfClass:[JFFAsyncOperationAbstractFinishError class]];
                
                if (cancellation) {
                    
                    if (blockCanceledOrUnsubscribed)
                        return;
                    
                    JFFAsyncOperationHandlerBlockHolder *otherHandlerHolder = (index == 0)
                    ?handlerHolder2
                    :handlerHolder1;
                    
                    blockCanceledOrUnsubscribed = cancellation;
                    
                    finishTask = ([error isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]])
                    ?JFFAsyncOperationHandlerTaskCancel
                    :JFFAsyncOperationHandlerTaskUnSubscribe;
                    [otherHandlerHolder performCancelBlockOnceWithArgument:finishTask];
                    
                    handlerHolder1 = nil;
                    handlerHolder2 = nil;
                    
                    if (doneCallback)
                        doneCallback(nil, error);
                    return;
                }
                
                if (result)
                    complexResult[index] = result;
                
                if (loaded) {
                    error = error?error:errorHolder;
                    
                    if (result)
                        [error.lazyResultOwnerships addObject:result];
                    
                    if (errorHolder && error != errorHolder && errorHolder.resultOwnerships) {
                        [error.lazyResultOwnerships addObject:errorHolder.resultOwnerships];
                        errorHolder.resultOwnerships = nil;
                    }
                    
                    handlerHolder1 = nil;
                    handlerHolder2 = nil;
                    
                    notifyGroupResult(doneCallback, complexResult, error);
                    error.resultOwnerships = nil;
                    
                    return;
                } else {
                    
                    if (index == 0)
                        handlerHolder1 = nil;
                    else
                        handlerHolder2 = nil;
                }
                loaded = YES;
                
                errorHolder = [error copy];
                errorHolder.resultOwnerships = error.resultOwnerships;
            };
        };
        
        JFFAsyncOperationHandler loaderHandler = firstLoader(progressCallback,
                                                             stateCallback,
                                                             makeResultHandler(0));
        
        if (blockCanceledOrUnsubscribed) {
            
            if (finishTask == JFFAsyncOperationHandlerTaskUnSubscribe) {
                
                secondLoader(nil, nil, nil);
            }
            return JFFStubHandlerAsyncOperationBlock;
        }
        
        handlerHolder1.loaderHandler = loaderHandler;
        
        loaderHandler = secondLoader(progressCallback,
                                     stateCallback,
                                     makeResultHandler(1));
        
        if (blockCanceledOrUnsubscribed) {
            
            return JFFStubHandlerAsyncOperationBlock;
        }
        
        handlerHolder2.loaderHandler = loaderHandler;
        
        return ^void(JFFAsyncOperationHandlerTask task) {
            
            [handlerHolder1 performHandlerWithArgument:task];
            [handlerHolder2 performHandlerWithArgument:task];
        };
    };
}

static JFFAsyncOperation resultToArrayForLoader(JFFAsyncOperation loader)
{
    return bindSequenceOfAsyncOperations(loader, ^(id result) {
        
        return asyncOperationWithResult(@[result]);
    }, nil);
}

static JFFAsyncOperation MergeGroupLoaders(MergeTwoLoadersPtr merger, NSArray *blocks)
{
    if (![blocks lastObject])
        return asyncOperationWithResult(@[]);
    
    JFFAsyncOperation firstBlock = blocks[0];
    JFFAsyncOperation arrayFirstBlock = resultToArrayForLoader(firstBlock);
    
    for (NSUInteger index = 1; index < [blocks count]; ++index) {
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
         nextBlock = va_arg(args, JFFAsyncOperation)) {
        [loaders addObject:[nextBlock copy]];
    }
    va_end(args);
    
    return groupOfAsyncOperationsArray(loaders);
}

static JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperationsPair(JFFAsyncOperation firstLoader,
                                                                    JFFAsyncOperation secondLoader)
{
    NSCParameterAssert(firstLoader);//do not pass nil
    
    firstLoader  = [firstLoader  copy];
    secondLoader = [secondLoader copy];
    
    if (secondLoader == nil) {
        return firstLoader;
    }
    
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        __block JFFAsyncOperationHandlerBlockHolder *handlerHolder1 = [JFFAsyncOperationHandlerBlockHolder new];
        __block JFFAsyncOperationHandlerBlockHolder *handlerHolder2 = [JFFAsyncOperationHandlerBlockHolder new];
        
        NSMutableArray *complexResult = [@[[NSNull null], [NSNull null]] mutableCopy];
        
        __block NSUInteger resultCount = 0;
        __block BOOL blockCanceledOrUnsubscribed = NO;
        __block JFFAsyncOperationHandlerTask finishTask = JFFAsyncOperationHandlerTaskUndefined;
        
        doneCallback = [doneCallback copy];
        JFFDidFinishAsyncOperationCallback (^makeResultHandler)(NSUInteger) =
        ^JFFDidFinishAsyncOperationCallback(NSUInteger index) {
            
            return ^void(id result, NSError *error) {
                
                if (error) {
                    
                    if (blockCanceledOrUnsubscribed)
                        return;
                    
                    JFFAsyncOperationHandlerBlockHolder *otherHandlerHolder = (index == 0)
                    ?handlerHolder2
                    :handlerHolder1;
                    
                    blockCanceledOrUnsubscribed = YES;
                    finishTask = [error isKindOfClass:[JFFAsyncOpFinishedByUnsubscriptionError class]]
                    ?JFFAsyncOperationHandlerTaskUnSubscribe
                    :JFFAsyncOperationHandlerTaskCancel;
                    [otherHandlerHolder performCancelBlockOnceWithArgument:finishTask];
                    
                    handlerHolder1 = nil;
                    handlerHolder2 = nil;
                    
                    if (doneCallback)
                        doneCallback(nil, error);
                    return;
                }
                
                complexResult[index] = result;
                resultCount += 1;
                
                if (resultCount == 2) {
                    
                    handlerHolder1 = nil;
                    handlerHolder2 = nil;
                    
                    notifyGroupResult(doneCallback, complexResult, nil);
                    return;
                }
            };
        };
        
        JFFAsyncOperationHandler loaderHandler = firstLoader(progressCallback,
                                                             stateCallback,
                                                             [makeResultHandler(0) copy]
                                                             );
        
        if (blockCanceledOrUnsubscribed) {
            
            if (finishTask == JFFAsyncOperationHandlerTaskUnSubscribe) {
                
                secondLoader(nil, nil, nil);
            }
            return JFFStubHandlerAsyncOperationBlock;
        }
        
        handlerHolder1.loaderHandler = loaderHandler;
        
        loaderHandler = secondLoader(progressCallback,
                                     stateCallback,
                                     [makeResultHandler(1) copy]
                                     );
        
        if (blockCanceledOrUnsubscribed) {
            
            return JFFStubHandlerAsyncOperationBlock;
        }
        
        handlerHolder2.loaderHandler = loaderHandler;
        
        return ^void(JFFAsyncOperationHandlerTask task) {
            
            [handlerHolder1 performHandlerWithArgument:task];
            [handlerHolder2 performHandlerWithArgument:task];
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
         nextBlock = va_arg(args, JFFAsyncOperation)) {
        
        [loaders addObject:[nextBlock copy]];
    }
    va_end(args);
    
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
    if (nil == doneCallbackHook) {
        return loader;
    }
    
    doneCallbackHook = [doneCallbackHook copy];
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        doneCallback = [doneCallback copy];
        JFFDidFinishAsyncOperationCallback wrappedDoneCallback = ^void(id result, NSError *error) {
            doneCallbackHook();
            
            if (doneCallback) {
                doneCallback(result, error);
            }
        };
        return loader(progressCallback, stateCallback, wrappedDoneCallback);
    };
}
