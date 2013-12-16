#import <JFFNetwork/ContentEncodings/JNHttpDecoder.h>

#import <Foundation/Foundation.h>

@interface JNGzipDecoder : NSObject <JNHttpDecoder>

- (instancetype)initWithContentLength:(unsigned long long)contentLength;

@end
