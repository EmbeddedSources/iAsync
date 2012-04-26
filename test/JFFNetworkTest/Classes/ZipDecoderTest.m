@interface ZipDecoderTest : GHTestCase
@end

@implementation ZipDecoderTest

-(void)testErrorParameterIsRequired
{
   NSData*   gzip_data_  = [ JNTestBundleManager loadZipFileNamed : @"1.1" ];
   
   JNZipDecoder* decoder_ = [ [ JNZipDecoder new ] autorelease ];
   
   GHAssertThrows
   (
    [ decoder_ decodeData: gzip_data_
                    error: NULL ]
    , @"NULL error should produce assert"
    );
}

-(void)testNilDataProducesNilResult
{
   NSError* error_ = nil;
   
   JNZipDecoder* decoder_ = [ [ JNZipDecoder new ] autorelease ];
   NSData* received_data_ = [ decoder_ decodeData: nil
                                            error: &error_ ];
   
   GHAssertNil( received_data_, @"Nil output expected"    );
   GHAssertNil( error_        , @"No errors are expected" );
}


//!! dodikk -- TODO : uncomment this once an appropriate test case is created
-(void)_testZipFromBackEndExtractedCorrectly
{
   NSError* error_ = nil;
   
   NSData*   gzip_data_  = [ JNTestBundleManager loadZipFileNamed : @"1.1" ];
   NSString* expected_   = [ JNTestBundleManager loadTextFileNamed: @"1.1" ];
   
   JNZipDecoder* decoder_ = [ [ JNZipDecoder new ] autorelease ];
   NSData* received_data_ = [ decoder_ decodeData: gzip_data_
                                            error: &error_ ];
   GHAssertNil( error_, @"Unexpected decode error - %@", error_ );
   
   
   NSString* received_ = [ [ [ NSString alloc ] initWithData: received_data_
                                                    encoding: NSUTF8StringEncoding ] autorelease ];
   
   GHAssertNil( error_, @"Unexpected encoding error - %@", error_ );
   
   GHAssertTrue( [ received_ isEqualToString: expected_ ], @"Wrong decoding result" );
}

-(void)testBadDataProducesCorrectError
{
   NSError* error_ = nil;
   
   NSData*   gzip_data_  = [ JNTestBundleManager loadZipFileNamed : @"1.1" ];
   
   JNZipDecoder* decoder_ = [ [ JNZipDecoder new ] autorelease ];
   NSData* received_data_ = [ decoder_ decodeData: gzip_data_
                                            error: &error_ ];
   
   GHAssertNil( received_data_, @"nil data in error Expected" );
   GHAssertTrue( [ error_.domain isEqualToString: @"gzip.error" ], @"Unexpected error domain" );
   GHAssertTrue( error_.code == Z_DATA_ERROR, @"Unexpected error code" );
}

@end
