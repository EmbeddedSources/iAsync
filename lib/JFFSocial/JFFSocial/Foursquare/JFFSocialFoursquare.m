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

+ (JFFAsyncOperationBinder)serverResponseAnalyzer
{
    return ^JFFAsyncOperation (NSDictionary *response)
    {
        return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *outError) {
            id result = [NSDictionary fqApiresponseDictWithDict:response error:outError];
            return result;
        });
    };
}

#pragma mark - AUTH

+ (JFFAsyncOperation)cachedAuthLoader
{
    return asyncOperationWithSyncOperation(^id(NSError *__autoreleasing *outError) {
        NSString *cachedAccessToken = [JFFFoursquareSessionStorage accessToken];
        
        if (cachedAccessToken) {
            return cachedAccessToken;
        }
        
        if (outError) {
            *outError = [JFFFoursquareCachedAccessTokenError new];
        }
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
                                             [self serverResponseAnalyzer],
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
            NSArray *users = [NSArray fqFriendsWithDict:response error:outError];
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
                                             [self serverResponseAnalyzer],
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
            NSArray *checkins = [NSArray fqCheckinsWithDict:response error:outError];
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
                                             [self serverResponseAnalyzer],
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
    
    if (text)
        params[@"text"] = text;

    if (url)
        params[@"url"] = url;
    
    if (contentID)
        params[@"contentId"] = contentID;
    
    params = [params copy];
    
    JFFAsyncOperationBinder postLoaderBinder = ^JFFAsyncOperation (NSString *accessToken)
    {
        return bindSequenceOfAsyncOperations(jffFoursquareRequestLoader(addPostURL, @"POST", accessToken, params),
                                             asyncOperationBinderJsonDataParser(),
                                             [self serverResponseAnalyzer],
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

+ (JFFAsyncOperation)addPhoto:(UIImage *)image
                    toCheckin:(NSString *)checkinID
                         text:(NSString *)text
                          url:(NSString *)url
                    contentID:(NSString *)contentID
{
    static NSString *const addPhotoURL = @"https://api.foursquare.com/v2/photos/add";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    if (text)
        params[@"postText"] = text;
    
    if (url)
        params[@"postUrl"] = url;
    
    if (contentID)
        params[@"postContentId"] = contentID;
    
    if (checkinID)
        params[@"checkinId"] = checkinID;
    
    params[@"post*"] = @"1";
    
    NSString *boundary = [NSString createUuid];
    
    NSMutableData *httpBody = [NSMutableData dataForHTTPPostWithData:UIImageJPEGRepresentation(image, 1.0)
                                                         andFileName:@"name"
                                                    andParameterName:@"photo"
                                                            boundary:boundary];
    
    [httpBody appendHTTPParameters:params boundary:boundary];
    
    JFFAsyncOperationBinder postLoaderBinder = ^JFFAsyncOperation(NSString *accessToken) {
        return bindSequenceOfAsyncOperations(jffFoursquareRequestLoaderWithHTTPBody(addPhotoURL, httpBody, accessToken),
                                             asyncOperationBinderJsonDataParser(),
                                             [self serverResponseAnalyzer],
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
