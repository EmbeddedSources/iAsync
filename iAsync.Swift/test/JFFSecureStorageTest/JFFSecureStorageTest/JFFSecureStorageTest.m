
@interface JFFSecureStorageTest : GHTestCase
@end

@implementation JFFSecureStorageTest

- (void)testSecureStorage
{
    NSURL *url = [@"http://www.google.com" toURL];
    
    {
        NSString *login    = @"llll";
        NSString *password = @"ppp";
        
        jffStoreSecureCredentials(login, password, url);
        
        NSString *outLogin = nil;
        NSString *outPassword = jffGetSecureCredentialsForURL(&outLogin, url);
        
        GHAssertTrue([login    isEqualToString:outLogin   ], @"OK");
        GHAssertTrue([password isEqualToString:outPassword], @"OK");
    }
    
    {
        NSString *login    = @"llll2";
        NSString *password = @"ppp2";
        
        jffStoreSecureCredentials(login, password, url);
        
        NSURL *otherUrl = [@"http://www.google.com/other_url" toURL];
        jffStoreSecureCredentials(@"bb", @"aa", otherUrl);
        
        NSString *outLogin = nil;
        NSString *outPassword = jffGetSecureCredentialsForURL(&outLogin, url);
        
        GHAssertTrue([login    isEqualToString:outLogin   ], @"OK");
        GHAssertTrue([password isEqualToString:outPassword], @"OK");
    }
}

- (void)testNoPassword
{
    NSURL *url = [@"http://www.google.com/xxxx" toURL];
    
    NSString *outLogin = nil;
    NSString *outPassword = jffGetSecureCredentialsForURL(&outLogin, url);
    
    GHAssertNil(outLogin   , @"OK");
    GHAssertNil(outPassword, @"OK");
}

@end
