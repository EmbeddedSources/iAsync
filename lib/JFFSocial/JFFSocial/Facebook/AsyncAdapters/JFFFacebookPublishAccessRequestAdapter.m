#import "JFFFacebookPublishAccessRequestAdapter.h"

#import "JFFFacebookSDKErrors.h"
#import "JFFFacebookRequestPublishingAccessError.h"

#import <FacebookSDK/FacebookSDK.h>

#import <Accounts/Accounts.h>

@interface JFFFacebookPublishAccessRequestAdapter : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFFacebookPublishAccessRequestAdapter
{
@public
    FBSession *_session;
    NSArray   *_permissions;
}

#pragma mark - JFFAsyncOperationInterface

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    
    BOOL hasAllPermissions = [_permissions all:^BOOL(NSString *permission) {
        
        return [_session.permissions containsObject:permission];
    }];
    
    if (hasAllPermissions && _session.isOpen) {
        
        [self handleLoginWithSession:_session
                               error:nil
                             handler:handler];
        return;
    }
    
    FBSessionDefaultAudience defaultAudience = FBSessionDefaultAudienceEveryone;
    
    if (_session.isOpen) {
        FBSessionRequestPermissionResultHandler fbHandler = ^(FBSession *session, NSError *error) {
            
            NSError *libError = error?[JFFFacebookSDKErrors newFacebookSDKErrorsWithNativeError:error]:nil;
            
            [self handleLoginWithSession:session
                                   error:libError
                                 handler:handler];
        };
        
        [_session requestNewPublishPermissions:_permissions
                               defaultAudience:(defaultAudience)
                             completionHandler:fbHandler];
        
        return;
    }
    
    __block BOOL finished = NO;
    __weak JFFFacebookPublishAccessRequestAdapter *weakSelf = self;
    
    FBSessionStateHandler fbHandler = ^(FBSession *session, FBSessionState status, NSError *error) {
        
        if (finished)
            return;
        
        finished = YES;
        
        NSError *libError = error?[JFFFacebookSDKErrors newFacebookSDKErrorsWithNativeError:error]:nil;
        
        [weakSelf handleLoginWithSession:session
                                   error:libError
                                 handler:handler];
    };
    
    [FBSession openActiveSessionWithPublishPermissions:_permissions
                                       defaultAudience:(defaultAudience)
                                          allowLoginUI:YES
                                     completionHandler:fbHandler];
}

- (void)handleLoginWithSession:(FBSession *)session
                         error:(NSError *)error
                       handler:(JFFAsyncOperationInterfaceResultHandler)handler
{
    if (!error && !session.isOpen) {
        error = [JFFFacebookRequestPublishingAccessError new];
    }
    if (handler) {
        handler(error?nil:session, error);
    }
}

@end

JFFAsyncOperation jffFacebookPublishAccessRequest(FBSession *session, NSArray *permissions)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        
        JFFFacebookPublishAccessRequestAdapter *object = [JFFFacebookPublishAccessRequestAdapter new];
        
        object->_session     = session;
        object->_permissions = permissions;
        
        return object;
    };
    
    JFFAsyncOperation loader = buildAsyncOperationWithAdapterFactory(factory);
    
    NSDictionary *mergeParams =
    @{
      @"method"      : @"jffFacebookPublishAccessRequest",
      @"permissions" : [[NSSet alloc] initWithArray:permissions],
      @"class"       : NSStringFromClass([JFFFacebookPublishAccessRequestAdapter class])
      };
    
    return [JFFFacebookPublishAccessRequestAdapter asyncOperationMergeLoaders:loader withArgument:mergeParams];
}
