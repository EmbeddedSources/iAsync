
#import <JFFNetwork/Categories/NSHTTPCookie+MatchesURL.h>

#import "NSHTTPCookie+HTTPCookieWithHeader.h"

@interface NSHTTPCookieMatchesURLTest : GHTestCase
@end

@implementation NSHTTPCookieMatchesURLTest

- (void)testHTTPCookiematchesWithEmptyUrl
{
    NSString* header_ = @"ws-alr1.dk.sitecore.net80_sitecore_username=NOhnomXlt2B691wsxQMcKxsi6rXR2bqSc4mtScMHQWpeVVLhgvKrF91imx_37FEP0vWkKJ6X78VEl5Gx3gXPYA2; expires=Wed, 25-Jul-2012 07:21:54 GMT; path=/sitecore/login";
    
    NSHTTPCookie* cookie_ = [ NSHTTPCookie HTTPCookieWithHeader: header_ url: nil ];
    
    GHAssertNil( cookie_, @"OK" );
}

- (void)testHTTPCookiematchesWithEmptyUrlAndDomain
{
    NSString* header_ = @"ws-alr1.dk.sitecore.net80_sitecore_username=NOhnomXlt2B691wsxQMcKxsi6rXR2bqSc4mtScMHQWpeVVLhgvKrF91imx_37FEP0vWkKJ6X78VEl5Gx3gXPYA2; expires=Wed, 25-Jul-2012 07:21:54 GMT; Domain=ws-alr1.dk.sitecore.net; path=/sitecore/login";
    
    NSHTTPCookie* cookie_ = [ NSHTTPCookie HTTPCookieWithHeader: header_ url: nil ];
    
    GHAssertNil( cookie_, @"OK" );
}

- (void)testHTTPCookiePathMatchWithSameDomain
{
    NSString *header_ = @"ws-alr1.dk.sitecore.net80_sitecore_username=NOhnomXlt2B691wsxQMcKxsi6rXR2bqSc4mtScMHQWpeVVLhgvKrF91imx_37FEP0vWkKJ6X78VEl5Gx3gXPYA2; expires=Wed, 25-Jul-2012 07:21:54 GMT; path=/sitecore/login";
    
    NSURL *url_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net/sitecore/login" ];
    
    NSHTTPCookie *cookie_ = [NSHTTPCookie HTTPCookieWithHeader:header_ url:url_];
    
    GHAssertTrue ( [ cookie_.domain isEqualToString: @"ws-alr1.dk.sitecore.net" ], @"OK" );
    GHAssertTrue ( [ cookie_.path isEqualToString: @"/sitecore/login" ], @"OK" );

    GHAssertTrue( [ cookie_ matchesURL: url_ ], @"OK" );

    NSURL* subLoginUrl_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net/sitecore/login/xxxx" ];
    GHAssertTrue( [ cookie_ matchesURL: subLoginUrl_ ], @"OK" );

    NSURL* rootLoginUrl_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net/sitecore" ];
    GHAssertFalse( [ cookie_ matchesURL: rootLoginUrl_ ], @"OK" );

    NSURL* rootUrl_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net" ];
    GHAssertFalse( [ cookie_ matchesURL: rootUrl_ ], @"OK" );
}

- (void)testHTTPCookieDotDomainMatch
{
    NSString* header_ = @"ws-alr1.dk.sitecore.net80_sitecore_username=NOhnomXlt2B691wsxQMcKxsi6rXR2bqSc4mtScMHQWpeVVLhgvKrF91imx_37FEP0vWkKJ6X78VEl5Gx3gXPYA2; expires=Wed, 25-Jul-2012 07:21:54 GMT; Domain=sitecore.net; path=/";

    NSURL* url_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net/sitecore/login" ];

    NSHTTPCookie* cookie_ = [ NSHTTPCookie HTTPCookieWithHeader: header_ url: url_ ];

    GHAssertTrue ( [ cookie_.domain isEqualToString: @".sitecore.net" ], @"OK" );
    GHAssertTrue ( [ cookie_.path isEqualToString  : @"/"             ], @"OK" );

    GHAssertTrue( [ cookie_ matchesURL: url_ ], @"OK" );

    NSURL* subLoginUrl_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net/sitecore/login/xxx" ];
    GHAssertTrue( [ cookie_ matchesURL: subLoginUrl_ ], @"OK" );

    NSURL* rootLoginUrl_ = [ NSURL URLWithString: @"http://sitecore.net/sitecore" ];
    GHAssertTrue( [ cookie_ matchesURL: rootLoginUrl_ ], @"OK" );

    NSURL* rootUrl_ = [ NSURL URLWithString: @"http://dk.sitecore.net" ];
    GHAssertTrue( [ cookie_ matchesURL: rootUrl_ ], @"OK" );
}

- (void)testHTTPCookieNoDotDomainMatch
{
    NSString* header_ = @"sitecore.net80_sitecore_username=NOhnomXlt2B691wsxQMcKxsi6rXR2bqSc4mtScMHQWpeVVLhgvKrF91imx_37FEP0vWkKJ6X78VEl5Gx3gXPYA2; expires=Wed, 25-Jul-2012 07:21:54 GMT; path=/";

    NSURL* url_ = [ NSURL URLWithString: @"http://sitecore.net/sitecore/login" ];

    NSHTTPCookie* cookie_ = [ NSHTTPCookie HTTPCookieWithHeader: header_ url: url_ ];

    GHAssertTrue ( [ cookie_.domain isEqualToString: @"sitecore.net" ], @"OK" );
    GHAssertTrue ( [ cookie_.path isEqualToString  : @"/"             ], @"OK" );

    GHAssertTrue( [ cookie_ matchesURL: url_ ], @"OK" );

    NSURL* subLoginUrl_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net/sitecore/login/xxx" ];
    GHAssertFalse( [ cookie_ matchesURL: subLoginUrl_ ], @"OK" );

    NSURL* rootLoginUrl_ = [ NSURL URLWithString: @"http://sitecore.net/sitecore" ];
    GHAssertTrue( [ cookie_ matchesURL: rootLoginUrl_ ], @"OK" );

    NSURL* rootUrl_ = [ NSURL URLWithString: @"http://dk.sitecore.net" ];
    GHAssertFalse( [ cookie_ matchesURL: rootUrl_ ], @"OK" );
}

@end
