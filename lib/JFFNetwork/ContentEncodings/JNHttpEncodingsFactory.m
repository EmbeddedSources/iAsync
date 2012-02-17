#import "JNHttpEncodingsFactory.h"

#import "JNGzipDecoder.h"
#import "JNStubDecoder.h"

@implementation JNHttpEncodingsFactory

+(id<JNHttpDecoder>)decoderForHeaderString:( NSString* )header_string_
{
   NSDictionary* decoder_classes_ = [ NSDictionary dictionaryWithObjectsAndKeys: 
                                         [ JNGzipDecoder class ], @"gzip"
                                       , nil 
                                    ];
   
   Class decoder_class_ = [ decoder_classes_ objectForKey: header_string_ ];
   if ( Nil == decoder_class_ )
   {
//      NSLog( @"[!!! WARNING !!!] : JNHttpEncodingsFactory -- unknown HTTP encoding id '%@' ", header_string_ );
      return [ self stubDecoder ];
   }

   return [ [ decoder_class_ new ] autorelease ];
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
