#import <Foundation/Foundation.h>

@interface NSString (RFC_2965)

-(BOOL)domainMatchesCookiesDomain:( NSString* )cookiesDomain_;
-(BOOL)pathMatchesCookiesPath:( NSString* )cookiesPath_;

@end
