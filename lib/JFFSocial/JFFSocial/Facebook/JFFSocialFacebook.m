#import "JFFSocialFacebook.h"

#import "JFFAsyncFacebook.h"
#import "JFFAsyncFacebookLogin.h"
#import "JFFAsyncFacebookLogout.h"
#import "JFFAsyncFacebookDialog.h"

#import "JFFSocialFacebookUser+Parser.h"

#import <FacebookSDK/FacebookSDK.h>

static JFFFacebookDidLoginCallback  globalDidLoginCallback;
static JFFFacebookDidLogoutCallback globalDidLogoutCallback;

@implementation JFFSocialFacebook

+ (NSArray *)authPermissions
{
    NSArray *result = @[@"email",
                        @"user_birthday",
                        @"user_photos",
                        @"friends_location",
                        @"friends_photos",
                        @"friends_about_me",
                        @"user_about_me",
                        @"read_friendlists",
                        @"user_relationships",
                        /*
                         @"user_checkins",
                         @"friends_checkins",
                         
                         @"user_likes",
                         @"friends_likes",
                         
                         @"user_events",
                         @"friends_events"
                         */
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
    FBSession *facebookSession = [FBSession activeSession];
    if (![facebookSession isOpen]) {
        return asyncOperationWithResult([NSNull new]);
    }
    
    JFFAsyncOperation logoutLoader = jffFacebookLogout(facebookSession);
    logoutLoader = asyncOperationWithFinishCallbackBlock(logoutLoader, ^(id result, NSError *error) {
        
        if (result && globalDidLogoutCallback)
            globalDidLogoutCallback(nil);
    });
    
    return logoutLoader;
}

+ (JFFAsyncOperation)authFacebookSessionLoader
{
    JFFAsyncOperation loader = ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                                        JFFCancelAsyncOperationHandler cancelCallback,
                                                        JFFDidFinishAsyncOperationHandler doneCallback) {
        
        FBSession *session = [self facebookSession];
        
        JFFAsyncOperation loader = jffFacebookLogin(session, [self authPermissions]);
        
        if (!session.isOpen) {
            
            loader = asyncOperationWithFinishCallbackBlock(loader, ^(id result, NSError *error) {
                
                if (result && globalDidLoginCallback) {
                    globalDidLoginCallback(nil);
                }
            });
        }
        
        return loader(progressCallback, cancelCallback, doneCallback);
    };
    
    id mergeObject =
    @{
      @"methodName" : NSStringFromSelector(_cmd),
      @"className"  : [self description]
      };
    return [self asyncOperationMergeLoaders:loader withArgument:mergeObject];
}

+ (JFFAsyncOperation)authTokenLoader
{
    JFFAsyncOperationBinder binder = ^JFFAsyncOperation(FBSession *session) {
        
        return asyncOperationWithResult(session.accessTokenData.accessToken);
    };
    
    return bindSequenceOfAsyncOperations([self authFacebookSessionLoader], binder, nil);
}

#pragma mark callbacks

+ (void)setDidLoginCallback:(JFFFacebookDidLoginCallback)didLoginCallback
{
    globalDidLoginCallback = [didLoginCallback copy];
}

+ (void)setDidLogoutCallback:(JFFFacebookDidLogoutCallback)didLogoutCallback
{
    globalDidLogoutCallback = [didLogoutCallback copy];
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
{
    return bindSequenceOfAsyncOperations([self authFacebookSessionLoader], ^JFFAsyncOperation(FBSession *session) {
        
        return [self graphLoaderWithPath:graphPath
                                 session:session];
    }, nil);
}

+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath
                              httpMethod:(NSString *)HTTPMethod
                              parameters:(NSDictionary *)parameters
{
    return bindSequenceOfAsyncOperations([self authFacebookSessionLoader], ^JFFAsyncOperation(FBSession *session) {
        
        return [self graphLoaderWithPath:graphPath
                              httpMethod:HTTPMethod
                              parameters:parameters
                                 session:session];
    }, nil);
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
    fields = fields?:@[@"id", @"name", @"gender", @"picture", @"bio"];
    
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

@end
