#import "NSHTTPCookie+HTTPCookieWithHeader.h"

@implementation NSHTTPCookie (HTTPCookieWithHeader)

+ (instancetype)HTTPCookieWithHeader:(NSString *)header
                                 url:(NSURL *)url
{
    if ([header length] == 0)
        return nil;
    
    NSDictionary *headers = @{ @"Set-Cookie" : header };
    
    NSArray *cookies = [ NSHTTPCookie cookiesWithResponseHeaderFields:headers
                                                               forURL:url];
    
    return [cookies lastObject];
}

@end
