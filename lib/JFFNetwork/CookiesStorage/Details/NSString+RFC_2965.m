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
-(BOOL)domainMatchesCookiesDomain:( NSString* )cookiesDomain_
{
    NSString* domain_ = [ self lowercaseString ];
    cookiesDomain_    = [ cookiesDomain_ lowercaseString ];

    if ( [ cookiesDomain_ length ] == 0 )
        return NO;

    if ( [ cookiesDomain_ hasPrefix: @"." ] )
    {
        return [ domain_ hasSuffix: cookiesDomain_ ]
        || ( ( [ cookiesDomain_ length ] - [ domain_ length ] ) == 1
            && [ cookiesDomain_ hasSuffix: domain_ ] );
    }

    return [ domain_ isEqualToString: cookiesDomain_ ];
}

/*!
 @method path
 @abstract Returns the path of the receiver.
 @discussion This value specifies the URL path under the cookie's
 domain for which this cookie should be sent. The cookie will also
 be sent for children of that path, so "/" is the most general.
 @result The path of the receiver.
 */
-(BOOL)pathMatchesCookiesPath:( NSString* )cookiesPath_
{
    if ( [ cookiesPath_ length ] == 0 )
        return NO;

    if ( [ cookiesPath_ isEqualToString: @"/" ] )
        return YES;

    NSString* path_ = [ self lowercaseString ];
    cookiesPath_    = [ cookiesPath_ lowercaseString ];

    return [ path_ hasPrefix: cookiesPath_ ];
}

@end
