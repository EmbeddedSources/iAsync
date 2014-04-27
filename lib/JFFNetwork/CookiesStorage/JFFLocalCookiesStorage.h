#import <Foundation/Foundation.h>

@interface JFFLocalCookiesStorage : NSObject

- (void)setMultipleCookies:(NSArray *)cookies;

- (void)setCookie:(NSHTTPCookie *)cookie;
- (NSArray *)cookiesForURL:(NSURL *)url;

@end
