#import "NSString+RFC_2965.h"

@implementation NSString (RFC_2965)

// http://tools.ietf.org/html/rfc2965

/*!
 @method domain
 @abstract Returns the domain of the receiver.
 @discussion This value specifies URL domain to which the cookie
 should be sent. A domain with a leading dot means the cookie
 should be sent to subdomains as well, assuming certain other
 restrictions are valid. See RFC 2965 for more detail.
 @result The domain of the receiver.
 */
- (BOOL)domainMatchesCookiesDomain:(NSString *)cookiesDomain
{
    NSString* domain = [self lowercaseString];
    cookiesDomain    = [cookiesDomain lowercaseString];
    
    if ([cookiesDomain length] == 0)
        return NO;
    
    if ([cookiesDomain hasPrefix:@"."]) {
        
        return [domain hasSuffix: cookiesDomain]
        || (([cookiesDomain length] - [domain length]) == 1
            && [cookiesDomain hasSuffix:domain]);
    }
    
    return [domain isEqualToString:cookiesDomain];
}

/*!
 @method path
 @abstract Returns the path of the receiver.
 @discussion This value specifies the URL path under the cookie's
 domain for which this cookie should be sent. The cookie will also
 be sent for children of that path, so "/" is the most general.
 @result The path of the receiver.
 */
- (BOOL)pathMatchesCookiesPath:(NSString *)cookiesPath
{
    if ([cookiesPath length] == 0)
        return NO;
    
    if ([cookiesPath isEqualToString:@"/"])
        return YES;
    
    NSString *path = [self lowercaseString];
    cookiesPath    = [cookiesPath lowercaseString];
    
    return [path hasPrefix:cookiesPath];
}

@end
