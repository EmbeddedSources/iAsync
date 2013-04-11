#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFSocialFacebook : NSObject

+ (BOOL)isActiveFacebookSession;

+ (JFFAsyncOperation)logoutLoader;

+ (JFFAsyncOperation)authTokenLoader;
+ (JFFAsyncOperation)authFacebookSessionLoader;

+ (JFFAsyncOperation)userInfoLoader;

+ (JFFAsyncOperation)requestFacebookDialogWithParameters:(NSDictionary *)parameters
                                                 message:(NSString *)message
                                                   title:(NSString *)title;

#pragma mark callbacks

+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath;

+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath
                              httpMethod:(NSString *)HTTPMethod
                              parameters:(NSDictionary *)parameters;

@end
