#import "JFFAsyncFacebookLoginWithPublishPermissions.h"

#import "JFFFacebookSDKErrors.h"
#import "JFFFacebookAuthorizeError.h"

#import <FacebookSDK/FacebookSDK.h>

@interface JFFAsyncFacebookLoginWithPublishPermissions : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncFacebookLoginWithPublishPermissions
{
@public
    FBSession *_facebookSession;
    NSArray *_permissions;
}

#pragma mark - JFFAsyncOperationInterface

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    finishCallback = [finishCallback copy];
    
    NSMutableSet *requstPermissions = [[NSMutableSet alloc] initWithArray:_permissions];
    NSSet *currPermissions = [[NSSet alloc] initWithArray:_facebookSession.permissions];
    
    if (_facebookSession.isOpen) {
        
        BOOL hasAllPermissions = [requstPermissions isSubsetOfSet:currPermissions];
        
        if (hasAllPermissions) {
            
            [self handleLoginWithSession:_facebookSession
                                   error:nil
                                  status:_facebookSession.state
                          finishCallback:finishCallback];
            return;
        }
    }
    
    __block BOOL finished = NO;
    __weak JFFAsyncFacebookLoginWithPublishPermissions *weakSelf = self;
    
    FBSessionStateHandler fbHandler = ^(FBSession *session, FBSessionState status, NSError *error) {
        
        if (finished)
            return;
        
        finished = YES;
        
        NSError *libError = error?[JFFFacebookSDKErrors newFacebookSDKErrorsWithNativeError:error]:nil;
        
        [weakSelf handleLoginWithSession:session error:libError status:status finishCallback:finishCallback];
    };
    
    [FBSession openActiveSessionWithPublishPermissions:[requstPermissions allObjects]
                                       defaultAudience:(FBSessionDefaultAudienceEveryone)
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
    if (!error && !session.isOpen) {
        error = [JFFFacebookAuthorizeError new];
    }
    
    if (finishCallback) {
        finishCallback(error?nil:session, error);
    }
}

@end

JFFAsyncOperation jffFacebookLoginWithPublishPermissions(FBSession *facebook, NSArray *permissions)
{
    JFFAsyncOperationInstanceBuilder factory = ^id <JFFAsyncOperationInterface>(void) {
        
        JFFAsyncFacebookLoginWithPublishPermissions *object = [JFFAsyncFacebookLoginWithPublishPermissions new];
        
        object->_facebookSession = facebook;
        object->_permissions     = permissions;
        
        return object;
    };
    
    JFFAsyncOperation loader = buildAsyncOperationWithAdapterFactory(factory);
    
    NSDictionary *mergeParams =
    @{
      @"method"      : @"jffFacebookLoginWithPublishPermissions",
      @"permissions" : [[NSSet alloc] initWithArray:permissions],
      @"class"       : NSStringFromClass([JFFAsyncFacebookLoginWithPublishPermissions class])
      };
    
    return [JFFAsyncFacebookLoginWithPublishPermissions asyncOperationMergeLoaders:loader withArgument:mergeParams];
}

