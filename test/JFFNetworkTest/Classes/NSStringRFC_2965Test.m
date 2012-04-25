
#import <JFFNetwork/CookiesStorage/Details/NSString+RFC_2965.h>

@interface NSStringRFC_2965Test : GHTestCase
@end

@implementation NSStringRFC_2965Test

// http://tools.ietf.org/html/rfc2965
-(void)testNSStringRFC_2965Domain
{
    GHAssertTrue ( [ @"x.y.com" domainMatchesCookiesDomain: @".Y.com"  ], @"OK" );
    //domain-match is not a commutative
    GHAssertFalse( [ @".Y.com"  domainMatchesCookiesDomain: @"x.y.com" ], @"OK" );

    GHAssertFalse( [ @"x.y.com" domainMatchesCookiesDomain: @"Y.com"  ], @"OK" );
    GHAssertTrue ( [ @"y.com"   domainMatchesCookiesDomain: @".y.com" ], @"OK" );
}

-(void)testNSStringRFC_2965Path
{
    GHAssertFalse( [ @"/a/d/v" pathMatchesCookiesPath: @"" ], @"OK" );
    GHAssertFalse( [ @""       pathMatchesCookiesPath: @"" ], @"OK" );

    GHAssertTrue( [ @"/"       pathMatchesCookiesPath: @"/" ], @"OK" );
    GHAssertTrue( [ @""        pathMatchesCookiesPath: @"/" ], @"OK" );
    GHAssertTrue( [ @"asdsdsd" pathMatchesCookiesPath: @"/" ], @"OK" );
    GHAssertTrue( [ @"/a/d/v"  pathMatchesCookiesPath: @"/" ], @"OK" );

    GHAssertTrue ( [ @"/a/d/v" pathMatchesCookiesPath: @"/a" ], @"OK" );
    GHAssertFalse( [ @"/s/d/v" pathMatchesCookiesPath: @"/a" ], @"OK" );

    GHAssertTrue ( [ @"/a/B/v" pathMatchesCookiesPath: @"/a/b" ], @"OK" );
    GHAssertFalse( [ @"/a/c/v" pathMatchesCookiesPath: @"/a/b" ], @"OK" );
}

@end
