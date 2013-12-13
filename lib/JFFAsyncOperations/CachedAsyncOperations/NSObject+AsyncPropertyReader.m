#import "NSObject+AsyncPropertyReader.h"

#import "JFFPropertyPath.h"
#import "JFFPropertyExtractor.h"
#import "JFFObjectRelatedPropertyData.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"

#import "JFFAsyncOpFinishedByUnsubscriptionError.h"

#import "NSObject+PropertyExtractor.h"

@interface JFFCallbacksBlocksHolder : NSObject

@property (nonatomic, copy) JFFAsyncOperationProgressCallback onProgressBlock;
@property (nonatomic, copy) JFFAsyncOperationChangeStateCallback onChangeStateBlock;
@property (nonatomic, copy) JFFDidFinishAsyncOperationCallback didLoadDataBlock;

- (instancetype)initWithOnProgressBlock:(JFFAsyncOperationProgressCallback)onProgressBlock
                          onCancelBlock:(JFFAsyncOperationChangeStateCallback)onCancelBlock
                       didLoadDataBlock:(JFFDidFinishAsyncOperationCallback)didLoadDataBlock;

- (void)clearCallbacks;

@end

@implementation JFFCallbacksBlocksHolder

- (instancetype)initWithOnProgressBlock:(JFFAsyncOperationProgressCallback)onProgressBlock
                          onCancelBlock:(JFFAsyncOperationChangeStateCallback)onCancelBlock
                       didLoadDataBlock:(JFFDidFinishAsyncOperationCallback)didLoadDataBlock
{
    self = [super init];
    
    if (self) {
        
        _onProgressBlock    = [onProgressBlock  copy];
        _onChangeStateBlock = [onCancelBlock    copy];
        _didLoadDataBlock   = [didLoadDataBlock copy];
    }
    
    return self;
}

- (void)clearCallbacks
{
    _onProgressBlock    = nil;
    _onChangeStateBlock = nil;
    _didLoadDataBlock   = nil;
}

@end

@interface JFFCachePropertyExtractor : JFFPropertyExtractor
@end

@implementation JFFCachePropertyExtractor

- (id)property
{
    return nil;
}

- (void)setProperty:(id)propertyPath
{
}

@end

@interface NSObject (PrivateAsyncPropertyReader)

- (BOOL)hasAsyncPropertyDelegates;

@end

@interface NSDictionary (AsyncPropertyReader)
@end

@implementation NSDictionary (AsyncPropertyReader)

- (BOOL)hasAsyncPropertyDelegates
{
    __block BOOL result = NO;
    
    [self enumerateKeysAndObjectsUsingBlock:^void(id key, id value, BOOL *stop) {
        if ([value hasAsyncPropertyDelegates]) {
            *stop  = YES;
            result = YES;
        }
    }];
    
    return result;
}

@end

@interface JFFObjectRelatedPropertyData (AsyncPropertyReader)
@end

@implementation JFFObjectRelatedPropertyData (AsyncPropertyReader)

- (BOOL)hasAsyncPropertyDelegates
{
    return [self.delegates hasElements];
}

@end

static void clearDelegates(NSArray *delegates)
{
    [delegates each:^void(JFFCallbacksBlocksHolder *callback) {
        [callback clearCallbacks];
    }];
}

static void clearDataForPropertyExtractor(JFFPropertyExtractor *propertyExtractor)
{
    clearDelegates(propertyExtractor.delegates);
    propertyExtractor.delegates      = nil;
    propertyExtractor.loaderHandler  = nil;
    propertyExtractor.didFinishBlock = nil;
    propertyExtractor.asyncLoader    = nil;
    
    [propertyExtractor clearData];
}

