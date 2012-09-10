#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <UIKit/UIKit.h>

//JTODO remove class or rename
@interface JFFSocialTwitter : NSObject

+ (JFFAsyncOperation)usersNearbyCoordinatesLantitude:(double)lantitude longitude:(double)longitude;

+ (JFFAsyncOperation)followersLoader;

+ (JFFAsyncOperation)sendMessage:(NSString *)message
                toFollowerWithId:(NSString *)userId;

@end
