
#import <JFFNetwork/CookiesStorage/JFFLocalCookiesStorage.h>

#import "NSHTTPCookie+HTTPCookieWithHeader.h"

@interface JFFLocalCookiesStorageTest : GHTestCase
@end

@implementation JFFLocalCookiesStorageTest

-(void)setUp
{
    NSHTTPCookieStorage* storage_ = [ NSHTTPCookieStorage sharedHTTPCookieStorage ];
    NSArray* cookies_ = [ [ storage_ cookies ] copy ];
    for ( NSHTTPCookie* cookie_ in cookies_ )
    {
        [ storage_ deleteCookie: cookie_ ];
    }
}

-(void)testHTTPCookiePathMatchWithSameDomain
{
    NSString* header_ = @"ws-alr1.dk.sitecore.net80_sitecore_username=NOhnomXlt2B691wsxQMcKxsi6rXR2bqSc4mtScMHQWpeVVLhgvKrF91imx_37FEP0vWkKJ6X78VEl5Gx3gXPYA2; expires=Wed, 25-Jul-2012 07:21:54 GMT; path=/sitecore/login";

    NSURL* url_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net/sitecore/login" ];

    NSHTTPCookie* cookie_ = [ NSHTTPCookie HTTPCookieWithHeader: header_ url: url_ ];

    NSHTTPCookieStorage   * storage_      = [ NSHTTPCookieStorage sharedHTTPCookieStorage ];
    JFFLocalCookiesStorage* localStorage_ = [ JFFLocalCookiesStorage new ];

    //set cookies_
    {
        [ storage_      setCookie: cookie_ ];
        [ localStorage_ setCookie: cookie_ ];
    }

    //get cookie for url_
    {
        NSHTTPCookie* result1Cookie_ = [ [ storage_      cookiesForURL: url_ ] lastObject ];
        NSHTTPCookie* result2Cookie_ = [ [ localStorage_ cookiesForURL: url_ ] lastObject ];

        GHAssertNotNil( result1Cookie_, @"OK" );
        GHAssertNotNil( result2Cookie_, @"OK" );
    }
   
    NSURL* subLoginUrl_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net/sitecore/login/xxxx" ];
    //get cookie for subLoginUrl_
    {
        NSHTTPCookie* result1Cookie_ = [ [ storage_      cookiesForURL: subLoginUrl_ ] lastObject ];
        NSHTTPCookie* result2Cookie_ = [ [ localStorage_ cookiesForURL: subLoginUrl_ ] lastObject ];

        GHAssertNotNil( result1Cookie_, @"OK" );
        GHAssertNotNil( result2Cookie_, @"OK" );
    }

    NSURL* rootLoginUrl_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net/sitecore" ];
    //get cookie for rootLoginUrl_
    {
        NSHTTPCookie* result1Cookie_ = [ [ storage_      cookiesForURL: rootLoginUrl_ ] lastObject ];
        NSHTTPCookie* result2Cookie_ = [ [ localStorage_ cookiesForURL: rootLoginUrl_ ] lastObject ];

        GHAssertNil( result1Cookie_, @"OK" );
        GHAssertNil( result2Cookie_, @"OK" );
    }

    NSURL* rootUrl_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net" ];
    //get cookie for rootUrl_
    {
        NSHTTPCookie* result1Cookie_ = [ [ storage_      cookiesForURL: rootUrl_ ] lastObject ];
        NSHTTPCookie* result2Cookie_ = [ [ localStorage_ cookiesForURL: rootUrl_ ] lastObject ];

        GHAssertNil( result1Cookie_, @"OK" );
        GHAssertNil( result2Cookie_, @"OK" );
    }
}

