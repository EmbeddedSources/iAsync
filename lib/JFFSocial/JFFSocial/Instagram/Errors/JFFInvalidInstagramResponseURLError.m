#import "JFFInvalidInstagramResponseURLError.h"

@implementation JFFInvalidInstagramResponseURLError

-(id)init
{
    return [ self initWithDescription: NSLocalizedString( @"INVALID_INSTAGRAM_RESPONSE_URL", nil ) ];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFInvalidInstagramResponseURLError *copy = [[self class] allocWithZone:zone];

    if (copy)
    {
        copy->_url = [self->_url copy];
    }

    return copy;
}

@end
