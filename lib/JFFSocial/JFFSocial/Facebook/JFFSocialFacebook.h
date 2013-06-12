#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class FBSession;

@interface JFFSocialFacebook : NSObject

+ (BOOL)isActiveFacebookSession;

+ (JFFAsyncOperation)logoutLoader;

+ (JFFAsyncOperation)authTokenLoader;
+ (JFFAsyncOperation)authTokenLoaderWithPermissions:(NSArray *)permissions;
+ (JFFAsyncOperation)authFacebookSessionLoader;
+ (JFFAsyncOperation)authFacebookSessionLoaderWithPermissions:(NSArray *)permissions;

+ (JFFAsyncOperation)publishStreamAccessSessionLoader;

+ (JFFAsyncOperation)userInfoLoader;

+ (JFFAsyncOperation)requestFacebookDialogWithParameters:(NSDictionary *)parameters
                                                 message:(NSString *)message
                                                   title:(NSString *)title;

#pragma mark callbacks

+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath
                                 session:(FBSession *)session;

+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath
                              httpMethod:(NSString *)HTTPMethod
                              parameters:(NSDictionary *)parameters
                                 session:(FBSession *)session;

+ (JFFAsyncOperation)postImage:(UIImage *)photo
                   withMessage:(NSString *)message
                    postOnWall:(BOOL)postOnWall;

@end
