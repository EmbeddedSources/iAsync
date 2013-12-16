#import "JFFSocialFacebook.h"

#import "JFFAsyncFacebook.h"
#import "JFFAsyncFacebookLogin.h"
#import "JFFAsyncFacebookLogout.h"
#import "JFFAsyncFacebookDialog.h"
#import "JFFAsyncFacebookLoginWithPublishPermissions.h"

#import "JFFSocialFacebookUser+Parser.h"

#import "JFFFacebookPublishAccessRequestAdapter.h"

#import <FacebookSDK/FacebookSDK.h>

@implementation JFFSocialFacebook

+ (NSArray *)authPermissions
{
    NSArray *result = @[@"email", @"user_birthday"];
    
    return result;
}

+ (FBSession *)facebookSession
{
    FBSession *facebookSession = [FBSession activeSession];
    
    if (!facebookSession || !facebookSession.isOpen) {
        facebookSession = [[FBSession alloc] initWithPermissions:[self authPermissions]];
        [FBSession setActiveSession:facebookSession];
    }
    return facebookSession;
}

+ (void)setFacebookSession:(FBSession *)facebookSession
{
    [FBSession setActiveSession:facebookSession];
}

+ (BOOL)isActiveFacebookSession
{
    return [[self facebookSession] isOpen];
}

+ (JFFAsyncOperation)logoutLoaderWithRenewSystemAuthorization:(BOOL)renewSystemAuthorization
{
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        FBSession *session = [FBSession activeSession];
        
        JFFAsyncOperation loader = session
        ?jffFacebookLogout(session, renewSystemAuthorization)
        :asyncOperationWithResult([NSNull new]);
        
        doneCallback = [doneCallback copy];
        JFFDidFinishAsyncOperationHandler doneCallbackWrapper = ^(id result, NSError *error) {
            
            if (result)
                [self setFacebookSession:nil];
            
            if (doneCallback)
                doneCallback(result, error);
        };
        
        return loader(progressCallback,
                      cancelCallback,
                      doneCallbackWrapper);
    };
}

+ (JFFAsyncOperation)authFacebookSessionLoaderWithPermissions:(NSArray *)permissions
{
    JFFAsyncOperation loader = ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                                        JFFCancelAsyncOperationHandler cancelCallback,
                                                        JFFDidFinishAsyncOperationHandler doneCallback) {
        
        //TODO split perrmissions, first login for "email" "birthday"
        //tthen for other ones
        
        FBSession *session = [self facebookSession];
        
        NSMutableSet *currPermissions = [[NSMutableSet alloc] initWithArray:session.permissions];
        [currPermissions unionSet:[[NSSet alloc] initWithArray:permissions]];
        
        JFFAsyncOperation loader = jffFacebookLogin(session, permissions);
        
        doneCallback = [doneCallback copy];
        JFFDidFinishAsyncOperationHandler doneCallbackWrapper = ^(FBSession *session, NSError *error) {
            
            if (session)
                [self setFacebookSession:session];
            
            if (doneCallback)
                doneCallback(session, error);
        };
        
        return loader(progressCallback, cancelCallback, doneCallbackWrapper);
    };
    
    id mergeObject =
    @{
      @"methodName"  : NSStringFromSelector(_cmd),
      @"permissions" : [[NSSet alloc] initWithArray:permissions]
      };
    return [self asyncOperationMergeLoaders:loader withArgument:mergeObject];
}

+ (JFFAsyncOperation)authFacebookSessionWithPublishPermissions:(NSArray *)permissions
{
    JFFAsyncOperation loader = ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                                        JFFCancelAsyncOperationHandler cancelCallback,
                                                        JFFDidFinishAsyncOperationHandler doneCallback) {
        
        FBSession *session = [self facebookSession];
        
        NSMutableSet *currPermissions = [[NSMutableSet alloc] initWithArray:session.permissions];
        [currPermissions unionSet:[[NSSet alloc] initWithArray:permissions]];
        
        JFFAsyncOperation loader = jffFacebookLoginWithPublishPermissions(session, [currPermissions allObjects]);
        
        doneCallback = [doneCallback copy];
        JFFDidFinishAsyncOperationHandler doneCallbackWrapper = ^(FBSession *session, NSError *error) {
            
            if (session)
                [self setFacebookSession:session];
            
            if (doneCallback)
                doneCallback(session, error);
        };
        
        return loader(progressCallback, cancelCallback, doneCallbackWrapper);
    };
    
    id mergeObject =
    @{
      @"methodName"  : NSStringFromSelector(_cmd),
      @"permissions" : [[NSSet alloc] initWithArray:permissions]
      };
    return [self asyncOperationMergeLoaders:loader withArgument:mergeObject];
}

+ (JFFAsyncOperation)authFacebookSessionLoader
{
    return [self authFacebookSessionLoaderWithPermissions:[self authPermissions]];
}

