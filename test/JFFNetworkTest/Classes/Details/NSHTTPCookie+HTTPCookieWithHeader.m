#import "NSHTTPCookie+HTTPCookieWithHeader.h"

@implementation NSHTTPCookie (HTTPCookieWithHeader)

+(id)HTTPCookieWithHeader:( NSString* )header_
                      url:( NSURL* )url_
{
    if ( [ header_ length ] == 0 )
        return nil;
    
    NSDictionary* headers_ = [ NSDictionary dictionaryWithObject: header_
                                                          forKey: @"Set-Cookie" ];
    
    NSArray* cookies_ = [ NSHTTPCookie cookiesWithResponseHeaderFields: headers_
                                                                forURL: url_ ];
    
    return [ cookies_ lastObject ];
}

@end
