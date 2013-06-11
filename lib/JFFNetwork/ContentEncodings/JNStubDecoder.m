#import "JNStubDecoder.h"

@implementation JNStubDecoder

- (NSData *)decodeData:(NSData *)encodedData
                 error:(NSError **)outError
{
    NSParameterAssert(outError);
    *outError = nil;
    
    return encodedData;
}

@end
