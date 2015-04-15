#import <JFFNetwork/Detail/NSURL+URLWithLocation.h>

@interface URLWithLocationTest : GHTestCase
@end

@implementation URLWithLocationTest

-(void)testBuildURLWithNewLocation
{
    NSURL* url_ = [ NSURL URLWithString: @"http://www.google.com/a/b/c" ];

    url_ = [ url_ URLWithLocation: @"/c/d/e" ];

    GHAssertEqualObjects( [ url_ description ], @"http://www.google.com/c/d/e", @"NO" );
}

-(void)testBuildURLWithNewLocationAndPort
{
    NSURL* url_ = [ NSURL URLWithString: @"http://www.google.com:8080/a/b/c" ];

    url_ = [ url_ URLWithLocation: @"/c/d/e" ];

    GHAssertEqualObjects( [ url_ description ], @"http://www.google.com:8080/c/d/e", @"NO" );
}

-(void)testBuildHttpsURLWithNewLocation
{
    NSURL* url_ = [ NSURL URLWithString: @"https://www.google.com:8080/a/b/c" ];

    url_ = [ url_ URLWithLocation: @"/c/d/e" ];

    GHAssertEqualObjects( [ url_ description ], @"https://www.google.com:8080/c/d/e", @"NO" );
}

-(void)testBuildURLWithNewLocationLogin
{
    NSURL* url_ = [ NSURL URLWithString: @"http://login@www.google.com/a/b/c" ];

    url_ = [ url_ URLWithLocation: @"/c/d/e" ];

    GHAssertEqualObjects( [ url_ description ], @"http://login@www.google.com/c/d/e", @"NO" );
}

//ftp://username:password@hostname/

-(void)testBuildURLWithNewLocationLoginAndPassword
{
    NSURL* url_ = [ NSURL URLWithString: @"http://login:password@www.google.com/a/b/c" ];

    url_ = [ url_ URLWithLocation: @"/c/d/e" ];

    GHAssertEqualObjects( [ url_ description ], @"http://login:password@www.google.com/c/d/e", @"NO" );
}

@end
