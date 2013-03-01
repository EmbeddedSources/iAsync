#import "JFFAsyncFacebook.h"

#import <FacebookSDK/FacebookSDK.h>

@interface JFFFacebookGeneralRequestLoader : NSObject < JFFAsyncOperationInterface >

@property (nonatomic) FBSession    *facebookSession;
@property (nonatomic) NSString     *graphPath;
@property (nonatomic) NSString     *HTTPMethod;
@property (nonatomic) NSDictionary *parameters;

@property (nonatomic) FBRequestConnection *requestConnection;

@end

@implementation JFFFacebookGeneralRequestLoader

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    
    FBRequest *fbRequest = [FBRequest requestForGraphPath:self.graphPath];
    fbRequest.session    = self.facebookSession;
    fbRequest.HTTPMethod = self.HTTPMethod;
    [fbRequest.parameters addEntriesFromDictionary:self.parameters];
    
    self.requestConnection = [fbRequest startWithCompletionHandler:^(FBRequestConnection *connection,
                                                                     FBGraphObject *graphObject,
                                                                     NSError *error) {
        
        if (handler)
            handler([graphObject copy], error);
    }];
}

- (void)cancel:(BOOL)canceled
{
    [self.requestConnection cancel];
}

@end

JFFAsyncOperation jffGenericFacebookGraphRequestLoader(FBSession *facebook,
                                                       NSString *graphPath,
                                                       NSString *HTTPMethod,
                                                       NSDictionary *parameters)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        JFFFacebookGeneralRequestLoader *object = [JFFFacebookGeneralRequestLoader new];
        object.facebookSession = facebook;
        object.graphPath  = graphPath;
        object.HTTPMethod = HTTPMethod;
        object.parameters = parameters;
        return object;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}

JFFAsyncOperation jffFacebookGraphRequestLoader(FBSession *facebook, NSString *graphPath)
{
    return jffGenericFacebookGraphRequestLoader(facebook, graphPath, nil, nil);
}
