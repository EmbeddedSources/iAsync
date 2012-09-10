#import "JFFAsyncOperationNetwork.h"

#import "JFFURLConnectionParams.h"
#import "JNConnectionsFactory.h"
#import "JNUrlConnection.h"

#import <JFFNetwork/JNUrlResponse.h>

@implementation JFFAsyncOperationNetwork

-(void)asyncOperationWithResultHandler:(void (^)(id, NSError *) )handler
                       progressHandler:(void (^)(id) )progress
{
    {
        JNConnectionsFactory* factory =
        [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: self.params ];

        self.connection = self.params.useLiveConnection
            ? [factory createFastConnection    ]
            : [factory createStandardConnection];
    }

    self.connection.shouldAcceptCertificateBlock = self.params.certificateCallback;

    __unsafe_unretained JFFAsyncOperationNetwork* unretainedSelf = self;

    progress = [progress copy];
    self.connection.didReceiveDataBlock = ^(NSData *data)
    {
        if (progress)
            progress(data);
    };

    handler = [ handler copy ];
    JFFDidFinishLoadingHandler finish = [^(NSError *error)
    {
        if (handler)
            handler(error?nil:unretainedSelf.resultContext, error);
    }copy];

    self.connection.didFinishLoadingBlock = finish;

    self.connection.didReceiveResponseBlock = ^void(id< JNUrlResponse > response)
    {
        if ( !unretainedSelf->_responseAnalyzer )
        {
            unretainedSelf.resultContext = response;
            return;
        }

        NSError *error;
        unretainedSelf.resultContext = unretainedSelf->_responseAnalyzer(response, &error);

        if (error)
        {
            finish(error);
            [unretainedSelf forceCancel];
        }
    };

    [self.connection start];
}

-(void)forceCancel
{
    [self cancel:YES];
}

-(void)cancel:( BOOL )canceled_
{
    if (canceled_)
    {
        [self.connection cancel];
        self.connection = nil;
    }
}

@end
