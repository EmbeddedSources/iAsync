#import "JNZipDecoder.h"
#import "JNGzipCustomErrors.h"

#import "JNConstants.h"
#import "JNGzipErrorsLogger.h"

#include <zconf.h>

@implementation JNZipDecoder

- (NSData *)decodeData:(NSData *)encodedData
                 error:(NSError **)outError
{
    NSParameterAssert( outError );
    *outError = nil;
    if (nil == encodedData) {
        return nil;
    }
    
    Bytef decodedBuffer[ kJNMaxBufferSize ] = {0};
    uLongf decodedSize = kJNMaxBufferSize;
    
    int uncompressResult = uncompress(decodedBuffer    , &decodedSize        ,
                                      encodedData.bytes, encodedData.length );
    
    if (Z_OK != uncompressResult) {
        NSLog(@"[!!! WARNING !!!] JNZipDecoder -- unzip action has failed.\n Zip error code -- %d\n Zip error -- %@",
              uncompressResult,
              [JNGzipErrorsLogger zipErrorMessageFromCode:uncompressResult]);
        
        *outError = [[NSError alloc] initWithDomain:kGzipErrorDomain
                                               code:uncompressResult
                                           userInfo:nil];
        
        return nil;
    }
    
    NSData *result = [[NSData alloc] initWithBytes:decodedBuffer
                                            length:decodedSize];
    
    return result;
}

- (BOOL)closeWithError:(NSError **)error
{
    return YES;
}

@end
