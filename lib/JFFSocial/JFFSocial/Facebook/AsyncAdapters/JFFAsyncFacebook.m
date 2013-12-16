#import "JFFAsyncFacebook.h"

#import <FacebookSDK/FacebookSDK.h>

@interface JFFFacebookGeneralRequestLoader : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFFacebookGeneralRequestLoader
{
    FBRequestConnection *_requestConnection;
@public
    FBSession    *_facebookSession;
    NSString     *_graphPath;
    NSString     *_HTTPMethod;
    NSDictionary *_parameters;
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    
    FBRequest *fbRequest = [FBRequest requestForGraphPath:_graphPath];
    fbRequest.session    = _facebookSession;
    fbRequest.HTTPMethod = _HTTPMethod;
    [fbRequest.parameters addEntriesFromDictionary:_parameters];
    
    _requestConnection = [fbRequest startWithCompletionHandler:^(FBRequestConnection *connection,
                                                                 FBGraphObject *graphObject,
                                                                 NSError *error) {
        
        if (handler)
            handler([graphObject copy], error);
    }];
}

- (void)cancel:(BOOL)canceled
{
    [_requestConnection cancel];
}

@end

JFFAsyncOperation jffGenericFacebookGraphRequestLoader(FBSession *facebook,
                                                       NSString *graphPath,
                                                       NSString *HTTPMethod,
                                                       NSDictionary *parameters)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        JFFFacebookGeneralRequestLoader *object = [JFFFacebookGeneralRequestLoader new];
        object->_facebookSession = facebook;
        object->_graphPath  = graphPath;
        object->_HTTPMethod = HTTPMethod;
        object->_parameters = parameters;
        return object;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}

JFFAsyncOperation jffFacebookGraphRequestLoader(FBSession *facebook, NSString *graphPath)
{
    return jffGenericFacebookGraphRequestLoader(facebook, graphPath, nil, nil);
}
