@interface EncodingsFactoryTest : GHTestCase

@end


@implementation EncodingsFactoryTest

-(void)testFactoryProducesValidDecoders
{
   id<JNHttpDecoder> decoder_ = nil;

   {
      decoder_ = [ JNHttpEncodingsFactory gzipDecoder ];
      GHAssertNotNil( decoder_, @"NOT nil data Expected" );
      GHAssertTrue( [ decoder_ conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
      GHAssertTrue( [ decoder_ isMemberOfClass   : [ JNGzipDecoder class ]  ], @"This should be JNGzipDecoder class" );
   }

   {
      decoder_ = [ JNHttpEncodingsFactory decoderForHeaderString: @"gzip" ];
      GHAssertNotNil( decoder_, @"NOT nil data Expected" );
      GHAssertTrue( [ decoder_ conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
      GHAssertTrue( [ decoder_ isMemberOfClass   : [ JNGzipDecoder class ]  ], @"This should be JNGzipDecoder class" );
   }
}

-(void)testFactoryProducesStubDecoderForUnexpectedCases
{
   id<JNHttpDecoder> decoder_ = nil;

   {
      decoder_ = [ JNHttpEncodingsFactory stubDecoder ];
      GHAssertNotNil( decoder_, @"NOT nil data Expected" );
      GHAssertTrue( [ decoder_ conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
      GHAssertTrue( [ decoder_ isMemberOfClass   : [ JNStubDecoder class ]  ], @"This should be JNGzipDecoder class" );
   }   

   {
      decoder_ = [ JNHttpEncodingsFactory decoderForHeaderString: @"" ];

      GHAssertNotNil( decoder_, @"NOT nil data Expected" );
      GHAssertTrue( [ decoder_ conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
      GHAssertTrue( [ decoder_ isMemberOfClass   : [ JNStubDecoder class ]  ], @"This should be JNStubDecoder class" );
   }

   {
      decoder_ = [ JNHttpEncodingsFactory decoderForHeaderString: nil ];
      GHAssertNotNil( decoder_, @"NOT nil data Expected" );
      GHAssertTrue( [ decoder_ conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
      GHAssertTrue( [ decoder_ isMemberOfClass   : [ JNStubDecoder class ]  ], @"This should be JNStubDecoder class" );
   }

   {
      decoder_ = [ JNHttpEncodingsFactory decoderForHeaderString: @"abrakadabra" ];
      GHAssertNotNil( decoder_, @"NOT nil data Expected" );
      GHAssertTrue( [ decoder_ conformsToProtocol: @protocol(JNHttpDecoder) ], @"This class should conform protocol" );
      GHAssertTrue( [ decoder_ isMemberOfClass   : [ JNStubDecoder class ]  ], @"This should be JNStubDecoder class" );
   }
}

@end
