#import "JFFDataLoadersTools.h"

#import "JFFRestKitError.h"
#import <JFFNetwork/Callbacks/JFFNetworkResponseDataCallback.h>

JFFAsyncOperation jTmpFileLoaderWithChunkedDataLoader(JFFAsyncOperation chunkedDataLoader)
{
    chunkedDataLoader = [chunkedDataLoader copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        __block NSString *filePath;
        __block NSFileHandle *handle;
        
        __block void (^closeFile)() = ^{
            [handle closeFile];
            handle = nil;
        };
        
        __block void (^closeAndRemoveFile)() = ^{
            closeFile();

            if (filePath)
                [[NSFileManager defaultManager] removeItemAtPath:filePath
                                                           error:nil];
        };
        
        progressCallback = [progressCallback copy];
        JFFAsyncOperationProgressHandler progressWrapperCallback = ^(JFFNetworkResponseDataCallback *progressInfo) {
            if (!handle) {
                filePath = [[NSUUID new] UUIDString];
                filePath = [NSString cachesPathByAppendingPathComponent:filePath];
                [[NSFileManager defaultManager] createFileAtPath:filePath
                                                        contents:nil
                                                      attributes:nil];
                handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
            }

            //STODO write in separate thread only ( dispatch_io_create_with_path )
            [handle writeData:progressInfo.dataChunk];
            
            if (progressCallback)
                progressCallback(progressInfo);
        };
        
        cancelCallback = [cancelCallback copy];
        JFFCancelAsyncOperationHandler cancelWrapperCallback = ^(BOOL canceled) {
            closeAndRemoveFile();
            
            if (cancelCallback)
                cancelCallback(canceled);
        };
        
        JFFDidFinishAsyncOperationHandler doneWrapperCallback = ^(id response, NSError *error ) {
            id result = response;

            if (response) {
                result = filePath;
                closeFile();
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
