#import <Foundation/Foundation.h>

@protocol JNHttpDecoder;

@interface JNHttpEncodingsFactory : NSObject 

-(id)initWithContentLength:( unsigned long long )contentLength;

@property (nonatomic, readonly) unsigned long long contentLength;

-(id<JNHttpDecoder>)decoderForHeaderString:( NSString* )header_string_;
-(id<JNHttpDecoder>)gzipDecoder;
-(id<JNHttpDecoder>)stubDecoder;

@end
