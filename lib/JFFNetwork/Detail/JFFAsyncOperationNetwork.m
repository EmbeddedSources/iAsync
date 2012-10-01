#import "JFFAsyncOperationNetwork.h"

#import "JFFURLConnectionParams.h"
#import "JNConnectionsFactory.h"
#import "JNUrlConnection.h"

#import <JFFNetwork/JNUrlResponse.h>

@implementation JFFAsyncOperationNetwork

- (void)asyncOperationWithResultHandler:(void(^)(id, NSError *))handler
                        progressHandler:(void(^)(id))progress
{
    NSParameterAssert(handler );
    NSParameterAssert(progress);

    {
        JNConnectionsFactory* factory =
        [[JNConnectionsFactory alloc]initWithURLConnectionParams:self.params];
        
        self.connection = self.params.useLiveConnection
        ?[factory createFastConnection    ]
        :[factory createStandardConnection];
    }
    
    self.connection.shouldAcceptCertificateBlock = self.params.certificateCallback;
    
    __unsafe_unretained JFFAsyncOperationNetwork* unretainedSelf = self;
    
    progress = [progress copy];
    self.connection.didReceiveDataBlock = ^(NSData *data) {
        progress(data);
    };
    
    __block id resultHolder;
    
    handler = [handler copy];
    JFFDidFinishLoadingHandler finish = [^(NSError *error) {
        handler(error?nil:resultHolder, error);
    }copy];
    
    self.connection.didFinishLoadingBlock = finish;

    self.connection.didReceiveResponseBlock = ^void(id< JNUrlResponse > response)
    {
        if ( !unretainedSelf->_responseAnalyzer ) {
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

    [self.connection start];
}

-(void)forceCancel
{
    [self cancel:YES];
}

- (void)cancel:(BOOL)canceled
{
    if (canceled)
    {
        [self.connection cancel];
        self.connection = nil;
    }
}

@end
