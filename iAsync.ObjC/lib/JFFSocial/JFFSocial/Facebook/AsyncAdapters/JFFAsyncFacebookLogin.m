#import "JFFAsyncFacebookLogin.h"

#import "JFFFacebookSDKErrors.h"
#import "JFFFacebookAuthorizeError.h"

#import <FacebookSDK/FacebookSDK.h>

@interface JFFAsyncFacebookLogin : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncFacebookLogin
{
@public
    FBSession *_facebookSession;
    NSArray   *_permissions;
}

#pragma mark - JFFAsyncOperationInterface

- (BOOL)isValidSession:(FBSession *)session
{
    return session.isOpen && session.accessTokenData.accessToken;
}

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    finishCallback = [finishCallback copy];
    
    NSMutableSet *requestPermissions = [[NSMutableSet alloc] initWithArray:_permissions];
    NSSet *currPermissions = [[NSSet alloc] initWithArray:_facebookSession.permissions];
    
    if ([self isValidSession:_facebookSession]) {
        
        BOOL hasAllPermissions = [requestPermissions isSubsetOfSet:currPermissions];
        
        if (hasAllPermissions) {
            
            [self handleLoginWithSession:_facebookSession
                                   error:nil
                                  status:_facebookSession.state
                          finishCallback:finishCallback];
            return;
        }
    }
    
    [requestPermissions unionSet:currPermissions];
    
    //exclude publich pemissions
    {
        static NSSet *publishPermissions;
        
        if (!publishPermissions) {
            
            publishPermissions = [[NSSet alloc] initWithArray:@[@"publish_actions", @"publish_stream", @"publish_checkins"]];
        }
        
        [requestPermissions minusSet:publishPermissions];
    }
    
    __block BOOL finished = NO;
    __weak JFFAsyncFacebookLogin *weakSelf = self;
    
    FBSessionStateHandler fbHandler = ^(FBSession *session, FBSessionState status, NSError *error) {
        
        if (finished)
            return;
        
        finished = YES;
        
        NSError *libError = error?[JFFFacebookSDKErrors newFacebookSDKErrorsWithNativeError:error]:nil;
        
        [weakSelf handleLoginWithSession:session error:libError status:status finishCallback:finishCallback];
    };
    
    [FBSession openActiveSessionWithReadPermissions:[requestPermissions allObjects]
                                       allowLoginUI:YES
                                  completionHandler:fbHandler];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
}

- (void)handleLoginWithSession:(FBSession *)session
                         error:(NSError *)error
                        status:(FBSessionState)status
                finishCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
{
    if (status == FBSessionStateCreatedOpening)
        return;
    
    if (!error && ![self isValidSession:session]) {
        error = [JFFFacebookAuthorizeError new];
    }
    
    if (finishCallback) {
        finishCallback(error?nil:session, error);
    }
}

@end

JFFAsyncOperation jffFacebookLogin(FBSession *facebook, NSArray *permissions)
{
    JFFAsyncOperationInstanceBuilder factory = ^id<JFFAsyncOperationInterface>() {
        
        JFFAsyncFacebookLogin *object = [JFFAsyncFacebookLogin new];
        
        object->_facebookSession = facebook;
        object->_permissions     = permissions;
        
        return object;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}

