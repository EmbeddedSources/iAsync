#import <Foundation/Foundation.h>

@protocol JNHttpDecoder;

@interface JNHttpEncodingsFactory : NSObject 

+ (id<JNHttpDecoder>)decoderForHeaderString:(NSString *)headerString;
+ (id<JNHttpDecoder>)gzipDecoder;
+ (id<JNHttpDecoder>)stubDecoder;

@end
