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
    NSDictionary* decoderClasses_ = @{ @"gzip": [ JNGzipDecoder class ] };

    Class decoderClass_ = decoderClasses_[headerString];
    if ( Nil == decoderClass_ )
    {
        return [ self stubDecoder ];
    }
    
    return [ [ decoderClass_ alloc ] initWithContentLength: self.contentLength ];
}

- (id<JNHttpDecoder>)gzipDecoder
{
    return [ [ JNGzipDecoder alloc ] initWithContentLength: self.contentLength ];
}

- (id<JNHttpDecoder>)stubDecoder
{
    return [ JNStubDecoder new ];
}

@end
