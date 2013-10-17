#import "NSHTTPCookie+matchesURL.h"

#import "NSString+RFC_2965.h"

@implementation NSHTTPCookie (matchesURL)

- (BOOL)matchesURL:(NSURL *)url
{
    return [url.host domainMatchesCookiesDomain:self.domain]
    && [url.path pathMatchesCookiesPath:self.path];
}

@end
