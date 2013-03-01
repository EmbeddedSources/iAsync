#import "JFFAsyncFacebookLogin.h"

#import "JFFFacebookSDKErrors.h"
#import "JFFFacebookAuthorizeError.h"

#import <JFFScheduler/JFFScheduler.h>

#import <FacebookSDK/FacebookSDK.h>

#import <Accounts/Accounts.h>

@interface JFFAsyncFacebookLogin : NSObject <JFFAsyncOperationInterface>

@property (nonatomic) FBSession *facebookSession;
@property (nonatomic) NSArray *permissions;

@end

@implementation JFFAsyncFacebookLogin

#pragma mark - JFFAsyncOperationInterface

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    
    if (self.facebookSession.isOpen) {
        
        [self handleLoginWithSession:self.facebookSession
                               error:nil
                              status:self.facebookSession.state
                             handler:handler];
        return;
    }
    
    FBSessionStateHandler fbHandler = ^(FBSession *session, FBSessionState status, NSError *error) {
        
        NSError *libError = error?[JFFFacebookSDKErrors newFacebookSDKErrorsWithNativeError:error]:nil;
        
        JFFScheduler *scheduler = [JFFScheduler sharedByThreadScheduler];
        [scheduler addBlock:^(JFFCancelScheduledBlock cancel) {
            
            cancel();
            [self handleLoginWithSession:session error:libError status:status handler:handler];
        } duration:0.2];
    };
    
    [FBSession openActiveSessionWithReadPermissions:self.permissions
                                       allowLoginUI:YES
                                  completionHandler:fbHandler];
}

- (void)handleLoginWithSession:(FBSession *)session
                         error:(NSError *)error
                        status:(FBSessionState)status
                       handler:(JFFAsyncOperationInterfaceResultHandler)handler
{
    if (!error && status != FBSessionStateOpen && status != FBSessionStateOpenTokenExtended) {
        error = [JFFFacebookAuthorizeError new];
    }
    
    if (handler) {
        handler(error?nil:session, error);
    }
}

- (void)cancel:(BOOL)canceled
{
}

@end

JFFAsyncOperation jffFacebookLogin(FBSession *facebook, NSArray *permissions)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        
        JFFAsyncFacebookLogin *object = [JFFAsyncFacebookLogin new];
        
        object.facebookSession = facebook;
        object.permissions     = permissions;
        
        return object;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}

