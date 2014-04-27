#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef void(^JFFSocialTwitterDidLoginCallback)(NSString *login);

@interface JFFSocialTwitter : NSObject

+ (BOOL)isAuthorized;

+ (JFFAsyncOperation)authorizationLoader;

+ (JFFAsyncOperation)usersNearbyCoordinatesLatitude:(double)latitude longitude:(double)longitude;

+ (JFFAsyncOperation)followersLoader;

+ (JFFAsyncOperation)sendDirectMessage:(NSString *)message
                      toFollowerWithId:(NSString *)userId;

+ (JFFAsyncOperation)sendTweetMessage:(NSString *)message;

@end
