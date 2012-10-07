#import "JFFCoreDataOperationAsyncAdapter.h"

#import "JFFCoreDataProvider.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

@interface NSObject (JFFCoreDataAsyncOperationAdapter)

- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context;

@end

@interface JFFCoreDataOperationAsyncAdapter () <JFFAsyncOperationInterface>

@property (copy, nonatomic) JFFSyncOperation operationBlock;

+ (dispatch_queue_t)coreDataQueue;

@end

@implementation JFFCoreDataOperationAsyncAdapter

@synthesize operationBlock = _operationBlock;

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
        
        __block NSError *error = nil;
        id result = self.operationBlock(&error);
        NSParameterAssert(result);
        
        [[JFFCoreDataProvider sharedCoreDataProvider] saveMediationContext];
        
        [mainContext performBlock:^{
            
            id resultInMainContext = [result objectInManagedObjectContext:mainContext];
            NSParameterAssert(resultInMainContext);
            
            handler(resultInMainContext, error);
        }];
    });
}

- (void)cancel:(BOOL)canceled
{
}

+ (JFFAsyncOperation)operationWithBlock:(JFFSyncOperation)block
{
    NSParameterAssert(block);
    
    block = [block copy];
    
    JFFAsyncOperationInstanceBuilder builder = ^id< JFFAsyncOperationInterface >() {
        JFFCoreDataOperationAsyncAdapter *adapter = [JFFCoreDataOperationAsyncAdapter new];
        adapter.operationBlock = block;
        return adapter;
    };
    
    return buildAsyncOperationWithInterface(builder);
}

@end
