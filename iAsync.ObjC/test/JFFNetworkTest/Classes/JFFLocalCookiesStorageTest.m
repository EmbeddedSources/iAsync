
#import <JFFNetwork/CookiesStorage/JFFLocalCookiesStorage.h>

#import "NSHTTPCookie+HTTPCookieWithHeader.h"

@interface JFFLocalCookiesStorageTest : GHTestCase
@end

@implementation JFFLocalCookiesStorageTest

- (void)setUp
{
    NSHTTPCookieStorage* storage_ = [ NSHTTPCookieStorage sharedHTTPCookieStorage ];
    NSArray* cookies_ = [ [ storage_ cookies ] copy ];
    for ( NSHTTPCookie* cookie_ in cookies_ )
    {
        [ storage_ deleteCookie: cookie_ ];
    }
}

- (void)testHTTPCookieExparationDate
{
    NSString* header_ = @"ws-alr1.dk.sitecore.net80_sitecore_username=NOhnomXlt2B691wsxQMcKxsi6rXR2bqSc4mtScMHQWpeVVLhgvKrF91imx_37FEP0vWkKJ6X78VEl5Gx3gXPYA2; expires=Wed, 05-Aug-2012 07:21:54 GMT; path=/sitecore/login";

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

        GHAssertNil( result1Cookie_, @"OK" );
        GHAssertNil( result2Cookie_, @"OK" );
    }
}

- (void)testHTTPCookiePathMatchWithSameDomain
{
    NSDate* now_ = [NSDate distantFuture];

    NSDateFormatter* formatter_ = [ NSDateFormatter new ];
    [ formatter_ setLocale: [ [ NSLocale alloc ] initWithLocaleIdentifier: @"en_US_POSIX" ] ];
    formatter_.timeZone = [ NSTimeZone timeZoneWithName: @"GMT" ];
    formatter_.dateFormat = @"EEE, dd-MMM-YYYY hh:mm:ss";

    static NSString* const headerFormat_ = @"ws-alr1.dk.sitecore.net80_sitecore_username=NOhnomXlt2B691wsxQMcKxsi6rXR2bqSc4mtScMHQWpeVVLhgvKrF91imx_37FEP0vWkKJ6X78VEl5Gx3gXPYA2; expires=%@ GMT; path=/sitecore/login";

    NSString* header_ = [ [ NSString alloc ] initWithFormat: headerFormat_
                         , [ formatter_ stringFromDate: now_ ] ];

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

- (void)testHTTPCookieDotDomainMatch
{
    NSDate *now = [NSDate distantFuture];

    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
    formatter.timeZone = [[NSTimeZone alloc]initWithName:@"GMT"];
    formatter.dateFormat = @"EEE, dd-MMM-YYYY hh:mm:ss";

    static NSString* const headerFormat_ = @"ws-alr1.dk.sitecore.net80_sitecore_username=NOhnomXlt2B691wsxQMcKxsi6rXR2bqSc4mtScMHQWpeVVLhgvKrF91imx_37FEP0vWkKJ6X78VEl5Gx3gXPYA2; expires=%@ GMT; Domain=sitecore.net; path=/";

    NSString* header_ = [[NSString alloc]initWithFormat:headerFormat_
                         , [formatter stringFromDate:now]];

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

- (void)testHTTPCookieNoDotDomainMatch
{
    NSDate* now_ = [NSDate distantFuture];
    
    NSDateFormatter* formatter_ = [ NSDateFormatter new ];
    [ formatter_ setLocale: [ [ NSLocale alloc ] initWithLocaleIdentifier: @"en_US_POSIX" ] ];
    formatter_.timeZone = [ NSTimeZone timeZoneWithName: @"GMT" ];
    formatter_.dateFormat = @"EEE, dd-MMM-YYYY hh:mm:ss";

    static NSString* const headerFormat_ = @"sitecore.net80_sitecore_username=NOhnomXlt2B691wsxQMcKxsi6rXR2bqSc4mtScMHQWpeVVLhgvKrF91imx_37FEP0vWkKJ6X78VEl5Gx3gXPYA2; expires=%@ GMT; path=/";

    NSString* header_ = [ [ NSString alloc ] initWithFormat: headerFormat_
                         , [ formatter_ stringFromDate: now_ ] ];

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
