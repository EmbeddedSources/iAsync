#import <JFFNetwork/ContentEncodings/JNHttpDecoder.h>

#import <Foundation/Foundation.h>

@interface JNGzipDecoder : NSObject < JNHttpDecoder >

-(id)initWithContentLength:( unsigned long long )contentLength_;

@end
