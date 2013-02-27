#import "JFFCoreDataAsyncOperation.h"

#import "JFFCoreDataProvider.h"
#import "JFFObjectInManagedObjectContext.h"
#import "JFFNoManagedObjectError.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

@interface JFFCoreDataAsyncOperation () <JFFAsyncOperationInterface>

@property (copy, nonatomic) JFFCoreDataSyncOperation operationBlock;
@property (nonatomic) JFFCDReadWriteLock readWrite;
@property (nonatomic) NSManagedObjectContext *context;

+ (dispatch_queue_t)coreDataQueue;

@end

@implementation JFFCoreDataAsyncOperation

+ (dispatch_queue_t)coreDataQueue
{
    static dispatch_queue_t _coreDataQueue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _coreDataQueue = dispatch_queue_create("com.jff_core_data.worker.library", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return _coreDataQueue;
}

#pragma mark - JFFAsyncOperationInterface

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    
    NSManagedObjectContext *mainContext = [[JFFCoreDataProvider sharedCoreDataProvider] contextForMainThread];
    
    void (*dispatchAsyncMethod)(dispatch_queue_t, dispatch_block_t) = _readWrite == JFFCDWriteLock
    ?&dispatch_barrier_async
    :&dispatch_async;
    
    NSManagedObjectContext *context = self.context;
    JFFCoreDataSyncOperation operationBlock = self.operationBlock;
    
    //TODO1 may be use the performBlock: here, test realy it concurrent on reading
    dispatchAsyncMethod([[self class] coreDataQueue], ^{
        
        NSError *error = nil;
        id<JFFObjectInManagedObjectContext> result = operationBlock(&error);
        NSParameterAssert((result || error) && !(result && error));
        
        if (_readWrite == JFFCDWriteLock) {
            result = [context save:&error]?result:nil;
            [[JFFCoreDataProvider sharedCoreDataProvider] saveRootContext];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            
            id resultInMainContext = [result objectInManagedObjectContext:mainContext];
            //TODO try to avoid this call
            [resultInMainContext updateManagedObjectFromContext];
            handler(resultInMainContext, error);
        });
    });
}

- (void)cancel:(BOOL)canceled
{
}

+ (JFFAsyncOperation)operationWithBlock2:(JFFCoreDataSyncOperationFactory)block
                               readWrite:(JFFCDReadWriteLock)readWrite
{
    NSParameterAssert(block);
    
    block = [block copy];
    
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        
        JFFCoreDataAsyncOperation *adapter = [self new];
        
        NSManagedObjectContext *context = [[JFFCoreDataProvider sharedCoreDataProvider] newPrivateQueueConcurrentContext];
        
        adapter.readWrite      = readWrite;
        adapter.context        = context;
        adapter.operationBlock = block(context);
        
        return adapter;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}

+ (JFFAsyncOperation)operationWithRootObject2:(NSManagedObject *)managedObject
                                        block:(JFFCoreDataSyncOperationWithObjectFactory)block
                                    readWrite:(JFFCDReadWriteLock)readWrite
{
    block = [block copy];
    
    JFFCoreDataSyncOperationFactory tmpBlock = ^(NSManagedObjectContext *context) {
        
        NSManagedObjectID *objectID = [managedObject objectID];
        
        return ^id<JFFObjectInManagedObjectContext>(NSError *__autoreleasing *outError) {
            
            NSError *error;
            NSManagedObject *currManagedObject = [context existingObjectWithID:objectID error:&error];
            
            [error writeErrorWithJFFLogger];
            if (!currManagedObject) {
                
                if (outError) {
                    *outError = [JFFNoManagedObjectError new];
                }
                return nil;
            }
            
            return block(context)(currManagedObject, outError);
        };
    };
    
    return [self operationWithBlock2:tmpBlock readWrite:readWrite];
}

@end
