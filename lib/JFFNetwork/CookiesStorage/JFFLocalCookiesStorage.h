#import <Foundation/Foundation.h>

@interface JFFLocalCookiesStorage : NSObject

-(void)setCookie:( NSHTTPCookie* )cookie_;
-(NSArray*)cookiesForURL:( NSURL* )url_;

@end
