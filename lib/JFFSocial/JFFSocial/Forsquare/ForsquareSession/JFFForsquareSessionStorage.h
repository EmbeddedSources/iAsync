#import <Foundation/Foundation.h>

@interface JFFForsquareSessionStorage : NSObject

+ (NSString *)accessToken;
+ (void)saveAccessToken:(NSString *)accessToken;


- (BOOL)handleAuthOpenURL:(NSURL *)url;
+ (BOOL)handleAuthOpenURL:(NSURL *)url;

- (void)openSessionWithHandler:(JFFDidFinishAsyncOperationHandler)hendler;

+ (NSString *)redirectURI;

+ (id)shared;

@end
