
#import <JFFNetwork/ContentEncodings/JNHttpEncodingsFactory.h>

@interface EncodingsFactoryTest : GHTestCase
@end

@implementation EncodingsFactoryTest
{
    JNHttpEncodingsFactory* _factory;
}

-(void)setUp
{
    self->_factory = [ [ JNHttpEncodingsFactory alloc ] initWithContentLength: 0 ];
}

-(void)testFactoryProducesValidDecoders
{
   id<JNHttpDecoder> decoder_ = nil;

   {
      decoder_ = [ _factory gzipDecoder ];
      GHAssertNotNil( decoder_, @"NOT nil data Expected" );
      GHAssertTrue( [ decoder_ conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
      GHAssertTrue( [ decoder_ isMemberOfClass   : [ JNGzipDecoder class ]  ], @"This should be JNGzipDecoder class" );
   }

   {
      decoder_ = [ _factory decoderForHeaderString: @"gzip" ];
      GHAssertNotNil( decoder_, @"NOT nil data Expected" );
      GHAssertTrue( [ decoder_ conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
      GHAssertTrue( [ decoder_ isMemberOfClass   : [ JNGzipDecoder class ]  ], @"This should be JNGzipDecoder class" );
   }
}

-(void)testFactoryProducesStubDecoderForUnexpectedCases
{
   id<JNHttpDecoder> decoder_ = nil;

   {
      decoder_ = [ _factory stubDecoder ];
      GHAssertNotNil( decoder_, @"NOT nil data Expected" );
      GHAssertTrue( [ decoder_ conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
      GHAssertTrue( [ decoder_ isMemberOfClass   : [ JNStubDecoder class ]  ], @"This should be JNGzipDecoder class" );
   }   

   {
      decoder_ = [ _factory decoderForHeaderString: @"" ];

      GHAssertNotNil( decoder_, @"NOT nil data Expected" );
      GHAssertTrue( [ decoder_ conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
      GHAssertTrue( [ decoder_ isMemberOfClass   : [ JNStubDecoder class ]  ], @"This should be JNStubDecoder class" );
   }

   {
      decoder_ = [ _factory decoderForHeaderString: nil ];
      GHAssertNotNil( decoder_, @"NOT nil data Expected" );
      GHAssertTrue( [ decoder_ conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
      GHAssertTrue( [ decoder_ isMemberOfClass   : [ JNStubDecoder class ]  ], @"This should be JNStubDecoder class" );
   }

   {
      decoder_ = [ _factory decoderForHeaderString: @"abrakadabra" ];
      GHAssertNotNil( decoder_, @"NOT nil data Expected" );
      GHAssertTrue( [ decoder_ conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
      GHAssertTrue( [ decoder_ isMemberOfClass   : [ JNStubDecoder class ]  ], @"This should be JNStubDecoder class" );
   }
}

@end
