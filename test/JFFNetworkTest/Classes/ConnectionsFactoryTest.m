@interface ConnectionsFactoryTest : GHTestCase

@end


@implementation ConnectionsFactoryTest

-(void)testUrlIsRequired
{
    char hello_[] = "Hello";
    NSData* stub_data_ = [ NSData dataWithBytesNoCopy: hello_
                                               length: sizeof( hello_ )
                                         freeWhenDone: NO ];

    NSDictionary* headers_ = [ NSDictionary dictionary ];

    GHAssertThrows
    (
     {
         JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
         params_.httpBody = stub_data_;
         params_.headers = headers_;
         id res_ = [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: params_ ];
         NSLog( @"res: %@", res_ );
     }
     , @"NSAssert expected"
    );
}

-(void)testHeadersAndDataAreOptional
{
    NSURL* google_url_ = [ NSURL URLWithString: @"www.google.com" ];

    char hello_[] = "Hello";
    NSData* stub_data_ = [ NSData dataWithBytesNoCopy: hello_
                                               length: sizeof( hello_ )
                                         freeWhenDone: NO ];
    NSDictionary* headers_ = [ NSDictionary dictionary ];

    GHAssertNoThrow
    (
     {
         JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
         params_.url = google_url_;
         params_.headers = headers_;
         id res_ = [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: params_ ];
         NSLog( @"res: %@", res_ );
     }
    , @"NSAssert expected"
    );
   
    GHAssertNoThrow
    (
     {
         JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
         params_.url = google_url_;
         params_.httpBody = stub_data_;
         id res_ = [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: params_ ];
         NSLog( @"res: %@", res_ );
     }
     , @"NSAssert expected"
     );
}

-(void)testInitNotSupported
{
   GHAssertThrows
   (
    {
        id res_ = [ [ JNConnectionsFactory alloc ] init ];
        NSLog( @"res: %@", res_ );
    }
    , @"NSAssert expected" 
   );
}

-(void)testFactoryReturnsCorrectClasses
{
    NSURL* google_url_ = [ NSURL URLWithString: @"www.yahoo.com" ];

    char hello_[] = "Abrakadabra";
    NSData* stub_data_ = [ NSData dataWithBytesNoCopy: hello_
                                               length: sizeof( hello_ )
                                         freeWhenDone: NO ];

    NSDictionary* headers_ = [ NSDictionary dictionary ];

    JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
    params_.url = google_url_;
    params_.httpBody = stub_data_;
    params_.headers = headers_;
    JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: params_ ];

    id< JNUrlConnection > connection_ = nil;

    connection_ = [ factory_ createFastConnection ];
    GHAssertTrue( [ connection_ isMemberOfClass: [ JFFURLConnection class ] ], @"Custom connection class mismatch" );

    connection_ = [ factory_ createStandardConnection ];
    GHAssertTrue( [ connection_ isMemberOfClass: [ JNNsUrlConnection class ] ], @"Standard connection class mismatch" );
}

@end
