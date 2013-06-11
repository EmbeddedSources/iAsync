#import <Foundation/Foundation.h>

@interface JFFFoursquareSessionStorage : NSObject

+ (NSString *)accessToken;
+ (void)saveAccessToken:(NSString *)accessToken;

+ (NSString *)authURLString;

- (BOOL)handleAuthOpenURL:(NSURL *)url;
+ (BOOL)handleAuthOpenURL:(NSURL *)url;

+ (NSString *)accessTokenWithURL:(NSURL *)url;

- (void)openSessionWithHandler:(JFFDidFinishAsyncOperationHandler)hendler;

+ (NSString *)redirectURI;

+ (instancetype)shared;

@end
