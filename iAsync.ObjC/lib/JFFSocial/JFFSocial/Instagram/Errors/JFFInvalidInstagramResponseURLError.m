#import "JFFInvalidInstagramResponseURLError.h"

@implementation JFFInvalidInstagramResponseURLError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"INVALID_INSTAGRAM_RESPONSE_URL", nil)];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    JFFInvalidInstagramResponseURLError *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy->_url = [_url copyWithZone:zone];
    }
    
    return copy;
}

@end
