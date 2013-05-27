#import "JFFSocialFacebook.h"

#import "JFFAsyncFacebook.h"
#import "JFFAsyncFacebookLogin.h"
#import "JFFAsyncFacebookLogout.h"
#import "JFFAsyncFacebookDialog.h"

#import "JFFSocialFacebookUser+Parser.h"

#import "JFFFacebookPublishAccessRequestAdapter.h"

#import <FacebookSDK/FacebookSDK.h>

@implementation JFFSocialFacebook

+ (NSArray *)authPermissions
{
    NSArray *result = @[@"email",
                        @"user_birthday",
//                        @"friends_location",
//                        @"friends_photos",
//                        @"friends_about_me",
//                        @"read_friendlists",
//                        @"user_relationships",
//                        @"user_checkins",
//                        @"friends_checkins",
//                        @"user_likes",
//                        @"friends_likes",
//                        @"user_events",
//                        @"friends_events"
                        ];
    
    return result;
}

+ (FBSession *)facebookSession
{
    FBSession *facebookSession = [FBSession activeSession];
    
    if (!facebookSession || ![facebookSession isOpen]) {
        facebookSession = [[FBSession alloc] initWithPermissions:[self authPermissions]];
        [FBSession setActiveSession:facebookSession];
    }
    return facebookSession;
}

+ (BOOL)isActiveFacebookSession
{
    return [[self facebookSession] isOpen];
}

+ (JFFAsyncOperation)logoutLoader
{
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        FBSession *session = [FBSession activeSession];
        JFFAsyncOperation loader = [session isOpen]
        ?jffFacebookLogout(session)
        :asyncOperationWithResult([NSNull new]);
        
        return loader(progressCallback,
                      cancelCallback,
                      doneCallback);
    };
}

+ (JFFAsyncOperation)authFacebookSessionLoaderWithPermissions:(NSArray *)permissions
{
    JFFAsyncOperation loader = ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                                        JFFCancelAsyncOperationHandler cancelCallback,
                                                        JFFDidFinishAsyncOperationHandler doneCallback) {
        
        FBSession *session = [self facebookSession];
        
        JFFAsyncOperation loader = jffFacebookLogin(session, permissions);
        
        return loader(progressCallback, cancelCallback, doneCallback);
    };
    
    id mergeObject =
    @{
      @"methodName"  : NSStringFromSelector(_cmd),
      @"permissions" : permissions
      };
    return [self asyncOperationMergeLoaders:loader withArgument:mergeObject];
}

+ (JFFAsyncOperation)authFacebookSessionLoader
{
    return [self authFacebookSessionLoaderWithPermissions:[self authPermissions]];
}

+ (JFFAsyncOperation)publishStreamAccessLoader
{
    JFFAsyncOperation authLoader = [self authFacebookSessionLoader];
    
    JFFAsyncOperationBinder binder = ^JFFAsyncOperation(FBSession *session) {
        
        NSArray *permissions = @[@"publish_stream"];
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
    return [self graphLoaderWithPath:graphPath httpMethod:@"GET"
                          parameters:parameters
                             session:session];
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
    
    return bindSequenceOfAsyncOperations([self authFacebookSessionLoader], userLoader, nil);
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

+ (JFFAsyncOperation)postPhoto:(UIImage *)photo
                   withMessage:(NSString *)message
                    postOnWall:(BOOL)postOnWall
{
    NSDictionary *parameters =
    @{
      @"message" : message?:@"",
      @"image"   : UIImageJPEGRepresentation(photo, 1.)
      };
    
    JFFAsyncOperationBinder binder = ^(FBSession *session) {
        
        return [JFFSocialFacebook graphLoaderWithPath:@"me/photos"
                                           httpMethod:@"POST"
                                           parameters:parameters
                                              session:session];
    };
    
    JFFAsyncOperation getAccessLoader = postOnWall
    ?[JFFSocialFacebook publishStreamAccessLoader]
    :asyncOperationWithResult(@YES);
    
    return bindSequenceOfAsyncOperations(getAccessLoader, binder, nil);
}

@end
