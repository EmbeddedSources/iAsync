#import <Foundation/Foundation.h>

@interface JFFLocalCookiesStorage : NSObject

-(void)setCookies:( NSArray* )cookies_;
-(NSArray*)cookiesForURL:( NSURL* )url_;

@end
