#import "JFFAsyncFacebook.h"

#import <FacebookSDK/FacebookSDK.h>

@interface JFFFacebookGeneralRequestLoader : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic, copy ) JFFAsyncOperationInterfaceHandler handler;
@property ( nonatomic ) FBSession* facebookSession;
@property ( nonatomic ) NSString *graphPath;
@property ( nonatomic ) NSString *HTTPMethod;
@property ( nonatomic ) NSDictionary *parameters;

@property (nonatomic) FBRequest *fbRequest;
@property (weak, nonatomic) FBRequestConnection *requestConnection;

@end

@implementation JFFFacebookGeneralRequestLoader

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(void (^)(id))progress
{
    self.handler = handler;
    
    self.fbRequest = [FBRequest requestForGraphPath:self.graphPath];
    self.fbRequest.session    = self.facebookSession;
    self.fbRequest.HTTPMethod = self.HTTPMethod;
    [self.fbRequest.parameters addEntriesFromDictionary:self.parameters];
    
    self.requestConnection = [self.fbRequest startWithCompletionHandler:^(FBRequestConnection *connection,
                                                                          FBGraphObject *graphObject,
                                                                          NSError *error) {
        
        if ( self.handler )
            self.handler([graphObject copy], error);
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
