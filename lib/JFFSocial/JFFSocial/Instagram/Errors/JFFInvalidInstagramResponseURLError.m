#import "JFFInvalidInstagramResponseURLError.h"

@implementation JFFInvalidInstagramResponseURLError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"INVALID_INSTAGRAM_RESPONSE_URL", nil)];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFInvalidInstagramResponseURLError *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy->_url = [_url copyWithZone:zone];
    }
    
    return copy;
}

@end
