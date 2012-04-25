#import "JFFSecureStorageTests.h"

#import "JFFSecureStorage.h"

@implementation JFFSecureStorageTests

-(void)setUp
{
    [ super setUp ];
    // Set-up code here.
}

-(void)tearDown
{
    // Tear-down code here.
    [ super tearDown ];
}

-(void)testExample
{
    NSURL* url_ = [ NSURL URLWithString: @"http://www.google.com" ];

    JFFSecureStorage* storage_ = [ JFFSecureStorage new ];
    [ storage_ setPassword: @"ppp"
                     login: @"llll"
                    forURL: url_ ];

    NSString* login_ = nil;
    NSString* password_ = [ storage_ passwordAndLogin: &login_
                                               forURL: url_ ];

    NSLog( @"password: %@", password_ );
    NSLog( @"url: %@", url_ );
    NSLog( @"" );

    //   STFail(@"Unit tests are not implemented yet in JFFSecureStorageTests");
}

@end
