#import "JFFNetworkAsyncOperation.h"

#import "JNUrlConnection.h"
#import "JNConnectionsFactory.h"
#import "JFFURLConnectionParams.h"

#import "JFFNetworkResponseDataCallback.h"
#import "JFFNetworkUploadProgressCallback.h"

#import <JFFNetwork/JNUrlResponse.h>

@implementation JFFNetworkAsyncOperation

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    NSParameterAssert(finishCallback  );
    NSParameterAssert(progressCallback);
    
    {
        JNConnectionsFactory *factory =
        [[JNConnectionsFactory alloc] initWithURLConnectionParams:self.params];
        
        _connection = [factory createConnection];
    }
    
    _connection.shouldAcceptCertificateBlock = self.params.certificateCallback;
    
    __unsafe_unretained JFFNetworkAsyncOperation *unretainedSelf = self;
    id<JNUrlConnection> connection = self.connection;
    
    progressCallback = [progressCallback copy];
    _connection.didReceiveDataBlock = ^(NSData *dataChunk) {
        
        JFFNetworkResponseDataCallback *progressData = [JFFNetworkResponseDataCallback new];
        {
            progressData.dataChunk            = dataChunk;
            progressData.totalBytesCount      = [connection totalBytesCount     ];
            progressData.downloadedBytesCount = [connection downloadedBytesCount];
        }
        
        progressCallback(progressData);
    };
    
    _connection.didUploadDataBlock = ^(NSNumber *progressNum) {
        
        JFFNetworkUploadProgressCallback *uploadProgress = [JFFNetworkUploadProgressCallback new];
        uploadProgress.progress = progressNum;
        uploadProgress.params   = unretainedSelf.params;
        progressCallback(uploadProgress);
    };
    
    __block id resultHolder;
    
    JFFNetworkErrorTransformer errorTransformer = _errorTransformer;
    
    finishCallback = [finishCallback copy];
    JFFDidFinishLoadingHandler finish = [^(NSError *error) {
        
        if (error) {
            
            finishCallback(nil, errorTransformer?errorTransformer(error):error);
            return;
        }
        
        finishCallback(resultHolder, nil);
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
    [self doTask:JFFAsyncOperationHandlerTaskCancel];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSCParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    
    _connection.didReceiveDataBlock          = nil;
    _connection.didFinishLoadingBlock        = nil;
    _connection.didReceiveResponseBlock      = nil;
    _connection.didUploadDataBlock           = nil;
    _connection.shouldAcceptCertificateBlock = nil;
    
    //TODO maybe always cancel?
    if (task == JFFAsyncOperationHandlerTaskCancel) {
        [_connection cancel];
        _connection = nil;
    }
}

@end