-(void)testHTTPCookieDotDomainMatch
{
    NSString* header_ = @"ws-alr1.dk.sitecore.net80_sitecore_username=NOhnomXlt2B691wsxQMcKxsi6rXR2bqSc4mtScMHQWpeVVLhgvKrF91imx_37FEP0vWkKJ6X78VEl5Gx3gXPYA2; expires=Wed, 25-Jul-2012 07:21:54 GMT; Domain=sitecore.net; path=/";

    NSURL* url_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net/sitecore/login" ];

    NSHTTPCookie* cookie_ = [ NSHTTPCookie HTTPCookieWithHeader: header_ url: url_ ];

    NSHTTPCookieStorage   * storage_      = [ NSHTTPCookieStorage sharedHTTPCookieStorage ];
    JFFLocalCookiesStorage* localStorage_ = [ JFFLocalCookiesStorage new ];

    //set cookies_
    {
        [ storage_      setCookie: cookie_ ];
        [ localStorage_ setCookie: cookie_ ];
    }

    //get cookie for url_
    {
        NSHTTPCookie* result1Cookie_ = [ [ storage_      cookiesForURL: url_ ] lastObject ];
        NSHTTPCookie* result2Cookie_ = [ [ localStorage_ cookiesForURL: url_ ] lastObject ];

        GHAssertNotNil( result1Cookie_, @"OK" );
        GHAssertNotNil( result2Cookie_, @"OK" );
    }

    NSURL* subLoginUrl_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net/sitecore/login/xxx" ];
    //get cookie for subLoginUrl_
    {
        NSHTTPCookie* result1Cookie_ = [ [ storage_      cookiesForURL: subLoginUrl_ ] lastObject ];
        NSHTTPCookie* result2Cookie_ = [ [ localStorage_ cookiesForURL: subLoginUrl_ ] lastObject ];

        GHAssertNotNil( result1Cookie_, @"OK" );
        GHAssertNotNil( result2Cookie_, @"OK" );
    }

    NSURL* rootLoginUrl_ = [ NSURL URLWithString: @"http://sitecore.net/sitecore" ];
    //get cookie for rootLoginUrl_
    {
        NSHTTPCookie* result1Cookie_ = [ [ storage_      cookiesForURL: rootLoginUrl_ ] lastObject ];
        NSHTTPCookie* result2Cookie_ = [ [ localStorage_ cookiesForURL: rootLoginUrl_ ] lastObject ];

        GHAssertNotNil( result1Cookie_, @"OK" );
        GHAssertNotNil( result2Cookie_, @"OK" );
    }

    NSURL* rootUrl_ = [ NSURL URLWithString: @"http://dk.sitecore.net" ];
    //get cookie for rootUrl_
    {
        NSHTTPCookie* result1Cookie_ = [ [ storage_      cookiesForURL: rootUrl_ ] lastObject ];
        NSHTTPCookie* result2Cookie_ = [ [ localStorage_ cookiesForURL: rootUrl_ ] lastObject ];

        GHAssertNotNil( result1Cookie_, @"OK" );
        GHAssertNotNil( result2Cookie_, @"OK" );
    }
}

-(void)testHTTPCookieNoDotDomainMatch
{
    NSString* header_ = @"sitecore.net80_sitecore_username=NOhnomXlt2B691wsxQMcKxsi6rXR2bqSc4mtScMHQWpeVVLhgvKrF91imx_37FEP0vWkKJ6X78VEl5Gx3gXPYA2; expires=Wed, 25-Jul-2012 07:21:54 GMT; path=/";

    NSURL* url_ = [ NSURL URLWithString: @"http://sitecore.net/sitecore/login" ];

    NSHTTPCookie* cookie_ = [ NSHTTPCookie HTTPCookieWithHeader: header_ url: url_ ];

    NSHTTPCookieStorage   * storage_      = [ NSHTTPCookieStorage sharedHTTPCookieStorage ];
    JFFLocalCookiesStorage* localStorage_ = [ JFFLocalCookiesStorage new ];

    //set cookies_
    {
        [ storage_      setCookie: cookie_ ];
        [ localStorage_ setCookie: cookie_ ];
    }

    //get cookie for url_
    {
        NSHTTPCookie* result1Cookie_ = [ [ storage_      cookiesForURL: url_ ] lastObject ];
        NSHTTPCookie* result2Cookie_ = [ [ localStorage_ cookiesForURL: url_ ] lastObject ];

        GHAssertNotNil( result1Cookie_, @"OK" );
        GHAssertNotNil( result2Cookie_, @"OK" );
    }

    NSURL* subLoginUrl_ = [ NSURL URLWithString: @"http://ws-alr1.dk.sitecore.net/sitecore/login/xxx" ];
    //get cookie for subLoginUrl_
    {
        NSHTTPCookie* result1Cookie_ = [ [ storage_      cookiesForURL: subLoginUrl_ ] lastObject ];
        NSHTTPCookie* result2Cookie_ = [ [ localStorage_ cookiesForURL: subLoginUrl_ ] lastObject ];

        GHAssertNil( result1Cookie_, @"OK" );
        GHAssertNil( result2Cookie_, @"OK" );
    }

    NSURL* rootLoginUrl_ = [ NSURL URLWithString: @"http://sitecore.net/sitecore" ];
    //get cookie for rootLoginUrl_
    {
        NSHTTPCookie* result1Cookie_ = [ [ storage_      cookiesForURL: rootLoginUrl_ ] lastObject ];
        NSHTTPCookie* result2Cookie_ = [ [ localStorage_ cookiesForURL: rootLoginUrl_ ] lastObject ];

        GHAssertNotNil( result1Cookie_, @"OK" );
        GHAssertNotNil( result2Cookie_, @"OK" );
    }

    NSURL* rootUrl_ = [ NSURL URLWithString: @"http://dk.sitecore.net" ];
    //get cookie for rootUrl_
    {
        NSHTTPCookie* result1Cookie_ = [ [ storage_      cookiesForURL: rootUrl_ ] lastObject ];
        NSHTTPCookie* result2Cookie_ = [ [ localStorage_ cookiesForURL: rootUrl_ ] lastObject ];

        GHAssertNil( result1Cookie_, @"OK" );
        GHAssertNil( result2Cookie_, @"OK" );
    }
}

@end
