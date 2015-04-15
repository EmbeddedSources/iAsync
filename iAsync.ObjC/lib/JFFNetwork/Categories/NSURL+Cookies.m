#import "NSURL+Cookies.h"

@implementation NSURL (Cookies)

- (void)logCookies
{
    NSMutableString *cookiesLog = [[NSMutableString alloc] initWithFormat:@"Cookies for url: %@\n", self];
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self];
    for (NSHTTPCookie *cookie in cookies) {
        
        [cookiesLog appendFormat:@"Name: '%@'; Value: '%@'\n", cookie.name, cookie.value];
    }
    
    NSLog(@"%@", cookiesLog);
}

- (void)removeCookies
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self];
    for (NSHTTPCookie *cookie in cookies) {
        
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

@end
