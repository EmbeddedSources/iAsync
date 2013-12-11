#import <Foundation/Foundation.h>

@interface JFFLocalCookiesStorage : NSObject

-(void)setMultipleCookies:( NSArray* )cookies;

-(void)setCookie:( NSHTTPCookie* )cookie_;
-(NSArray*)cookiesForURL:( NSURL* )url_;

@end
