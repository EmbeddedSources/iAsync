#import "JFFAsyncFacebookLogin.h"

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

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(void (^)(id))progress
{
    handler = [handler copy];
    
    if (self.facebookSession.isOpen) {
        [self handleLoginWithSession:self.facebookSession
                               error:nil
                              status:self.facebookSession.state
                             handler:handler];
        return;
    }
    
    //For debug
    //    ACAccountStore *accountStore = [ACAccountStore new];
    //
    //    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    //
    //    NSDictionary *options =
    //    @{ACFacebookAppIdKey : [[FBSession activeSession] appID],
    //    ACFacebookPermissionsKey: [[FBSession activeSession] permissions],
    //    ACFacebookAudienceKey : ACFacebookAudienceOnlyMe};
    //
    //    [accountStore requestAccessToAccountsWithType:accountType options:options completion:
    //     ^(BOOL granted, NSError *error)
    //     {
    //
    //     }];
    
    FBSessionStateHandler fbHandler = ^(FBSession *session, FBSessionState status, NSError *error) {
        
        JFFScheduler *scheduler = [JFFScheduler sharedByThreadScheduler];
        [scheduler addBlock:^(JFFCancelScheduledBlock cancel) {
            
            [self handleLoginWithSession:session error:error status:status handler:handler];
        } duration:0.2];
    };
    
    //[[FBSession activeSession] openWithBehavior:(FBSessionLoginBehaviorUseSystemAccountIfPresent)
    //                          completionHandler:fbHandler];
    [FBSession openActiveSessionWithReadPermissions:self.permissions
                                       allowLoginUI:YES
                                  completionHandler:fbHandler];
}

- (void)handleLoginWithSession:(FBSession *)session
                         error:(NSError *)error
                        status:(FBSessionState)status
                       handler:(JFFAsyncOperationInterfaceHandler)handler
{
    if (!error && status != FBSessionStateOpen && status != FBSessionStateOpenTokenExtended) {
        error = [JFFFacebookAuthorizeError new];
    }
    
    if (handler) {
        handler(error?nil:session.accessToken, error);
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

