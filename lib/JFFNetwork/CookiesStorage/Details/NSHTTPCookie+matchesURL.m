#import "NSHTTPCookie+matchesURL.h"

#import "NSString+RFC_2965.h"

@implementation NSHTTPCookie (matchesURL)

-(BOOL)matchesURL:( NSURL* )url_
{
    return [ url_.host domainMatchesCookiesDomain: self.domain ]
        && [ url_.path pathMatchesCookiesPath    : self.path   ];
}

@end
