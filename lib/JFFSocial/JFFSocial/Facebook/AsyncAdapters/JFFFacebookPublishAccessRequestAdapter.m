#import "JFFFacebookPublishAccessRequestAdapter.h"

#import "JFFFacebookRequestPublishingAccessError.h"

#import <JFFSocial/Facebook/Errors/SDKErrors/JFFFacebookSDKErrors.h>

#import <FacebookSDK/FacebookSDK.h>

#import <Accounts/Accounts.h>

@interface JFFFacebookPublishAccessRequestAdapter : NSObject <JFFAsyncOperationInterface>

@property (nonatomic) NSArray *permissions;

@end

@implementation JFFFacebookPublishAccessRequestAdapter

#pragma mark - JFFAsyncOperationInterface

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    
    //    if ([FBSession activeSession].isOpen) {
    //TODO pass session, do not use [FBSession activeSession]
    
    FBSessionRequestPermissionResultHandler fbHandler = ^(FBSession *session, NSError *error) {
                                                   
        NSError *libError = error?[JFFFacebookSDKErrors newFacebookSDKErrorsWithNativeError:error]:nil;
                                                   
                                                   [self handleLoginWithSession:[FBSession activeSession]
                                                                          error:libError
                                                                        handler:handler];
    };
    
    [[FBSession activeSession] requestNewPublishPermissions:self.permissions
                                            defaultAudience:(FBSessionDefaultAudienceFriends)
                                          completionHandler:fbHandler];
    
    
    //        return;
    //    }
    //
    
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
    
    // TODO: Request access for publishing separate from reading
    
    
}

- (void)handleLoginWithSession:(FBSession *)session
                         error:(NSError *)error
                       handler:(JFFAsyncOperationInterfaceResultHandler)handler
{
    if (session.state != FBSessionStateOpen && session.state != FBSessionStateOpenTokenExtended) {
        error = [JFFFacebookRequestPublishingAccessError new];
    }
    if (handler) {
        handler(error?nil:session.accessTokenData.accessToken, error);
    }
}

- (void)cancel:(BOOL)canceled
{
}

@end

JFFAsyncOperation jffFacebookPublishAccessRequest(NSArray *permissions)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        JFFFacebookPublishAccessRequestAdapter *object = [JFFFacebookPublishAccessRequestAdapter new];
        
        object.permissions = permissions;
        
        return object;
    };
    
    JFFAsyncOperation loader = buildAsyncOperationWithAdapterFactory(factory);
    
    NSDictionary *mergeParams =
    @{
      @"method"      : @"jffFacebookPublishAccessRequest",
      @"permissions" : permissions,
      @"class"       : @"JFFFacebookPublishAccessRequestAdapter"
      };
    
    return [JFFFacebookPublishAccessRequestAdapter asyncOperationMergeLoaders:loader withArgument:mergeParams];
}