static JFFAsyncOperationHandler cancelBlock(JFFPropertyExtractor *propertyExtractor,
                                           JFFCallbacksBlocksHolder *callbacks)
{
    return ^void(JFFAsyncOperationHandlerTask task) {
        
        JFFAsyncOperationHandler handler = propertyExtractor.loaderHandler;
        if (!handler)
            return;
        
        handler = [handler copy];
        
        switch (task) {
            case JFFAsyncOperationHandlerTaskUnsubscribe:
            {
                JFFDidFinishAsyncOperationCallback didLoadDataBlock = callbacks.didLoadDataBlock;
                
                [propertyExtractor.delegates removeObject:callbacks];
                [callbacks clearCallbacks];
                
                if (didLoadDataBlock)
                    didLoadDataBlock(nil, [JFFAsyncOpFinishedByUnsubscriptionError new]);
                break;
            }
            case JFFAsyncOperationHandlerTaskCancel:
            {
                handler(JFFAsyncOperationHandlerTaskCancel);
                clearDataForPropertyExtractor(propertyExtractor);
                break;
            }
            case JFFAsyncOperationHandlerTaskResume:
            case JFFAsyncOperationHandlerTaskSuspend:
            {
                [propertyExtractor.delegates each:^void(id obj) {
                    JFFCallbacksBlocksHolder *objCallback = obj;
                    if (objCallback.onChangeStateBlock) {
                        JFFAsyncOperationState state = (task == JFFAsyncOperationHandlerTaskResume)
                        ?JFFAsyncOperationStateResumed
                        :JFFAsyncOperationStateSuspended;
                        objCallback.onChangeStateBlock(state);
                    }
                }];
                break;
            }
            default:
            {
                NSCAssert1(NO, @"unsupported type of task: %lu", (unsigned long)task);
                break;
            }
        }
    };
}

static JFFDidFinishAsyncOperationCallback doneCallbackBlock(JFFPropertyExtractor *propertyExtractor)
{
    return ^void(id result, NSError *error) {
        if (!((result != nil) ^ (error != nil))) {
            
            NSString *errorDescription = [[NSString alloc] initWithFormat:@"Assert propertyPath object: %@ propertyPath: %@ result: %@ error: %@",
                                          propertyExtractor.object,
                                          propertyExtractor.propertyPath,
                                          result,
                                          error];
            
            NSCAssert(0, errorDescription);
        }
        
        NSArray *copyDelegates = [propertyExtractor.delegates map:^id(id obj) {
            JFFCallbacksBlocksHolder *callback = obj;
            return [[JFFCallbacksBlocksHolder alloc] initWithOnProgressBlock:callback.onProgressBlock
                                                               onCancelBlock:callback.onChangeStateBlock
                                                            didLoadDataBlock:callback.didLoadDataBlock];
        }];
        
        JFFDidFinishAsyncOperationCallback finishBlock = [propertyExtractor.didFinishBlock copy];
        
        propertyExtractor.property = result;
        
        if (finishBlock) {
            finishBlock(result, error);
            result = propertyExtractor.property;
        }
        
        clearDataForPropertyExtractor(propertyExtractor);
        
        [copyDelegates each:^void(id obj) {
            JFFCallbacksBlocksHolder *callback = obj;
            if (callback.didLoadDataBlock)
                callback.didLoadDataBlock(result, error);
        }];
        
        clearDelegates(copyDelegates);
    };
}

static JFFAsyncOperationHandler performNativeLoader(JFFPropertyExtractor *propertyExtractor,
                                                   JFFCallbacksBlocksHolder *callbacks)
{
    JFFAsyncOperationProgressCallback progressCallback = ^void(id progressInfo) {
        [propertyExtractor.delegates each:^void(id obj) {
            JFFCallbacksBlocksHolder *objCallback = obj;
            if (objCallback.onProgressBlock)
                objCallback.onProgressBlock(progressInfo);
        }];
    };
    
    JFFDidFinishAsyncOperationCallback doneCallback = doneCallbackBlock(propertyExtractor);
    
    JFFAsyncOperationChangeStateCallback stateCallback = ^void(JFFAsyncOperationState state) {
        
        [propertyExtractor.delegates each:^void(id obj) {
            JFFCallbacksBlocksHolder *objCallback = obj;
            if (objCallback.onChangeStateBlock)
                objCallback.onChangeStateBlock(state);
        }];
    };
    
    propertyExtractor.loaderHandler = propertyExtractor.asyncLoader(progressCallback,
                                                                    stateCallback,
                                                                    doneCallback);
    
    if (nil == propertyExtractor.loaderHandler)
        return JFFStubHandlerAsyncOperationBlock;
    
    return cancelBlock(propertyExtractor, callbacks);
}

