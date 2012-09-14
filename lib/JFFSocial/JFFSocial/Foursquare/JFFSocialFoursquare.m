#import "JFFSocialFoursquare.h"

#import "JFFAsyncFoursquaerLogin.h"
#import "JFFAsyncFoursquareRequest.h"

#import "JFFFoursquareSessionStorage.h"

#import "JFFFoursquareAuthInvalidAccessTokenError.h"
#import "JFFFoursquareCachedAccessTokenError.h"

#import "NSArray+FqFriendsAPIParser.h"
#import "NSArray+FqCheckinsAPIParser.h"
#import "NSDictionary+FqAPIresponseParser.h"

#import "FoursquareCheckinsModel.h"

#import "JFFFoursquareNotFoundUsersCheckinsError.h"

@implementation JFFSocialFoursquare


#pragma mark - Common

+ (JFFAsyncOperationBinder)serverResponseAnalizer
{
    return ^JFFAsyncOperation (NSDictionary *response)
    {
        return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *outError) {
            NSError *error = nil;
            id result = [NSDictionary fqApiresponseDictWithDict:response error:&error];
            [error setToPointer:outError];
            return result;
        });
    };
}

#pragma mark - AUTH

+ (JFFAsyncOperation)cachedAuthLoader
{
    return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *error) {
        NSString *cachedAccessToken = [JFFFoursquareSessionStorage accessToken];
        
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
        NSString *accessToken = [JFFFoursquareSessionStorage accessTokenWithURL:url];
        if (accessToken) {
            [JFFFoursquareSessionStorage saveAccessToken:accessToken];
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
        return bindSequenceOfAsyncOperations(jffFoursquareRequestLoader(fqLoadFriendsURL, @"GET", accessToken, nil),
                                             asyncOperationBinderJsonDataParser(),
                                             [self serverResponseAnalizer],
                                             nil);
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
        return bindSequenceOfAsyncOperations(jffFoursquareRequestLoader(fqLoadCheckinsURL, @"GET", accessToken, params),
                                             asyncOperationBinderJsonDataParser(),
                                             [self serverResponseAnalizer],
                                             nil);
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

+ (JFFAsyncOperation)postComment:(NSString *)text toCheckin:(NSString *)checkinID
{
    static NSString *addPostURLFormat = @"https://api.foursquare.com/v2/checkins/%@/addcomment"; //CHECKIN_ID
    
    NSString *addPostURL = [NSString stringWithFormat:addPostURLFormat, checkinID];
    
    NSDictionary *params = @{ @"text" : text };
   
    
    JFFAsyncOperationBinder postLoaderBinder = ^JFFAsyncOperation (NSString *accessToken)
    {
        return bindSequenceOfAsyncOperations(jffFoursquareRequestLoader(addPostURL, @"POST", accessToken, params),
                                             asyncOperationBinderJsonDataParser(),
                                             [self serverResponseAnalizer],
                                             nil);
    };
    
    return bindSequenceOfAsyncOperations([self authLoader],
                                         postLoaderBinder,
                                         [self addPostResponseParser],
                                         nil);
}


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
        return bindSequenceOfAsyncOperations(jffFoursquareRequestLoader(addPostURL, @"POST", accessToken, params),
                                             asyncOperationBinderJsonDataParser(),
                                             [self serverResponseAnalizer],
                                             nil);
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
            return response;
        });
    };
}


#pragma mark Add photo
//TODO: Post question to API developers
+ (JFFAsyncOperation)addPhoto:(UIImage *)image
                    toCheckin:(NSString *)checkinID
                         text:(NSString *)text
                          url:(NSString *)url
                    contentID:(NSString *)contentID
{
    static NSString *addPhotoURL = @"https://api.foursquare.com/v2/photos/add";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:3];
    [params setObjectWithIgnoreNillValue:text forKey:@"postText"];
    [params setObjectWithIgnoreNillValue:url forKey:@"postUrl"];
    [params setObjectWithIgnoreNillValue:contentID forKey:@"postContentId"];
    [params setObjectWithIgnoreNillValue:checkinID forKey:@"checkinId"];
    [params setObject:@"1" forKey:@"post*"];
    
    NSData *imageData = [NSData dataForHTTPPostWithData:UIImageJPEGRepresentation(image, 1.0) andFileName:@"name" andParameterName:@"photo"];
    NSData *httpBody = [imageData dataForHTTPPostByAppendingParameters:params];
    
    JFFAsyncOperationBinder postLoaderBinder = ^JFFAsyncOperation (NSString *accessToken)
    {
        return bindSequenceOfAsyncOperations(jffFoursquareRequestLoaderWithHTTPBody(addPhotoURL, httpBody, accessToken),
                                             asyncOperationBinderJsonDataParser(),
                                             [self serverResponseAnalizer],
                                             nil);
    };
    
    return bindSequenceOfAsyncOperations([self authLoader],
                                         postLoaderBinder,
                                         nil);
}

#pragma mark - Invite

+ (JFFAsyncOperation)inviteUserLoader:(NSString *)userID
                                 text:(NSString *)text
                                  url:(NSString *)url
{
    JFFAsyncOperationBinder addPostBinder = ^JFFAsyncOperation (NSArray *checkins)
    {
        FoursquareCheckinsModel *lastCheckin = [checkins count] > 0 ? checkins[0] : nil;
        
        if (!lastCheckin) {
            return asyncOperationWithError([JFFFoursquareNotFoundUsersCheckinsError new]);
        }
//        return [self addPostToCheckin:lastCheckin.checkinID withText:text url:url contentID:nil];
        return [self postComment:@"http://wishdates.com" toCheckin:lastCheckin.checkinID];
    };
    
    return bindSequenceOfAsyncOperations([self checkinsLoaderWithUserId:userID limit:1], addPostBinder, nil);
}


#pragma mark - Make checkin

//+ (JFFAsyncOperation)

@end
