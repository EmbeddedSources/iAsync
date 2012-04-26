#import <Foundation/Foundation.h>

@protocol JNHttpDecoder;

@interface JNHttpEncodingsFactory : NSObject 

+(id<JNHttpDecoder>)decoderForHeaderString:( NSString* )header_string_;
+(id<JNHttpDecoder>)gzipDecoder;
+(id<JNHttpDecoder>)stubDecoder;

@end
