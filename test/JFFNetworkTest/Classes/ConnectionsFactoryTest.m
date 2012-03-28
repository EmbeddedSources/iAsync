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
     [ [ [ JNConnectionsFactory alloc ] initWithUrl: nil
                                           httpBody: stub_data_
                                            headers: headers_ ] autorelease ]
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
     [ [ [ JNConnectionsFactory alloc ] initWithUrl: google_url_
                                           httpBody: nil
                                            headers: headers_] autorelease ]
    , @"NSAssert expected"
    );
   
    GHAssertNoThrow
    (
     [ [ [ JNConnectionsFactory alloc ] initWithUrl: google_url_
                                           httpBody: stub_data_
                                            headers: nil ] autorelease ]
     , @"NSAssert expected"
     );
}

-(void)testInitNotSupported
{
   GHAssertThrows
   (
    [ [ [ JNConnectionsFactory alloc ] init ] autorelease ]
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

    JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithUrl: google_url_
                                                                         httpBody: stub_data_
                                                                          headers: headers_ ];
    [ factory_ autorelease ];
    id< JNUrlConnection > connection_ = nil;

    connection_ = [ factory_ createFastConnection ];
    GHAssertTrue( [ connection_ isMemberOfClass: [ JFFURLConnection class ] ], @"Custom connection class mismatch" );

    connection_ = [ factory_ createStandardConnection ];
    GHAssertTrue( [ connection_ isMemberOfClass: [ JNNsUrlConnection class ] ], @"Standard connection class mismatch" );
}

-(void)testCannotCreateAbstactConnection
{
    GHAssertThrows( [ [ JNAbstractConnection alloc ] init ] , @"NSAssert expected" );
}

@end
