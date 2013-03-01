#import "JFFCoreDataAsyncOperationAdapter.h"

#import "JFFCoreDataProvider.h"
#import "JFFObjectInManagedObjectContext.h"
#import "JFFNoManagedObjectError.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

@interface JFFCoreDataAsyncOperationAdapter () <JFFAsyncOperationInterface>

@property (copy, nonatomic) JFFCoreDataSyncOperation operationBlock;
@property (nonatomic) JFFCDReadWriteLock readWrite;
@property (nonatomic) NSManagedObjectContext *context;

+ (dispatch_queue_t)coreDataQueue;

@end

@implementation JFFCoreDataAsyncOperationAdapter

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
        
        NSError *error;
        id<JFFObjectInManagedObjectContext> result = operationBlock(&error);
        NSParameterAssert((result || error) && !(result && error));
        
        float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        
        if (_readWrite == JFFCDWriteLock) {
            result = [context save:&error]?result:nil;
            [[JFFCoreDataProvider sharedCoreDataProvider] saveRootContext];

            if (osVersion >= 6.0) {
                BOOL obtained = [result obtainPermanentIDsIfNeedsWithError:&error];
                result = obtained?result:nil;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            
            if (error) {
                
                handler(nil, error);
                return;
            }
            
            id resultInMainContext = [result objectInManagedObjectContext:mainContext];
            
            if (osVersion >= 6.0) {
                NSError *error;
                BOOL obtained = [resultInMainContext obtainPermanentIDsIfNeedsWithError:&error];
                if (!obtained) {
                
                    handler(nil, error);
                    return;
                }
            }
            
            //TODO try to avoid this call
            [resultInMainContext updateManagedObjectFromContext];
            handler(resultInMainContext, error);
        });
    });
}

- (void)cancel:(BOOL)canceled
{
}

+ (JFFAsyncOperation)operationWithBlock:(JFFCoreDataSyncOperationFactory)block
                              readWrite:(JFFCDReadWriteLock)readWrite
{
    NSParameterAssert(block);
    
    block = [block copy];
    
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        
        JFFCoreDataAsyncOperationAdapter *adapter = [self new];
        
        NSManagedObjectContext *context = [[JFFCoreDataProvider sharedCoreDataProvider] newPrivateQueueConcurrentContext];
        
        adapter.readWrite      = readWrite;
        adapter.context        = context;
        adapter.operationBlock = block(context);
        
        return adapter;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}

+ (JFFAsyncOperation)operationWithRootObject:(NSManagedObject *)managedObject
                                       block:(JFFCoreDataSyncOperationWithObjectFactory)block
                                   readWrite:(JFFCDReadWriteLock)readWrite
{
    block = [block copy];
    
    NSManagedObjectID *objectID = managedObject.objectID;
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (osVersion >= 6.0) {
        NSParameterAssert(objectID && ![objectID isTemporaryID]);
    }
    
    JFFCoreDataSyncOperationFactory tmpBlock = ^(NSManagedObjectContext *context) {
    
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
    
    return [self operationWithBlock:tmpBlock readWrite:readWrite];
}

@end
