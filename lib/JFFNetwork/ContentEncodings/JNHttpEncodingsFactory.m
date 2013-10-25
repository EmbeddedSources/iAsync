#import "JNHttpEncodingsFactory.h"

#import "JNGzipDecoder.h"
#import "JNStubDecoder.h"

@interface JNHttpEncodingsFactory()

@property (nonatomic) unsigned long long contentLength;

@end

@implementation JNHttpEncodingsFactory

- (instancetype)initWithContentLength:( unsigned long long )contentLength
{
    self = [ super init ];
    self.contentLength = contentLength;
    
    return self;
}

- (id<JNHttpDecoder>)decoderForHeaderString:(NSString *)headerString
{
    NSDictionary *decoderClasses = @{ @"gzip": [JNGzipDecoder class] };
    
    Class decoderClass = decoderClasses[headerString];
    if (Nil == decoderClass) {
        
        return [self stubDecoder];
    }
    
    return [[decoderClass alloc] initWithContentLength:_contentLength];
}

- (id<JNHttpDecoder>)gzipDecoder
{
    return [[JNGzipDecoder alloc] initWithContentLength:_contentLength];
}

- (id<JNHttpDecoder>)stubDecoder
{
    return [JNStubDecoder new];
}

@end
