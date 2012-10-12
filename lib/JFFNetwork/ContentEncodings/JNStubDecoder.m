#import "JNStubDecoder.h"

@implementation JNStubDecoder

-(NSData*)decodeData:( NSData* )encoded_data_
               error:( NSError** )outError
{
    NSParameterAssert( outError );
    *outError = nil;
    
    return encoded_data_;
}

@end