@implementation NSObject (AsyncPropertyReader)

-(BOOL)isLoadingPropertyForPropertyName:(NSString *)name
{
    return [self.propertyDataByPropertyName[name] hasAsyncPropertyDelegates];
}

- (JFFAsyncOperation)privateAsyncOperationForPropertyWithPath:(JFFPropertyPath *)propertyPath
                                propertyExtractorFactoryBlock:(JFFPropertyExtractorFactoryBlock)factory
                                               asyncOperation:(JFFAsyncOperation)asyncOperation
                                       didFinishLoadDataBlock:(JFFDidFinishAsyncOperationCallback)didFinishOperation
{
    NSParameterAssert(asyncOperation);
    
    asyncOperation     = [asyncOperation     copy];
    didFinishOperation = [didFinishOperation copy];
    factory            = [factory            copy];
    
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                    JFFAsyncOperationChangeStateCallback stateCallback,
                                    JFFDidFinishAsyncOperationCallback doneCallback) {
        
        JFFPropertyExtractor *propertyExtractor = factory();
        propertyExtractor.object       = self;
        propertyExtractor.propertyPath = propertyPath;
        
        id result = propertyExtractor.property;
        
        if (result) {
            if (doneCallback)
                doneCallback(result, nil);
            return JFFStubHandlerAsyncOperationBlock;
        }
        
        propertyExtractor.asyncLoader    = asyncOperation;
        propertyExtractor.didFinishBlock = didFinishOperation;
        
        JFFCallbacksBlocksHolder *callbacks =
            [[JFFCallbacksBlocksHolder alloc] initWithOnProgressBlock:progressCallback
                                                        onCancelBlock:stateCallback
                                                     didLoadDataBlock:doneCallback];
        
        if (nil == propertyExtractor.delegates) {
            propertyExtractor.delegates = [@[callbacks] mutableCopy];
        }
        
        if (propertyExtractor.loaderHandler != nil) {
            [propertyExtractor.delegates addObject:callbacks];
            return cancelBlock(propertyExtractor, callbacks);
        }
        
        return performNativeLoader(propertyExtractor, callbacks);
    };
}

- (JFFAsyncOperation)asyncOperationForPropertyWithPath:(JFFPropertyPath *)propertyPath
                         propertyExtractorFactoryBlock:(JFFPropertyExtractorFactoryBlock)factory
                                        asyncOperation:(JFFAsyncOperation)asyncOperation
                                didFinishLoadDataBlock:(JFFDidFinishAsyncOperationCallback)didFinishOperation
{
    NSAssert(propertyPath.name && propertyPath.key, @"propertyName argument should not be nil");
    return [self privateAsyncOperationForPropertyWithPath:propertyPath
                            propertyExtractorFactoryBlock:factory
                                           asyncOperation:asyncOperation
                                   didFinishLoadDataBlock:didFinishOperation];
}

- (JFFAsyncOperation)asyncOperationForPropertyWithPath:(JFFPropertyPath *)propertyPath
                         propertyExtractorFactoryBlock:(JFFPropertyExtractorFactoryBlock)factory
                                        asyncOperation:(JFFAsyncOperation)asyncOperation
{
    return [self asyncOperationForPropertyWithPath:propertyPath
                     propertyExtractorFactoryBlock:factory
                                    asyncOperation:asyncOperation
                            didFinishLoadDataBlock:nil];
}

