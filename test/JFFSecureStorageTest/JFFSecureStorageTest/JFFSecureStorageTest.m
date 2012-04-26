
@interface JFFSecureStorageTest : GHTestCase
@end

@implementation JFFSecureStorageTest

-(void)testSecureStorage
{
    NSURL* url_ = [ NSURL URLWithString: @"http://www.google.com" ];

    {
        NSString* login_    = @"llll";
        NSString* password_ = @"ppp";

        JFFSecureStorage* storage_ = [ JFFSecureStorage new ];
        [ storage_ setPassword: password_
                         login: login_
                        forURL: url_ ];

        NSString* outLogin_ = nil;
        NSString* outPassword_ = [ storage_ passwordAndLogin: &outLogin_
                                                      forURL: url_ ];

        GHAssertTrue( [ login_    isEqualToString: outLogin_    ], @"OK" );
        GHAssertTrue( [ password_ isEqualToString: outPassword_ ], @"OK" );
    }

    {
        NSString* login_    = @"llll2";
        NSString* password_ = @"ppp2";

        JFFSecureStorage* storage_ = [ JFFSecureStorage new ];
        [ storage_ setPassword: password_
                         login: login_
                        forURL: url_ ];

        NSURL* otherUrl_ = [ NSURL URLWithString: @"http://www.google.com/other_url" ];
        [ storage_ setPassword: @"aa"
                         login: @"bb"
                        forURL: otherUrl_ ];

        NSString* outLogin_ = nil;
        NSString* outPassword_ = [ storage_ passwordAndLogin: &outLogin_
                                                      forURL: url_ ];

        GHAssertTrue( [ login_    isEqualToString: outLogin_    ], @"OK" );
        GHAssertTrue( [ password_ isEqualToString: outPassword_ ], @"OK" );
    }
}

-(void)testNoPassword
{
    NSURL* url_ = [ NSURL URLWithString: @"http://www.google.com/xxxx" ];

    JFFSecureStorage* storage_ = [ JFFSecureStorage new ];

    NSString* outLogin_ = nil;
    NSString* outPassword_ = [ storage_ passwordAndLogin: &outLogin_
                                                  forURL: url_ ];
    
    GHAssertNil( outLogin_   , @"OK" );
    GHAssertNil( outPassword_, @"OK" );
}

@end
