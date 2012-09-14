#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <UIKit/UIKit.h>

typedef void(^JFFSocialTwitterDidLoginCallback)(NSString *login);

@interface JFFSocialTwitter : NSObject

+ (BOOL)isAuthorized;

+ (JFFAsyncOperation)usersNearbyCoordinatesLantitude:(double)lantitude longitude:(double)longitude;

+ (JFFAsyncOperation)followersLoader;

+ (JFFAsyncOperation)sendDirectMessage:(NSString *)message
                      toFollowerWithId:(NSString *)userId;

+ (JFFAsyncOperation)sendTweetMessage:(NSString *)message;

#pragma mark callbacks

+ (void)setDidLoginCallback:(JFFSocialTwitterDidLoginCallback)didLoginCallback;

@end
