#import "JStreamError.h"

@implementation JStreamError

{
@private
    CFStreamError _rawError;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDescription:(NSString *)description
                  domain:(NSString *)domain
                    code:(NSInteger)code
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id)initWithStreamError:(CFStreamError)rawError_
{
    NSString *domain_ = [[NSString alloc] initWithFormat: @"com.just_for_fun.library.network.CFError(%ld)", rawError_.domain];
    
    self = [super initWithDescription:NSLocalizedString(@"JNETWORK_CF_STREAM_ERROR", nil)
                               domain:domain_
                                 code:rawError_.error];
    
    if (nil == self) {
        
        return nil;
    }
    
    _rawError = rawError_;
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    JStreamError *copy = [super copyWithZone:zone];
    
    if (copy) {
        
        copy->_rawError = _rawError;
    }
    
    return copy;
}

@end
