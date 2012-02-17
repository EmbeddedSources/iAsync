#import "JNStubDecoder.h"

@implementation JNStubDecoder

-(NSData*)decodeData:( NSData* )encoded_data_
               error:( NSError** )error_
{
    NSParameterAssert( error_ );
    *error_ = nil;

    //!! dodikk : Just in case
    return [ [ encoded_data_ retain ] autorelease ];
}

@end
