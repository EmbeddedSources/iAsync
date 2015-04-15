@interface GzipDecoderTest : GHTestCase
@end


@implementation GzipDecoderTest

- (void)testErrorParameterIsRequired
{
    NSData *gzipData  = [JNTestBundleManager loadZipFileNamed:@"1"];
    
    JNGzipDecoder* decoder = [[JNGzipDecoder alloc] initWithContentLength:100500];
    
    GHAssertThrows
    (
     [decoder decodeData:gzipData
                   error:NULL]
     , @"NULL error should produce assert"
     );
}

- (void)testNilDataProducesNilResult
{
    NSError *error = nil;
    
    JNGzipDecoder *decoder = [[JNGzipDecoder alloc] initWithContentLength:100500];
    NSData *receivedData = [decoder decodeData:nil
                                         error:&error];
    
    GHAssertNil(receivedData, @"Nil output expected"   );
    GHAssertNil(error       , @"No errors are expected");
}

- (void)testGzipFromBackEndExtractedCorrectly
{
    NSError *error = nil;
    
    NSData   *gzipData = [JNTestBundleManager loadZipFileNamed :@"1"];
    NSString *expected = [JNTestBundleManager loadTextFileNamed:@"1"];
    
    JNGzipDecoder* decoder_ = [[JNGzipDecoder alloc] initWithContentLength:1];
    NSData *receivedData = [decoder_ decodeData:gzipData
                                          error:&error];
    GHAssertNil(error, @"Unexpected decode error - %@", error);
    
    NSString *received = [[NSString alloc] initWithData:receivedData
                                               encoding:NSUTF8StringEncoding];
    
    GHAssertTrue([received isEqualToString: expected ], @"Wrong decoding result" );
}

- (void)testBadDataProducesCorrectError
{
    NSError       *error        = nil;
    NSData        *gzipData     = nil;
    NSData        *receivedData = nil;
    JNGzipDecoder *decoder      = nil;
    
    {
        //compressed with zip instead of gzip
        gzipData  = [JNTestBundleManager loadZipFileNamed:@"1.1"];
        decoder   = [[JNGzipDecoder alloc] initWithContentLength:[gzipData length]];
        
        receivedData = [decoder decodeData:gzipData
                                     error:&error];
        
        GHAssertNil( receivedData, @"nil data in error Expected" );
        
        GHAssertTrue( [ error.domain isEqualToString: kGzipErrorDomain ], @"Unexpected error domain" );
        GHAssertTrue( error.code == Z_DATA_ERROR, @"Unexpected error code" );
    }
    
    {
        //compressed with zip instead of gzip
        gzipData  = [JNTestBundleManager loadZipFileNamed:@"1-Incomplete"];
        decoder = [[JNGzipDecoder alloc] initWithContentLength: [gzipData length]];
        
        receivedData = [decoder decodeData:gzipData
                                     error:&error];
        
        GHAssertNotNil(receivedData, @"nil data in error Expected");
        GHAssertNil(error, @"No error expected since on-the-fly unpacking was introduced ");
    }
}

@end
