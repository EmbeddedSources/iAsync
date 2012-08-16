#import "NSURL+Cookies.h"

@implementation NSURL (Cookies)

-(void)logCookies
{
    NSMutableString* cookiesLog_ = [ [ NSMutableString alloc ] initWithFormat: @"Cookies for url: %@\n", self ];

    NSArray* cookies_ = [ [ NSHTTPCookieStorage sharedHTTPCookieStorage ] cookiesForURL: self ];
    for ( NSHTTPCookie* cookie_ in cookies_ )
    {
        [ cookiesLog_ appendFormat: @"Name: '%@'; Value: '%@'\n", cookie_.name, cookie_.value ];
    }

    NSLog( @"%@", cookiesLog_ );
}

-(void)removeCookies
{
    NSArray* cookies_ = [ [ NSHTTPCookieStorage sharedHTTPCookieStorage ] cookiesForURL: self ];
    for ( NSHTTPCookie* cookie_ in cookies_ )
    {
        [ [ NSHTTPCookieStorage sharedHTTPCookieStorage ] deleteCookie: cookie_ ];
    }
}

@end
