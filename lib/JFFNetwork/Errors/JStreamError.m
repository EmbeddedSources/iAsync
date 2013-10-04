#import "JStreamError.h"

@implementation JStreamError
{
@private
    CFStreamError _rawError;
    id<NSCopying> _context;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithDescription:(NSString *)description
                             domain:(NSString *)domain
                               code:(NSInteger)code
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithStreamError:(CFStreamError)rawError
                            context:(id<NSCopying>)context
{
    NSString *domain_ = [[NSString alloc] initWithFormat: @"com.just_for_fun.library.network.CFError(%ld)", rawError.domain];
    
    self = [super initWithDescription:NSLocalizedString(@"JNETWORK_CF_STREAM_ERROR", nil)
                               domain:domain_
                                 code:rawError.error];
    
    if (nil == self) {
        
        return nil;
    }
    
    _rawError = rawError;
    _context  = context;
    
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    JStreamError *copy = [super copyWithZone:zone];
    
    if (copy) {
        
        copy->_rawError = _rawError;
        copy->_context  = [_context copyWithZone:zone];
    }
    
    return copy;
}

- (NSString *)errorLogDescription
{
    return [[NSString alloc] initWithFormat:@"%@ nativeError domain:%ld error_code:%d context:%@",
            [self localizedDescription],
            _rawError.domain,
            (int)_rawError.error,
            _context];
}

@end
