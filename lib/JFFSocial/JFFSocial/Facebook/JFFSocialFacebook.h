#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef void(^JFFFacebookDidLoginCallback)(NSString *login);
typedef void(^JFFFacebookDidLogoutCallback)(NSString *login);

@class FBSession;

@interface JFFSocialFacebook : NSObject

+ (FBSession *)facebookSession;

+ (JFFAsyncOperation)logoutLoader;
+ (JFFAsyncOperation)authLoader;

+ (JFFAsyncOperation)userInfoLoader;

#pragma mark callbacks

+ (void)setDidLoginCallback:(JFFFacebookDidLoginCallback)didLoginCallback;
+ (void)setDidLogoutCallback:(JFFFacebookDidLogoutCallback)didLogoutCallback;

//TODO hide this methods
+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath;

+ (JFFAsyncOperation)graphLoaderWithPath:(NSString *)graphPath
                              httpMethod:(NSString *)HTTPMethod
                              parameters:(NSDictionary *)parameters;

@end
