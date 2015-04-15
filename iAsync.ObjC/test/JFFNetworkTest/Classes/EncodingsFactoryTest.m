
#import <JFFNetwork/ContentEncodings/JNHttpEncodingsFactory.h>

@interface EncodingsFactoryTest : GHTestCase
@end

@implementation EncodingsFactoryTest
{
    JNHttpEncodingsFactory* _factory;
}

- (void)setUp
{
    _factory = [[JNHttpEncodingsFactory alloc] initWithContentLength:0];
}

- (void)testFactoryProducesValidDecoders
{
    id<JNHttpDecoder> decoder = nil;
    
    {
        decoder = [ _factory gzipDecoder ];
        GHAssertNotNil( decoder, @"NOT nil data Expected" );
        GHAssertTrue( [ decoder conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
        GHAssertTrue( [ decoder isMemberOfClass   : [ JNGzipDecoder class ]  ], @"This should be JNGzipDecoder class" );
    }
    
    {
        decoder = [ _factory decoderForHeaderString: @"gzip" ];
        GHAssertNotNil( decoder, @"NOT nil data Expected" );
        GHAssertTrue( [ decoder conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
        GHAssertTrue( [ decoder isMemberOfClass   : [ JNGzipDecoder class ]  ], @"This should be JNGzipDecoder class" );
    }
}

- (void)testFactoryProducesStubDecoderForUnexpectedCases
{
    id<JNHttpDecoder> decoder = nil;
    
    {
        decoder = [ _factory stubDecoder ];
        GHAssertNotNil(decoder, @"NOT nil data Expected" );
        GHAssertTrue([decoder conformsToProtocol: @protocol(JNHttpDecoder)], @"This class should conform protocol");
        GHAssertTrue([decoder isMemberOfClass   : [JNStubDecoder class]], @"This should be JNGzipDecoder class");
    }
    
    {
        decoder = [ _factory decoderForHeaderString: @"" ];
        
        GHAssertNotNil( decoder, @"NOT nil data Expected" );
        GHAssertTrue( [ decoder conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
        GHAssertTrue( [ decoder isMemberOfClass   : [ JNStubDecoder class ]  ], @"This should be JNStubDecoder class" );
    }
    
    {
        decoder = [ _factory decoderForHeaderString: nil ];
        GHAssertNotNil( decoder, @"NOT nil data Expected" );
        GHAssertTrue( [ decoder conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
        GHAssertTrue( [ decoder isMemberOfClass   : [ JNStubDecoder class ]  ], @"This should be JNStubDecoder class" );
    }
    
    {
        decoder = [ _factory decoderForHeaderString: @"abrakadabra" ];
        GHAssertNotNil( decoder, @"NOT nil data Expected" );
        GHAssertTrue( [ decoder conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
        GHAssertTrue( [ decoder isMemberOfClass   : [ JNStubDecoder class ]  ], @"This should be JNStubDecoder class" );
    }
}

@end
