#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class UIImage;

@interface JFFSocialFoursquare : NSObject

+ (JFFAsyncOperation)authLoader;

+ (JFFAsyncOperation)myFriendsLoader;

+ (JFFAsyncOperation)checkinsLoaderWithUserId:(NSString *)userID limit:(NSInteger)limit;

+ (JFFAsyncOperation)addPostToCheckin:(NSString *)checkinID
                             withText:(NSString *)text
                                  url:(NSString *)url
                            contentID:(NSString *)contentID;

+ (JFFAsyncOperation)addPhoto:(UIImage *)image
                    toCheckin:(NSString *)checkinID
                         text:(NSString *)text
                          url:(NSString *)url
                    contentID:(NSString *)contentID;

+ (JFFAsyncOperation)inviteUserLoader:(NSString *)userID
                                 text:(NSString *)text
                                  url:(NSString *)url;

@end
