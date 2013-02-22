#import "JFFSocialFacebook.h"

#import "JFFAsyncFacebook.h"
#import "JFFAsyncFacebookLogin.h"
#import "JFFAsyncFacebookLogout.h"

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
                        @"user_photos",
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

+ (JFFAsyncOperation)authLoader
{
    JFFAsyncOperation authLoader = jffFacebookLogin([self facebookSession], [self authPermissions]);
    
    authLoader = asyncOperationWithFinishCallbackBlock(authLoader, ^(id result, NSError *error) {
        
        if (result && globalDidLoginCallback) {
            globalDidLoginCallback(nil);
        }
    });
    
    id mergeObject =
    @{
      @"methodName" : NSStringFromSelector(_cmd),
      @"className"  : [self description]
      };
    return [self asyncOperationMergeLoaders:authLoader withArgument:mergeObject];
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
    return [self graphLoaderWithPath:graphPath httpMethod:@"GET" parameters:nil];
}

+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath
                              httpMethod:(NSString *)HTTPMethod
                              parameters:(NSDictionary *)parameters
{
    graphPath = [graphPath stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    JFFAsyncOperation graphLoader = jffGenericFacebookGraphRequestLoader([JFFSocialFacebook facebookSession], graphPath, HTTPMethod, parameters);
    
    return graphLoader;
}

+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath andRequestTag:(NSString *)requestTag
{
    return [self graphLoaderWithPath:graphPath httpMethod:@"GET" parameters:nil];
}

+ (JFFAsyncOperation)userInfoLoader
{
    JFFAsyncOperation selfUserLoader = [self graphLoaderWithPath:@"me" andRequestTag:@"selfUser"];
    
    JFFAsyncOperationBinder userParser = [self userParser];
    
    return bindSequenceOfAsyncOperations(selfUserLoader,
                                         userParser,
                                         nil);
}

@end
