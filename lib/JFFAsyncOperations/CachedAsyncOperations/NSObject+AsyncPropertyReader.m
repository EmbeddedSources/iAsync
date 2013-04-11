#import "NSObject+AsyncPropertyReader.h"

#import "JFFPropertyPath.h"
#import "JFFPropertyExtractor.h"
#import "JFFObjectRelatedPropertyData.h"
#import "JFFCallbacksBlocksHolder.h"
#import "JFFAsyncOperationsPredefinedBlocks.h"

#import "NSObject+PropertyExtractor.h"

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
    [delegates each:^void(id obj) {
        JFFCallbacksBlocksHolder *callback = obj;
        callback.didLoadDataBlock = nil;
        callback.onCancelBlock    = nil;
        callback.onProgressBlock  = nil;
    }];
}

static void clearDataForPropertyExtractor(JFFPropertyExtractor *propertyExtractor)
{
    clearDelegates(propertyExtractor.delegates);
    propertyExtractor.delegates      = nil;
    propertyExtractor.cancelBlock    = nil;
    propertyExtractor.didFinishBlock = nil;
    propertyExtractor.asyncLoader    = nil;
    
    [propertyExtractor clearData];
}

static JFFCancelAsyncOperation cancelBlock(JFFPropertyExtractor *propertyExtractor,
                                           JFFCallbacksBlocksHolder *callbacks)
{
    return ^void(BOOL cancelOperation) {
        JFFCancelAsyncOperation cancel = propertyExtractor.cancelBlock;
        if (!cancel)
            return;
        
        cancel = [cancel copy];
        
        if (cancelOperation) {
            cancel(YES);
            clearDataForPropertyExtractor(propertyExtractor);
        } else {
            [propertyExtractor.delegates removeObject:callbacks];
            callbacks.didLoadDataBlock = nil;
            callbacks.onProgressBlock  = nil;
            
            if (callbacks.onCancelBlock)
                callbacks.onCancelBlock(NO);
            
            callbacks.onCancelBlock = nil;
        }
    };
}

static JFFDidFinishAsyncOperationHandler doneCallbackBlock(JFFPropertyExtractor *propertyExtractor)
{
    return ^void(id result, NSError *error) {
        if (!result && !error) {
            NSLog(@"Assert propertyPath object: %@ propertyPath: %@",
                  propertyExtractor.object,
                  propertyExtractor.propertyPath);
            assert(0);//"should be result or error"
        }
        
        NSArray *copyDelegates = [propertyExtractor.delegates map:^id(id obj) {
            JFFCallbacksBlocksHolder *callback = obj;
            return [[JFFCallbacksBlocksHolder alloc] initWithOnProgressBlock:callback.onProgressBlock
                                                               onCancelBlock:callback.onCancelBlock
                                                            didLoadDataBlock:callback.didLoadDataBlock];
        }];
        
        JFFDidFinishAsyncOperationHandler finishBlock = [propertyExtractor.didFinishBlock copy];
        
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

static JFFCancelAsyncOperation performNativeLoader(JFFPropertyExtractor *propertyExtractor,
                                                   JFFCallbacksBlocksHolder *callbacks)
{
    JFFAsyncOperationProgressHandler progressCallback = ^void(id progressInfo) {
        [propertyExtractor.delegates each:^void(id obj) {
            JFFCallbacksBlocksHolder *objCallback = obj;
            if (objCallback.onProgressBlock)
                objCallback.onProgressBlock(progressInfo);
        }];
    };
    
    JFFDidFinishAsyncOperationHandler doneCallback = doneCallbackBlock(propertyExtractor);
    
    JFFCancelAsyncOperationHandler cancelCallback = ^void(BOOL canceled) {
        
        [propertyExtractor.delegates each:^void(id obj) {
            JFFCallbacksBlocksHolder *objCallback = obj;
            if (objCallback.onCancelBlock)
                objCallback.onCancelBlock(canceled);
        }];
        
        clearDataForPropertyExtractor(propertyExtractor);
    };
    
    propertyExtractor.cancelBlock = propertyExtractor.asyncLoader(progressCallback,
                                                                  cancelCallback,
                                                                  doneCallback);

    if (nil == propertyExtractor.cancelBlock)
        return JFFStubCancelAsyncOperationBlock;
    
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
                                       didFinishLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didFinishOperation
{
    NSParameterAssert(asyncOperation);
    
    asyncOperation     = [asyncOperation     copy];
    didFinishOperation = [didFinishOperation copy];
    factory            = [factory            copy];
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        JFFPropertyExtractor *propertyExtractor = factory();
        propertyExtractor.object       = self;
        propertyExtractor.propertyPath = propertyPath;
        
        id result = propertyExtractor.property;
        if (result) {
            if (doneCallback)
                doneCallback(result, nil);
            return JFFStubCancelAsyncOperationBlock;
        }
        
        propertyExtractor.asyncLoader    = asyncOperation;
        propertyExtractor.didFinishBlock = didFinishOperation;
        
        JFFCallbacksBlocksHolder *callbacks =
            [[JFFCallbacksBlocksHolder alloc] initWithOnProgressBlock:progressCallback
                                                        onCancelBlock:cancelCallback
                                                     didLoadDataBlock:doneCallback];
        
        if (nil == propertyExtractor.delegates) {
            propertyExtractor.delegates = [@[callbacks] mutableCopy];
        }
        
        if (propertyExtractor.cancelBlock != nil) {
            [propertyExtractor.delegates addObject:callbacks];
            return cancelBlock(propertyExtractor, callbacks);
        }
        
        return performNativeLoader(propertyExtractor, callbacks);
    };
}

- (JFFAsyncOperation)asyncOperationForPropertyWithPath:(JFFPropertyPath *)propertyPath
                         propertyExtractorFactoryBlock:(JFFPropertyExtractorFactoryBlock)factory
                                        asyncOperation:(JFFAsyncOperation)asyncOperation
                                didFinishLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didFinishOperation
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
                                       didFinishLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didFinishOperation
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
                                didFinishLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didFinishOperation
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
                                didFinishLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didFinishOperation
{
    NSAssert(propertyPath.name && propertyPath.key, @"propertyName argument should not be nil");
    return [self privateAsyncOperationForPropertyWithPath:propertyPath
                                           asyncOperation:asyncOperation
                                   didFinishLoadDataBlock:didFinishOperation];
}

-(JFFAsyncOperation)privateAsyncOperationMergeLoaders:(JFFAsyncOperation)asyncOperation
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

-(JFFAsyncOperation)asyncOperationMergeLoaders:(JFFAsyncOperation)asyncOperation
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
