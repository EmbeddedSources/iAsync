@interface ConnectionsFactoryTest : GHTestCase
@end

@implementation ConnectionsFactoryTest

- (void)testUrlIsRequired
{
    char hello[] = "Hello";
    NSData *stubData = [NSData dataWithBytesNoCopy:hello
                                            length:sizeof(hello)
                                      freeWhenDone:NO];
    
    NSDictionary *headers = @{};
    
    GHAssertThrows
    (
     {
         JFFURLConnectionParams *params = [JFFURLConnectionParams new];
         params.httpBody = stubData;
         params.headers = headers;
         id res = [[JNConnectionsFactory alloc] initWithURLConnectionParams:params];
         NSLog(@"res: %@", res);
     }
     , @"NSAssert expected"
     );
}

- (void)testHeadersAndDataAreOptional
{
    NSURL *googleURL = [@"www.google.com" toURL];
    
    char hello[] = "Hello";
    NSData *stubData = [NSData dataWithBytesNoCopy:hello
                                            length:sizeof(hello)
                                      freeWhenDone:NO];
    NSDictionary *headers = @{};
    
    GHAssertNoThrow
    (
     {
         JFFURLConnectionParams* params = [JFFURLConnectionParams new];
         params.url     = googleURL;
         params.headers = headers;
         id res = [[JNConnectionsFactory alloc] initWithURLConnectionParams:params];
         NSLog(@"res: %@", res);
     }
     , @"NSAssert expected"
     );
    
    GHAssertNoThrow
    (
     {
         JFFURLConnectionParams *params = [JFFURLConnectionParams new];
         params.url      = googleURL;
         params.httpBody = stubData;
         id res = [[JNConnectionsFactory alloc] initWithURLConnectionParams:params];
         NSLog(@"res: %@", res);
     }
     , @"NSAssert expected"
     );
}

- (void)testInitNotSupported
{
    GHAssertThrows
    (
     {
         id res = [JNConnectionsFactory new];
         NSLog(@"res: %@", res);
     }
     , @"NSAssert expected"
     );
}

- (void)testFactoryReturnsCorrectClasses
{
    NSURL *googleURL = [@"www.yahoo.com" toURL];
    
    char hello[] = "Abrakadabra";
    NSData *stubData = [NSData dataWithBytesNoCopy:hello
                                            length:sizeof(hello)
                                      freeWhenDone:NO ];
    
    NSDictionary *headers = @{};
    
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    params.url      = googleURL;
    params.httpBody = stubData;
    params.headers  = headers;
    JNConnectionsFactory *factory = [[JNConnectionsFactory alloc] initWithURLConnectionParams:params];
    
    id< JNUrlConnection > connection = nil;
    
    connection = [factory createFastConnection];
    GHAssertTrue([connection isMemberOfClass:[JFFURLConnection class]], @"Custom connection class mismatch");
    
    connection = [factory createStandardConnection ];
    GHAssertTrue([connection isMemberOfClass:[JNNsUrlConnection class]], @"Standard connection class mismatch");
}

@end
