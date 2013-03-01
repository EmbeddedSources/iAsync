#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef void(^JFFFacebookDidLoginCallback)(NSString *login);
typedef void(^JFFFacebookDidLogoutCallback)(NSString *login);

@interface JFFSocialFacebook : NSObject

+ (BOOL)isActiveFacebookSession;

+ (JFFAsyncOperation)logoutLoader;

+ (JFFAsyncOperation)authTokenLoader;

+ (JFFAsyncOperation)userInfoLoader;

+ (JFFAsyncOperation)requestFacebookDialogWithParameters:(NSDictionary *)parameters
                                                 message:(NSString *)message
                                                   title:(NSString *)title;

#pragma mark callbacks

+ (void)setDidLoginCallback:(JFFFacebookDidLoginCallback)didLoginCallback;
+ (void)setDidLogoutCallback:(JFFFacebookDidLogoutCallback)didLogoutCallback;

//TODO hide this methods
+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath;

+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath
                              httpMethod:(NSString *)HTTPMethod
                              parameters:(NSDictionary *)parameters;

@end
