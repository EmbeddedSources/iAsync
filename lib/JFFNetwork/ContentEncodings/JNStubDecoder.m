#import "JNStubDecoder.h"

@implementation JNStubDecoder

- (NSData *)decodeData:(NSData *)encodedData
                 error:(NSError **)outError
{
    NSParameterAssert(outError);
    *outError = nil;
    
    return encodedData;
}

- (BOOL)closeWithError:(NSError **)outError
{
    return YES;
}

-(BOOL)closeWithError:( NSError ** )outError
{
    return YES;
}

@end
