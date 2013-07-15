#import "JFFAsyncFacebookLogin.h"

#import "JFFFacebookSDKErrors.h"
#import "JFFFacebookAuthorizeError.h"

#import <FacebookSDK/FacebookSDK.h>

#import <Accounts/Accounts.h>

@interface JFFAsyncFacebookLogin : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncFacebookLogin
{
@public
    FBSession *_facebookSession;
    NSArray   *_permissions;
}

#pragma mark - JFFAsyncOperationInterface

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    
    NSMutableSet *requstPermissions = [[NSMutableSet alloc] initWithArray:_permissions];
    NSSet *currPermissions = [[NSSet alloc] initWithArray:_facebookSession.permissions];
    
    if (_facebookSession.isOpen) {
        
        BOOL hasAllPermissions = [requstPermissions isSubsetOfSet:currPermissions];
        
        if (hasAllPermissions) {
            
            [self handleLoginWithSession:_facebookSession
                                   error:nil
                                  status:_facebookSession.state
                                 handler:handler];
            return;
        }
    }
    
    [requstPermissions unionSet:currPermissions];
    
    //exclude publich pemissions
    {
        static NSSet *publishPermissions;
        
        //    "share_item",
        //    "photo_upload",
        //    "video_upload",
        //    "installed",
        //    "status_update",
        //    "email",
        //    "user_birthday",
        //    "create_note",
        if (!publishPermissions) {
            
            publishPermissions = [[NSSet alloc] initWithArray:@[@"publish_actions", @"publish_stream"]];
        }
        
        [requstPermissions minusSet:publishPermissions];
    }
    
    __block BOOL finished = NO;
    __weak JFFAsyncFacebookLogin *weakSelf = self;
    
    FBSessionStateHandler fbHandler = ^(FBSession *session, FBSessionState status, NSError *error) {
        
        if (finished)
            return;
        
        finished = YES;
        
        NSError *libError = error?[JFFFacebookSDKErrors newFacebookSDKErrorsWithNativeError:error]:nil;
        
        [weakSelf handleLoginWithSession:session error:libError status:status handler:handler];
    };
    
    [FBSession openActiveSessionWithReadPermissions:[requstPermissions allObjects]
                                       allowLoginUI:YES
                                  completionHandler:fbHandler];
}

- (void)handleLoginWithSession:(FBSession *)session
                         error:(NSError *)error
                        status:(FBSessionState)status
                       handler:(JFFAsyncOperationInterfaceResultHandler)handler
{
    if (!error && (!session.isOpen || !session.accessTokenData.accessToken)) {
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
        
        object->_facebookSession = facebook;
        object->_permissions     = permissions;
        
        return object;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}

