#import "JFFSocialForsquare.h"

#import "JFFAsyncFoursquaerLogin.h"
#import "JFFAsyncFoursquareRequest.h"

#import "JFFForsquareSessionStorage.h"

#import "JFFSocialAsyncUtils.h"

#import "JFFFoursquareAuthInvalidAccessTokenError.h"
#import "JFFFoursquareCachedAccessTokenError.h"

#import "NSArray+FqFriendsAPIParser.h"
#import "NSArray+FqCheckinsAPIParser.h"

@implementation JFFSocialForsquare


#pragma mark - Common



#pragma mark - AUTH

+ (JFFAsyncOperation)cachedAuthLoader
{
    return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *error) {
        NSString *cachedAccessToken = [JFFForsquareSessionStorage accessToken];
        
        if (cachedAccessToken) {
            return cachedAccessToken;
        }
        
        [[JFFFoursquareCachedAccessTokenError new] setToPointer:error];
        return nil;
        
    });
}

+ (JFFAsyncOperation)authLoader
{
    JFFAsyncOperationBinder accessTokenBinder = ^JFFAsyncOperation(NSURL *url)
    {
        NSString *accessToken = [JFFForsquareSessionStorage accessTokenWithURL:url];
        if (accessToken) {
            return asyncOperationWithResult(accessToken);
        }
        else
        {
            return asyncOperationWithError([JFFFoursquareAuthInvalidAccessTokenError new]);
        }
    };
    
    return trySequenceOfAsyncOperations([self cachedAuthLoader],
                                        bindSequenceOfAsyncOperations(jffFoursquareLoginLoader(), accessTokenBinder, nil),
                                        nil);
}

#pragma mark - Get friends

+ (JFFAsyncOperation)myFriendsLoader
{
    static NSString *fqLoadFriendsURL = @"https://api.foursquare.com/v2/users/self/friends";
    JFFAsyncOperationBinder myFriendBinder = ^JFFAsyncOperation (NSString *accessToken)
    {
        return bindSequenceOfAsyncOperations(jffFoursquareRequestLoader(fqLoadFriendsURL, @"GET", accessToken, nil), asyncJsonDataAnalizer(), nil);
    };

    return bindSequenceOfAsyncOperations([self authLoader],
                                         myFriendBinder,
                                         [self myFriendsParser],
                                         nil);
}

+ (JFFAsyncOperationBinder)myFriendsParser
{
    return ^JFFAsyncOperation (NSDictionary *response)
    {
        return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *outError) {
            NSError *error = nil;
            NSArray *users = [NSArray fqFriendsWithDict:response error:&error];
            if (error) {
                [error setToPointer:outError];
                return nil;
            }
            return users;
        });
    };
}

#pragma mark - Get checkins

+ (JFFAsyncOperation)checkinsLoaderWithUserId:(NSString *)userID limit:(NSInteger)limit
{
    static NSString *fqLoadCheckinsURLFormat = @"https://api.foursquare.com/v2/users/%@/checkins";
    
    userID = (userID) ? : @"self";
    NSString *fqLoadCheckinsURL = [NSString stringWithFormat:fqLoadCheckinsURLFormat, userID];
    
    NSDictionary *params = @{ @"limit" : @(limit)};
    
    JFFAsyncOperationBinder checkinsBinder = ^JFFAsyncOperation (NSString *accessToken)
    {
        return bindSequenceOfAsyncOperations(jffFoursquareRequestLoader(fqLoadCheckinsURL, @"GET", accessToken, params), asyncJsonDataAnalizer(), nil);
    };
    
    return bindSequenceOfAsyncOperations([self authLoader],
                                         checkinsBinder,
                                         [self checkinsParser],
                                         nil);
}

+ (JFFAsyncOperationBinder)checkinsParser
{
    return ^JFFAsyncOperation (NSDictionary *response)
    {
        return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *outError) {
            NSError *error = nil;
            NSArray *checkins = [NSArray fqCheckinsWithDict:response error:&error];
            if (error) {
                [error setToPointer:outError];
                return nil;
            }
            return checkins;
        });
    };
}

#pragma mark - Post comment to checkin

//+ (JFFAsyncOperation)postComment:(NSString *)text toCheckin:(NSString *)checkinID
//{
//    
//}

#pragma mark AddPost

+ (JFFAsyncOperation)addPostToCheckin:(NSString *)checkinID
                             withText:(NSString *)text
                                  url:(NSString *)url
                            contentID:(NSString *)contentID
{
    static NSString *addPostURLFormat = @"https://api.foursquare.com/v2/checkins/%@/addpost"; //CHECKIN_ID
    
    NSString *addPostURL = [NSString stringWithFormat:addPostURLFormat, checkinID];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:3];
    [params setObjectWithIgnoreNillValue:text forKey:@"text"];
    [params setObjectWithIgnoreNillValue:url forKey:@"url"];
    [params setObjectWithIgnoreNillValue:contentID forKey:@"contentId"];
    
    params = [params copy];
    
    JFFAsyncOperationBinder postLoaderBinder = ^JFFAsyncOperation (NSString *accessToken)
    {
        return bindSequenceOfAsyncOperations(jffFoursquareRequestLoader(addPostURL, @"POST", accessToken, params), asyncJsonDataAnalizer(), nil);
    };
    
    return bindSequenceOfAsyncOperations([self authLoader],
                                         postLoaderBinder,
                                         [self addPostResponseParser],
                                         nil);
}

+ (JFFAsyncOperationBinder)addPostResponseParser
{
    return ^JFFAsyncOperation (NSDictionary *response)
    {
        return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *outError) {
            return [NSObject new];
        });
    };
}


#pragma mark Add photo

//+ (JFFAsyncOperation)addPhoto:(UIImage *)image
//                    toCheckin:(NSString *)checkinID
//                         text:(NSString *)text
//                          url:(NSString *)url
//                    contentID:(NSString *)contentID
//{
//    
//}


@end
