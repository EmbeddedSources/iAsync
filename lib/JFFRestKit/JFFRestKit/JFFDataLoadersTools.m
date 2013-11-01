#import "JFFDataLoadersTools.h"

#import "JFFRestKitError.h"

static NSString *queueNameForFileAtPath(NSString *filePath)
{
    NSCParameterAssert(nil != filePath);
    return [@"org.jRestKit.tmp-file-download/path=" stringByAppendingString:filePath];
}

static dispatch_queue_t queueForFileAtPath(NSString *filePath)
{
    NSString *queueName = queueNameForFileAtPath(filePath);
    return dispatch_queue_get_or_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
}

static void disposeQueueForFileAtPath(NSString *filePath)
{
    NSString *queueName = queueNameForFileAtPath(filePath);
    dispatch_queue_release_by_label([queueName UTF8String]);
}

JFFAsyncOperation jTmpFileLoaderWithChunkedDataLoader(JFFAsyncOperation chunkedDataLoader)
{
    chunkedDataLoader = [chunkedDataLoader copy];
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        NSString *fileName = [[NSUUID new] UUIDString];
        NSString *filePath = [NSString cachesPathByAppendingPathComponent:fileName];
        __block NSFileHandle *handle = nil;
        __block volatile BOOL canceled = NO;
        
        //TODO work with file with dispatch_io_create
        //https://developer.apple.com/library/ios/documentation/Performance/Reference/GCD_libdispatch_Ref/Reference/reference.html#//apple_ref/c/func/dispatch_io_create
        
        void (^closeFile)(void) = ^(void) {
            
            [handle closeFile];
            handle = nil;
        };
        
        __block void (^closeAndRemoveFile)(void) = ^(void) {
            
            canceled = YES;
            
            dispatch_queue_t fileQueue = queueForFileAtPath(fileName);
            
            dispatch_barrier_async(fileQueue, ^(void) {
                
                closeFile();
                
                if (filePath)
                    [[NSFileManager defaultManager] removeItemAtPath:filePath
                                                               error:nil];
                
                disposeQueueForFileAtPath(fileName);
            });
        };
        
        progressCallback = [progressCallback copy];
        JFFAsyncOperationProgressHandler progressWrapperCallback = ^(NSData *dataChunk) {
            
            NSCParameterAssert([dataChunk isKindOfClass:[NSData class]]);
            
            dispatch_queue_t fileQueue = queueForFileAtPath(fileName);
            
            dispatch_barrier_async(fileQueue, ^(void) {
                
                NSArray *operations =
                @[
                  ^void(void) {
                      
                      if (!handle) {
                          [[NSFileManager defaultManager] createFileAtPath:filePath
                                                                  contents:nil
                                                                attributes:nil];
                          handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
                      }
                  },
                  ^void(void) {
                      
                      [handle writeData:dataChunk];
                  },
                  ];
                
                for (NSUInteger index = 0; index < [operations count] && !canceled; ++index) {
                    
                    JFFSimpleBlock operation = operations[index];
                    operation();
                };
            });
            
            if (progressCallback)
                progressCallback(dataChunk);
        };
        
        cancelCallback = [cancelCallback copy];
        JFFCancelAsyncOperationHandler cancelWrapperCallback = ^(BOOL canceled) {
            closeAndRemoveFile();
            
            if (cancelCallback)
                cancelCallback(canceled);
        };
        
        JFFDidFinishAsyncOperationHandler doneWrapperCallback = ^(id response, NSError *error) {
            
            id result = response?filePath:nil;
            
            if (response) {
                
                dispatch_queue_t writerQueue  = queueForFileAtPath(fileName);
                dispatch_barrier_sync(writerQueue, ^(void) {
                    
                    closeFile();
                    disposeQueueForFileAtPath(fileName);
                });
            }
            
            if (doneCallback) {
                if (result == nil && error == nil) {
                    error = [JFFRestKitEmptyFileResponseError new];
                }
                doneCallback(result, error);
            }
        };
        
        return chunkedDataLoader(progressWrapperCallback,
                                 cancelWrapperCallback,
                                 doneWrapperCallback);
    };
}
