#import "JNHttpEncodingsFactory.h"

#import "JNGzipDecoder.h"
#import "JNStubDecoder.h"

@implementation JNHttpEncodingsFactory

+(id<JNHttpDecoder>)decoderForHeaderString:( NSString* )headerString_
{
    NSDictionary* decoderClasses_ = [ NSDictionary dictionaryWithObjectsAndKeys: 
                                     [ JNGzipDecoder class ], @"gzip"
                                     , nil ];

    Class decoderClass_ = [ decoderClasses_ objectForKey: headerString_ ];
    if ( Nil == decoderClass_ )
    {
//      NSLog( @"[!!! WARNING !!!] : JNHttpEncodingsFactory -- unknown HTTP encoding id '%@' ", header_string_ );
        return [ self stubDecoder ];
    }

    return [ [ decoderClass_ new ] autorelease ];
}

+(id<JNHttpDecoder>)gzipDecoder
{
    return [ [ JNGzipDecoder new ] autorelease ];
}


+(id<JNHttpDecoder>)stubDecoder
{
    return [ [ JNStubDecoder new ] autorelease ];
}

@end
