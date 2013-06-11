#import "JNGzipDecoder.h"

#import "JNGzipErrorsLogger.h"
#import "JNGzipCustomErrors.h"
#import "JNConstants.h"

NSString* kGzipErrorDomain = @"gzip.error";

@implementation JNGzipDecoder

//http://www.cocoadev.com/index.pl?NSDataCategory
- (NSData *)decodeData:(NSData *)encodedData_
                 error:(NSError **)outError
{
    NSParameterAssert(outError);
    *outError = nil;
    
    if ( 0 == [ encodedData_ length ] ) 
    {
        return encodedData_;
    }
    
    NSUInteger full_length_ = [ encodedData_ length ];
    NSUInteger half_length_ = [ encodedData_ length ] / 2;
    
    NSMutableData* decompressed_ = [ NSMutableData dataWithLength: full_length_ + half_length_ ];
    BOOL done_   = NO;
    int  status_ = 0 ;
    
    z_stream strm  = {0};
    strm.next_in   = (Bytef *)[ encodedData_ bytes ];
    strm.avail_in  = (uInt)[ encodedData_ length ];
    strm.total_out = 0;
    strm.zalloc    = Z_NULL;
    strm.zfree     = Z_NULL;
    
    //!! dodikk -- WTF Magic
    if ( inflateInit2( &strm, (15+32) ) != Z_OK ) 
    {
        [JFFLogger logErrorWithFormat:@"JNGzipDecoder -- inflateInit2 failed"];
        
        *outError = [ NSError errorWithDomain: kGzipErrorDomain
                                       code: kJNGzipInitFailed
                                   userInfo: nil ];
        return nil;
    }
    while (!done_)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed_ length])
        {
            [decompressed_ increaseLengthBy: half_length_];
        }
        strm.next_out = [decompressed_ mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)( [decompressed_ length] - strm.total_out );

        // Inflate another chunk.
        status_ = inflate (&strm, Z_SYNC_FLUSH);
        if (status_ == Z_STREAM_END) 
        {
            done_ = YES;
        }
        else if (status_ != Z_OK)
        {
            break;
        }
    }
    
    if (inflateEnd (&strm) != Z_OK) 
    {
        NSLog( @"[!!! WARNING !!!] JNZipDecoder -- unexpected EOF" );
      
        *outError = [NSError errorWithDomain:kGzipErrorDomain
                                        code:kJNGzipUnexpectedEOF
                                    userInfo:nil];

        return nil;
    }
    
    // Set real length.
    if (done_)
    {
        [ decompressed_ setLength: strm.total_out ];
        return [ NSData dataWithData: decompressed_ ];
    }
    
    NSLog(@"[!!! WARNING !!!] JNZipDecoder -- unzip action has failed.\n Zip error code -- %d\n Zip error -- %@",
          status_,
          [ JNGzipErrorsLogger zipErrorMessageFromCode: status_ ] );
    
    *outError = [NSError errorWithDomain:kGzipErrorDomain
                                    code:status_
                                userInfo:nil];
    
    return nil;
}

@end
