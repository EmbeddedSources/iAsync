#import "NSURL+Cookies.h"

@implementation NSURL (Cookies)

-(void)logCookies
{
   NSMutableString* cookies_log_ = [ NSMutableString stringWithFormat: @"Cookies for url: %@\n", self ];

   NSArray* cookies_ = [ [ NSHTTPCookieStorage sharedHTTPCookieStorage ] cookiesForURL: self ];
   for ( NSHTTPCookie* cookie_ in cookies_ )
   {
      [ cookies_log_ appendFormat: @"Name: '%@'; Value: '%@'\n", cookie_.name, cookie_.value ];
   }

   NSLog( @"%@", cookies_log_ );
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