+ (JFFAsyncOperation)publishStreamAccessSessionLoader
{
    JFFAsyncOperation authLoader = [self authFacebookSessionLoader];
    
    JFFAsyncOperationBinder binder = ^JFFAsyncOperation(FBSession *session) {
        
        NSArray *permissions = @[@"publish_stream", @"user_birthday", @"email"];
        return jffFacebookPublishAccessRequest(session, permissions);
    };
    
    return bindSequenceOfAsyncOperations(authLoader, binder, nil);
}

+ (JFFAsyncOperation)authTokenLoader
{
    return [self authTokenLoaderWithPermissions:[self authPermissions]];
}

+ (JFFAsyncOperation)authTokenLoaderWithPermissions:(NSArray *)permissions
{
    JFFAsyncOperationBinder binder = ^JFFAsyncOperation(FBSession *session) {
        
        return asyncOperationWithResult(session.accessTokenData.accessToken);
    };
    
    return bindSequenceOfAsyncOperations([self authFacebookSessionLoaderWithPermissions:permissions], binder, nil);
}

+ (JFFAsyncOperationBinder)userParser
{
    JFFAsyncOperationBinder parser = ^JFFAsyncOperation (NSDictionary *result) {
        JFFSyncOperation loadDataBlock = ^id(NSError **outError) {
            return [JFFSocialFacebookUser newSocialFacebookUserWithJsonObject:result error:outError];
        };
        return asyncOperationWithSyncOperationInCurrentQueue(loadDataBlock);
    };
    
    return parser;
}

+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath
                                 session:(FBSession *)session
{
    return [self graphLoaderWithPath:graphPath parameters:nil session:session];
}

+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath
                              parameters:(NSDictionary *)parameters
                                 session:(FBSession *)session
{
    return [self graphLoaderWithPath:graphPath
                          httpMethod:@"GET"
                          parameters:parameters
                             session:session
            ];
}

+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath
                              httpMethod:(NSString *)HTTPMethod
                              parameters:(NSDictionary *)parameters
                                 session:(FBSession *)session
{
    graphPath = [graphPath stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    JFFAsyncOperation graphLoader = jffGenericFacebookGraphRequestLoader(session, graphPath, HTTPMethod, parameters);
    
    return graphLoader;
}

+ (JFFAsyncOperation)userInfoLoader
{
    static NSArray *fields;
    fields = fields?:@[@"id", @"email", @"name", @"gender", @"birthday", @"picture", @"bio"];
    
    return [self userInfoLoaderWithFields:fields];
}

+ (JFFAsyncOperation)userInfoLoaderWithFields:(NSArray *)fields
                                sessionLoader:(JFFAsyncOperation)sessionLoader
{
    JFFAsyncOperationBinder userLoader = ^JFFAsyncOperation(FBSession *session) {
        
        NSDictionary *parameters;
        
        if ([fields count] > 0) {
            
            parameters = @{@"fields" : [fields componentsJoinedByString:@","]};
        }
        
        JFFAsyncOperation selfUserLoader = [self graphLoaderWithPath:@"me"
                                                          parameters:parameters
                                                             session:session];
        
        JFFAsyncOperationBinder userParser = [self userParser];
        
        JFFAsyncOperation userLoader = bindSequenceOfAsyncOperations(selfUserLoader,
                                                                     userParser,
                                                                     nil);
        
        return userLoader;
    };
    
    JFFAsyncOperation loader = bindSequenceOfAsyncOperations(sessionLoader, userLoader, nil);
    
    JFFAsyncOperation reloadSession = sequenceOfAsyncOperations([self logoutLoaderWithRenewSystemAuthorization:YES], sessionLoader, nil);
    JFFAsyncOperation reloadUser = bindSequenceOfAsyncOperations(reloadSession, userLoader, nil);
    
    return trySequenceOfAsyncOperations(loader, reloadUser, nil);
}

+ (JFFAsyncOperation)userInfoLoaderWithFields:(NSArray *)fields
{
    return [self userInfoLoaderWithFields:fields
                            sessionLoader:[self authFacebookSessionLoader]];
}

+ (JFFAsyncOperation)requestFacebookDialogWithParameters:(NSDictionary *)parameters
                                                 message:(NSString *)message
                                                   title:(NSString *)title
{
    JFFAsyncOperationBinder binder = ^JFFAsyncOperation(FBSession *session) {
        
        NSParameterAssert(session);
        return jffRequestFacebookDialog([JFFSocialFacebook facebookSession], parameters, message, title);
    };
    
    return bindSequenceOfAsyncOperations([self authFacebookSessionLoader],
                                         binder,
                                         nil);
}

+ (JFFAsyncOperation)postImage:(UIImage *)image
                   withMessage:(NSString *)message
{
    NSDictionary *parameters =
    @{
      @"message" : message?:@"",
      @"image"   : UIImageJPEGRepresentation(image, 1.)
      };
    
    JFFAsyncOperationBinder binder = ^(FBSession *session) {
        
        return [JFFSocialFacebook graphLoaderWithPath:@"me/photos"
                                           httpMethod:@"POST"
                                           parameters:parameters
                                              session:session];
    };
    
    JFFAsyncOperation getAccessLoader = [self publishStreamAccessSessionLoader];
    
    return bindSequenceOfAsyncOperations(getAccessLoader, binder, nil);
}

@end
