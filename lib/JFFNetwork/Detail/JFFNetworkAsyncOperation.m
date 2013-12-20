#import "JFFNetworkAsyncOperation.h"

#import "JNUrlConnection.h"
#import "JNConnectionsFactory.h"
#import "JFFURLConnectionParams.h"

#import "JFFNetworkResponseDataCallback.h"
#import "JFFNetworkUploadProgressCallback.h"

#import <JFFNetwork/JNUrlResponse.h>

@implementation JFFNetworkAsyncOperation

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    NSParameterAssert(handler );
    NSParameterAssert(progress);
    
    {
        JNConnectionsFactory *factory =
        [[JNConnectionsFactory alloc] initWithURLConnectionParams:self.params];
        
        _connection = [factory createConnection];
    }
    
    _connection.shouldAcceptCertificateBlock = self.params.certificateCallback;
    
    __unsafe_unretained JFFNetworkAsyncOperation *unretainedSelf = self;
    id<JNUrlConnection> connection = self.connection;

    
    progress = [progress copy];
    _connection.didReceiveDataBlock = ^(NSData *dataChunk) {
        
        JFFNetworkResponseDataCallback *progressData = [JFFNetworkResponseDataCallback new];
        {
            progressData.dataChunk            = dataChunk;

            progressData.totalBytesCount      = [connection totalBytesCount     ];
            progressData.downloadedBytesCount = [connection downloadedBytesCount];
        }
        
        progress(progressData);
    };
    
    _connection.didUploadDataBlock = ^(NSNumber *progressNum) {
        
        JFFNetworkUploadProgressCallback *uploadProgress = [JFFNetworkUploadProgressCallback new];
        uploadProgress.progress = progressNum;
        uploadProgress.params   = unretainedSelf.params;
        progress(uploadProgress);
    };
    
    __block id resultHolder;
    
    JFFNetworkErrorTransformer errorTransformer = _errorTransformer;
    
    handler = [handler copy];
    JFFDidFinishLoadingHandler finish = [^(NSError *error) {
        
        if (error) {
            
            handler(nil, errorTransformer?errorTransformer(error):error);
            return;
        }
        
        handler(resultHolder, nil);
        
    } copy];
    
    finish = [finish copy];
    _connection.didFinishLoadingBlock = finish;
    
    _connection.didReceiveResponseBlock = ^void(id<JNUrlResponse> response) {
        
        if (!unretainedSelf->_responseAnalyzer) {
            resultHolder = response;
            return;
        }
        
        NSError *error;
        resultHolder = unretainedSelf->_responseAnalyzer(response, &error);
        
        if (error) {
            [unretainedSelf forceCancel];
            finish(error);
        }
    };
    
    [_connection start];
}

- (void)forceCancel
{
    [self cancel:YES];
}

- (void)cancel:(BOOL)canceled
{
    _connection.didReceiveDataBlock          = nil;
    _connection.didFinishLoadingBlock        = nil;
    _connection.didReceiveResponseBlock      = nil;
    _connection.didUploadDataBlock           = nil;
    _connection.shouldAcceptCertificateBlock = nil;
    
    //TODO maybe always cancel?
    if (canceled) {
        [_connection cancel];
        _connection = nil;
    }
}

@end
