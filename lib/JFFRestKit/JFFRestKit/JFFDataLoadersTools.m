#import "JFFDataLoadersTools.h"

#import "JFFRestKitError.h"
#import <JFFNetwork/Callbacks/JFFNetworkResponseDataCallback.h>


static NSString* queueNameForFileAtPath( NSString* filePath )
{
    NSCParameterAssert( nil != filePath );
    return [ @"org.jRestKit.tmp-file-download/path=" stringByAppendingString: filePath ];
}

static dispatch_queue_t queueForFileAtPath( NSString* filePath )
{
    NSString* queueName = queueNameForFileAtPath( filePath );
    return dispatch_queue_get_or_create( [ queueName UTF8String ], DISPATCH_QUEUE_SERIAL );
}

static void disposeQueueForFileAtPath( NSString* filePath )
{
    NSString* queueName = queueNameForFileAtPath( filePath );
    dispatch_queue_release_by_label( [ queueName UTF8String ] );
}

JFFAsyncOperation jTmpFileLoaderWithChunkedDataLoader( JFFAsyncOperation chunkedDataLoader )
{
    chunkedDataLoader = [chunkedDataLoader copy];
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback
                                    , JFFCancelAsyncOperationHandler cancelCallback
                                    , JFFDidFinishAsyncOperationHandler doneCallback) {
        __block NSString     *fileName = nil;
        __block NSString     *filePath = nil;
        __block NSFileHandle *handle   = nil;

        
        __block void (^closeFile)() = ^{
            dispatch_queue_t writerQueue = queueForFileAtPath( fileName );
            dispatch_queue_t currentQueue = dispatch_get_current_queue();
            
            dispatch_barrier_async( writerQueue,
            ^{
                if ( filePath )
                {
                    disposeQueueForFileAtPath( fileName );
                }
                
                dispatch_async( currentQueue,
                ^{
                    [ handle closeFile ];
                    handle = nil;
                } );
            } );
        };
        
        __block void (^closeAndRemoveFile)() = ^{
            closeFile();

            if ( filePath )
            {
                [ [ NSFileManager defaultManager ] removeItemAtPath: filePath
                                                              error: nil ];
            }
        };
        
        progressCallback = [progressCallback copy];
        JFFAsyncOperationProgressHandler progressWrapperCallback = ^(JFFNetworkResponseDataCallback* progressInfo)
        {
            if ( !handle )
            {
                fileName = [ NSString createUuid ];
                filePath = [ NSString cachesPathByAppendingPathComponent: fileName ];
                [ [ NSFileManager defaultManager ] createFileAtPath: filePath
                                                           contents: nil
                                                         attributes: nil ];
                handle = [ NSFileHandle fileHandleForWritingAtPath: filePath ];
            }

            NSData* dataChunk = progressInfo.dataChunk;
            dispatch_queue_t fileQueue = queueForFileAtPath( fileName );
            dispatch_async( fileQueue,
            ^{
                [ handle writeData: dataChunk ];
            } );
            
            if (progressCallback)
            {
                progressCallback(progressInfo);
            }
        };
        
        cancelCallback = [cancelCallback copy];
        JFFCancelAsyncOperationHandler cancelWrapperCallback = ^(BOOL canceled) {
            closeAndRemoveFile();
            
            if (cancelCallback)
            {
                cancelCallback(canceled);
            }
        };
        
        JFFDidFinishAsyncOperationHandler doneWrapperCallback = ^(id response, NSError *error ) {
            id result = response;

            if (response) {
                result = filePath;
                closeFile();
            }
            
            if (doneCallback) {
                if ( result == nil && error == nil ) {
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
