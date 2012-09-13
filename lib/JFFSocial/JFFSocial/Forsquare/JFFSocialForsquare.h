#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFSocialForsquare : NSObject

+ (JFFAsyncOperation)authLoader;

+ (JFFAsyncOperation)myFriendsLoader;

+ (JFFAsyncOperation)checkinsLoaderWithUserId:(NSString *)userID limit:(NSInteger)limit;

+ (JFFAsyncOperation)addPostToCheckin:(NSString *)checkinID
                             withText:(NSString *)text
                                  url:(NSString *)url
                            contentID:(NSString *)contentID;

@end
