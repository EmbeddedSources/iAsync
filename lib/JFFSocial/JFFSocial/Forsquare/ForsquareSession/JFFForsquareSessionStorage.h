#import <Foundation/Foundation.h>

@interface JFFForsquareSessionStorage : NSObject

+ (NSString *)accessToken;

+ (void)saveAccessToken:(NSString *)accessToken;

@end
