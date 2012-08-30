
@interface JFFSecureStorageTest : GHTestCase
@end

@implementation JFFSecureStorageTest

-(void)testSecureStorage
{
    NSURL* url_ = [ NSURL URLWithString: @"http://www.google.com" ];

    {
        NSString* login_    = @"llll";
        NSString* password_ = @"ppp";

        jffStoreSecureCredentials( login_, password_, url_ );

        NSString* outLogin_ = nil;
        NSString* outPassword_ = jffGetSecureCredentialsForURL( &outLogin_, url_ );

        GHAssertTrue( [ login_    isEqualToString: outLogin_    ], @"OK" );
        GHAssertTrue( [ password_ isEqualToString: outPassword_ ], @"OK" );
    }

    {
        NSString* login_    = @"llll2";
        NSString* password_ = @"ppp2";

        jffStoreSecureCredentials( login_, password_, url_ );

        NSURL* otherUrl_ = [ NSURL URLWithString: @"http://www.google.com/other_url" ];
        jffStoreSecureCredentials( @"bb", @"aa", otherUrl_ );

        NSString* outLogin_ = nil;
        NSString* outPassword_ = jffGetSecureCredentialsForURL( &outLogin_, url_ );

        GHAssertTrue( [ login_    isEqualToString: outLogin_    ], @"OK" );
        GHAssertTrue( [ password_ isEqualToString: outPassword_ ], @"OK" );
    }
}

-(void)testNoPassword
{
    NSURL* url_ = [ NSURL URLWithString: @"http://www.google.com/xxxx" ];

    NSString* outLogin_ = nil;
    NSString* outPassword_ = jffGetSecureCredentialsForURL( &outLogin_, url_ );

    GHAssertNil( outLogin_   , @"OK" );
    GHAssertNil( outPassword_, @"OK" );
}

@end
