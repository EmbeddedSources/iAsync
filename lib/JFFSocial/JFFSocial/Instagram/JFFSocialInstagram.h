#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFInstagramCredentials;

@interface JFFSocialInstagram : NSObject

+ (JFFAsyncOperation)userLoaderForForUserId:(NSString *)userId
                                accessToken:(NSString *)accessToken;

+ (JFFAsyncOperation)followedByLoaderForUserId:(NSString *)userId
                                   accessToken:(NSString *)accessToken;

+ (JFFAsyncOperation)followedByLoaderWithCredentials:(JFFInstagramCredentials *)credentials;

+ (JFFAsyncOperation)recentMediaItemsLoaderForUserId:(NSString *)userId
                                         accessToken:(NSString *)accessToken;

+ (JFFAsyncOperation)recentMediaItemsLoaderForUserId:(NSString *)userId
                                         credentials:(JFFInstagramCredentials *)credentials;

+ (JFFAsyncOperation)commentMediaItemLoaderWithId:(NSString *)mediaItemId
                                          comment:(NSString *)comment
                                      accessToken:(NSString *)accessToken;

+ (JFFAsyncOperation)notifyUsersFollowersWithId:(NSString *)userId
                                        message:(NSString *)message
                                    accessToken:(NSString *)accessToken;

+ (JFFAsyncOperation)notifyUsersFollowersWithCredentials:(JFFInstagramCredentials *)credentials
                                                 message:(NSString *)message;

+ (JFFAsyncOperation)notifyUsersWithCredentials:(JFFInstagramCredentials *)credentials
                                       usersIds:(NSArray *)usersIds
                                        message:(NSString *)message;

@end
