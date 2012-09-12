#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFSocialInstagram : NSObject

+ (JFFAsyncOperation)userLoaderForForUserId:(NSString *)userId
                                accessToken:(NSString *)accessToken;

+ (JFFAsyncOperation)authedUserLoaderWithClientId:(NSString *)clientId
                                     clientSecret:(NSString *)clientSecret
                                      redirectURI:(NSString *)redirectURI;

+ (JFFAsyncOperation)followedByLoaderForUserId:(NSString *)userId
                                   accessToken:(NSString *)accessToken;

//TODO remove
+ (JFFAsyncOperation)followedByLoaderWithClientId:(NSString *)clientId
                                     clientSecret:(NSString *)clientSecret
                                      redirectURI:(NSString *)redirectURI;

+ (JFFAsyncOperation)recentMediaItemsLoaderForUserId:(NSString *)userId
                                         accessToken:(NSString *)accessToken;

+ (JFFAsyncOperation)commentMediaItemLoaderWithId:(NSString *)mediaItemId
                                          comment:(NSString *)comment
                                      accessToken:(NSString *)accessToken;

+ (JFFAsyncOperation)notifyUsersFollowersWithId:(NSString *)userId
                                        message:(NSString *)message
                                    accessToken:(NSString *)accessToken;

@end