- (JFFAsyncOperation)privateAsyncOperationForPropertyWithPath:(JFFPropertyPath *)propertyPath
                                               asyncOperation:(JFFAsyncOperation)asyncOperation
                                       didFinishLoadDataBlock:(JFFDidFinishAsyncOperationCallback)didFinishOperation
{
    JFFPropertyExtractorFactoryBlock factory = ^JFFPropertyExtractor*(void) {
        return [JFFPropertyExtractor new];
    };
    
    return [self privateAsyncOperationForPropertyWithPath:propertyPath
                            propertyExtractorFactoryBlock:factory
                                           asyncOperation:asyncOperation
                                   didFinishLoadDataBlock:didFinishOperation];
}

- (JFFAsyncOperation)asyncOperationForPropertyWithName:(NSString *)propertyName
                                        asyncOperation:(JFFAsyncOperation)asyncOperation
{
    return [self asyncOperationForPropertyWithName:propertyName
                                    asyncOperation:asyncOperation
                            didFinishLoadDataBlock:nil];
}

- (JFFAsyncOperation)asyncOperationForPropertyWithName:(NSString *)propertyName
                                        asyncOperation:(JFFAsyncOperation)asyncOperation
                                didFinishLoadDataBlock:(JFFDidFinishAsyncOperationCallback)didFinishOperation
{
    NSParameterAssert(propertyName);
    JFFPropertyPath *propertyPath = [[JFFPropertyPath alloc] initWithName:propertyName key:nil];
    
    return [self privateAsyncOperationForPropertyWithPath:propertyPath
                                           asyncOperation:asyncOperation
                                   didFinishLoadDataBlock:didFinishOperation];
}

- (JFFAsyncOperation)asyncOperationForPropertyWithPath:(JFFPropertyPath *)propertyPath
                                        asyncOperation:(JFFAsyncOperation)asyncOperation
{
    return [self asyncOperationForPropertyWithPath:propertyPath
                                    asyncOperation:asyncOperation
                            didFinishLoadDataBlock:nil];
}

- (JFFAsyncOperation)asyncOperationForPropertyWithPath:(JFFPropertyPath *)propertyPath
                                        asyncOperation:(JFFAsyncOperation)asyncOperation
                                didFinishLoadDataBlock:(JFFDidFinishAsyncOperationCallback)didFinishOperation
{
    NSAssert(propertyPath.name && propertyPath.key, @"propertyName argument should not be nil");
    return [self privateAsyncOperationForPropertyWithPath:propertyPath
                                           asyncOperation:asyncOperation
                                   didFinishLoadDataBlock:didFinishOperation];
}

- (JFFAsyncOperation)privateAsyncOperationMergeLoaders:(JFFAsyncOperation)asyncOperation
                                          withArgument:(id< NSCopying, NSObject >)argument
{
    static NSString *const name = @".__JFF_MERGE_LOADERS_BY_ARGUMENTS__.";
    JFFPropertyPath *propertyPath = [[JFFPropertyPath alloc] initWithName:name
                                                                      key:argument];
    JFFPropertyExtractorFactoryBlock factory = ^JFFPropertyExtractor*{
        return [JFFCachePropertyExtractor new];
    };
    
    return [self asyncOperationForPropertyWithPath:propertyPath
                     propertyExtractorFactoryBlock:factory
                                    asyncOperation:asyncOperation
                            didFinishLoadDataBlock:nil];
}

- (JFFAsyncOperation)asyncOperationMergeLoaders:(JFFAsyncOperation)asyncOperation
                                   withArgument:(id< NSCopying, NSObject >)argument
{
    return [self privateAsyncOperationMergeLoaders:asyncOperation
                                      withArgument:argument];
}

+ (JFFAsyncOperation)asyncOperationMergeLoaders:(JFFAsyncOperation)asyncOperation
                                   withArgument:(id<NSCopying, NSObject>)argument
{
    return [self privateAsyncOperationMergeLoaders:asyncOperation
                                      withArgument:argument];
}

@end
