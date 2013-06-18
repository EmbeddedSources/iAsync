#import <Foundation/Foundation.h>

@protocol JNHttpDecoder;

@interface JNHttpEncodingsFactory : NSObject 

- (instancetype)initWithContentLength:(unsigned long long)contentLength;

@property (nonatomic, readonly) unsigned long long contentLength;

- (id<JNHttpDecoder>)decoderForHeaderString:(NSString *)headerString;
- (id<JNHttpDecoder>)gzipDecoder;
- (id<JNHttpDecoder>)stubDecoder;

@end
