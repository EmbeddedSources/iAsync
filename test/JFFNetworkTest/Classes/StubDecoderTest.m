@interface StubDecoderTest : GHTestCase
@end


@implementation StubDecoderTest

-(void)testErrorParameterIsRequired
{
   NSData*   gzip_data_  = [ JNTestBundleManager loadZipFileNamed : @"1" ];
   
   JNStubDecoder* decoder_ = [ [ JNStubDecoder new ] autorelease ];
   
   GHAssertThrows
   (
    [ decoder_ decodeData: gzip_data_
                    error: NULL ]
    , @"NULL error should produce assert"
    );
}

-(void)testStubDecoderReturnsTheSameVariable
{
   NSError*       error_         = nil;
   JNStubDecoder* decoder_       = nil;
   NSData*        received_data_ = nil;
   NSData*        gzip_data_     = nil;
   
   {
      decoder_ = [ [ JNStubDecoder new ] autorelease ];
      received_data_ = [ decoder_ decodeData: nil
                                       error: &error_ ];
      
      GHAssertNil( received_data_, @"Nil output expected"    );
      GHAssertNil( error_        , @"No errors are expected" );
   }
   
   
   {
      gzip_data_  = [ JNTestBundleManager loadZipFileNamed : @"1" ];
      
      decoder_ = [ [ JNStubDecoder new ] autorelease ];
      received_data_ = [ decoder_ decodeData: gzip_data_
                                       error: &error_ ];
      
      GHAssertTrue( received_data_ == gzip_data_, @"Same output expected"   );
      GHAssertNil ( error_                      , @"No errors are expected" );
   }
   
   
   {
      gzip_data_  = [ JNTestBundleManager loadZipFileNamed : @"1.1" ];
      
      decoder_ = [ [ JNStubDecoder new ] autorelease ];
      received_data_ = [ decoder_ decodeData: gzip_data_
                                       error: &error_ ];
      
      GHAssertTrue( received_data_ == gzip_data_, @"Same output expected"   );
      GHAssertNil ( error_                      , @"No errors are expected" );
   }   
}


@end
