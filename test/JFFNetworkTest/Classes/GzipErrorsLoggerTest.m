@interface GzipErrorsLoggerTest : GHTestCase

@end

@implementation GzipErrorsLoggerTest

- (void)testGzipLoggerDoesNotAcceptValuesOutOf_minus1_minus6
{
    NSString* received_ = nil;
    NSString* expected_ = nil;
    
    {
        expected_ = @"Z_UnknownError";
        received_ = [ JNGzipErrorsLogger zipErrorMessageFromCode: 0 ];
        
        GHAssertTrue( [ expected_ isEqualToString: received_ ], @"Wrong description" );
    }
    
    {
        expected_ = @"Z_UnknownError";
        received_ = [ JNGzipErrorsLogger zipErrorMessageFromCode: -7 ];
        
        GHAssertTrue( [ expected_ isEqualToString: received_ ], @"Wrong description" );
    }
}

- (void)testGzipLoggerProducesCorrectStrings
{
    NSString* received_ = nil;
    NSString* expected_ = nil;
    
    {
        expected_ = @"Z_ERRNO";
        received_ = [ JNGzipErrorsLogger zipErrorMessageFromCode: Z_ERRNO ];
        
        GHAssertTrue( [ expected_ isEqualToString: received_ ], @"Wrong description" );
    }
    
    {
        expected_ = @"Z_STREAM_ERROR";
        received_ = [ JNGzipErrorsLogger zipErrorMessageFromCode: Z_STREAM_ERROR ];
        
        GHAssertTrue( [ expected_ isEqualToString: received_ ], @"Wrong description" );
    }
    
    {
        expected_ = @"Z_DATA_ERROR";
        received_ = [ JNGzipErrorsLogger zipErrorMessageFromCode: Z_DATA_ERROR ];
        
        GHAssertTrue( [ expected_ isEqualToString: received_ ], @"Wrong description" );
    }
    
    {
        expected_ = @"Z_MEM_ERROR";
        received_ = [ JNGzipErrorsLogger zipErrorMessageFromCode: Z_MEM_ERROR ];
        
        GHAssertTrue( [ expected_ isEqualToString: received_ ], @"Wrong description" );
    }
    
    {
        expected_ = @"Z_BUF_ERROR";
        received_ = [ JNGzipErrorsLogger zipErrorMessageFromCode: Z_BUF_ERROR ];
        
        GHAssertTrue( [ expected_ isEqualToString: received_ ], @"Wrong description" );
    }
    
    {
        expected_ = @"Z_VERSION_ERROR";
        received_ = [ JNGzipErrorsLogger zipErrorMessageFromCode: Z_VERSION_ERROR ];
        
        GHAssertTrue( [ expected_ isEqualToString: received_ ], @"Wrong description" );
    }
}

@end
