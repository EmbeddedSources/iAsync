#import "JFFCoreDataAsyncOperationAdapter.h"

#import "JFFCoreDataProvider.h"
#import "JFFObjectInManagedObjectContextProtocol.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

@interface JFFCoreDataAsyncOperationAdapter () <JFFAsyncOperationInterface>

@property (copy, nonatomic) JFFCoreDataSyncOperation operationBlock;

+ (dispatch_queue_t)coreDataQueue;

@end

@implementation JFFCoreDataAsyncOperationAdapter

+ (dispatch_queue_t)coreDataQueue
{
    static dispatch_queue_t _coreDataQueue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _coreDataQueue = dispatch_queue_create("com.jff_core_data.library", DISPATCH_QUEUE_SERIAL);
    });
    
    return _coreDataQueue;
}

#pragma mark - JFFAsyncOperationInterface

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(void (^)(id))progress
{
    handler = [handler copy];
    
    NSManagedObjectContext *mainContext = [[JFFCoreDataProvider sharedCoreDataProvider] contextForCurrentThread];
    
    dispatch_async([[self class] coreDataQueue], ^{
        
        NSManagedObjectContext *currentContext = [[JFFCoreDataProvider sharedCoreDataProvider] contextForCurrentThread];
        
        NSError *error = nil;
        id<JFFObjectInManagedObjectContextProtocol> result = self.operationBlock(currentContext, &error);
        NSParameterAssert((result || error) && !(result && error));
        
        [[JFFCoreDataProvider sharedCoreDataProvider] saveRootContext];
        
        [mainContext performBlock:^{
            
            id resultInMainContext = [result objectInManagedObjectContext:mainContext];
            if (result)
                NSParameterAssert(resultInMainContext);
            
            handler(resultInMainContext, error);
        }];
    });
}

- (void)cancel:(BOOL)canceled
{
}

+ (JFFAsyncOperation)operationWithBlock:(JFFCoreDataSyncOperation)block
{
    NSParameterAssert(block);
    
    block = [block copy];
    
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        JFFCoreDataAsyncOperationAdapter *adapter = [JFFCoreDataAsyncOperationAdapter new];
        adapter.operationBlock = block;
        return adapter;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}

@end
