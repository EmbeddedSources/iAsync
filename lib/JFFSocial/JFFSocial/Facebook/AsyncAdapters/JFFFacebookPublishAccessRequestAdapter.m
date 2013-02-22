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

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(void (^)(id))progress
{
    handler = [handler copy];
    
    //    if ([FBSession activeSession].isOpen) {
    
    [[FBSession activeSession] reauthorizeWithPublishPermissions:self.permissions
                                                 defaultAudience:(FBSessionDefaultAudienceFriends)
                                               completionHandler:^(FBSession *session, NSError *error) {
                                                   
                                                   NSError *libError = [JFFFacebookSDKErrors newFacebookSDKErrorsWithNativeError:error];
                                                   
                                                   [self handleLoginWithSession:[FBSession activeSession]
                                                                          error:libError
                                                                        handler:handler];
                                               }];
    
    
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
                       handler:(JFFAsyncOperationInterfaceHandler)handler
{
    if (session.state != FBSessionStateOpen && session.state != FBSessionStateOpenTokenExtended) {
        error = [JFFFacebookRequestPublishingAccessError new];
    }
    if (handler) {
        handler(error?nil:session.accessToken, error);
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
