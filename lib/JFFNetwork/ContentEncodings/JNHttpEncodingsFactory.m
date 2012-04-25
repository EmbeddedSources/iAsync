#import "JNHttpEncodingsFactory.h"

#import "JNGzipDecoder.h"
#import "JNStubDecoder.h"

@implementation JNHttpEncodingsFactory

+(id<JNHttpDecoder>)decoderForHeaderString:( NSString* )headerString_
{
    NSDictionary* decoderClasses_ = [ [ NSDictionary alloc ] initWithObjectsAndKeys: 
                                     [ JNGzipDecoder class ], @"gzip"
                                     , nil ];

    Class decoderClass_ = [ decoderClasses_ objectForKey: headerString_ ];
    if ( Nil == decoderClass_ )
    {
        return [ self stubDecoder ];
    }

    return [ decoderClass_ new ];
}

+(id<JNHttpDecoder>)gzipDecoder
{
    return [ JNGzipDecoder new ];
}


+(id<JNHttpDecoder>)stubDecoder
{
    return [ JNStubDecoder new ];
}

@end
