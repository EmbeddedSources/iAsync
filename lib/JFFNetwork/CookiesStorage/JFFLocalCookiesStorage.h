#import <Foundation/Foundation.h>

@interface JFFLocalCookiesStorage : NSObject

- (void)setCookie:(NSHTTPCookie *)cookie;
- (NSArray *)cookiesForURL:(NSURL *)url;

@end
