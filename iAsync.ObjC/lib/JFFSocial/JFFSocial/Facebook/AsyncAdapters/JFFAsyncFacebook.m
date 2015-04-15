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

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    finishCallback = [finishCallback copy];
    
    FBRequest *fbRequest = [FBRequest requestForGraphPath:_graphPath];
    fbRequest.session    = _facebookSession;
    fbRequest.HTTPMethod = _HTTPMethod;
    [fbRequest.parameters addEntriesFromDictionary:_parameters];
    
    _requestConnection = [fbRequest startWithCompletionHandler:^(FBRequestConnection *connection,
                                                                 FBGraphObject *graphObject,
                                                                 NSError *error) {
        
        if (finishCallback)
            finishCallback([graphObject copy], error);
    }];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSCParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    if (task == JFFAsyncOperationHandlerTaskCancel)
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
