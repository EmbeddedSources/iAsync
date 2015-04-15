#import <Foundation/Foundation.h>

@interface NSString (RFC_2965)

- (BOOL)domainMatchesCookiesDomain:(NSString *)cookiesDomain;
- (BOOL)pathMatchesCookiesPath:(NSString *)cookiesPath;

@end
