#import "JNZipDecoder.h"
#import "JNGzipCustomErrors.h"

#import "JNConstants.h"
#import "JNGzipErrorsLogger.h"

#include <zconf.h>

@implementation JNZipDecoder

-(NSData*)decodeData:( NSData*   )encoded_data_
               error:( NSError** )error_
{
    NSParameterAssert( error_ );
    *error_ = nil;
    if (nil == encoded_data_) {
        return nil;
    }
    
    Bytef decoded_buffer_[ kJNMaxBufferSize ] = {0};
    uLongf decoded_size_ = kJNMaxBufferSize;
    
    int uncompress_result_ = uncompress( decoded_buffer_    , &decoded_size_        ,
                                         encoded_data_.bytes, encoded_data_.length );
    
    if ( Z_OK != uncompress_result_ ) {
        NSLog( @"[!!! WARNING !!!] JNZipDecoder -- unzip action has failed.\n Zip error code -- %d\n Zip error -- %@"
              , uncompress_result_
              , [ JNGzipErrorsLogger zipErrorMessageFromCode: uncompress_result_ ] );

        *error_ = [ NSError errorWithDomain: kGzipErrorDomain 
                                       code: uncompress_result_ 
                                   userInfo: nil ];

        return nil;
    }

    NSData* result_ = [ NSData dataWithBytes: decoded_buffer_
                                      length: decoded_size_ ];

    return result_;
}

@end
