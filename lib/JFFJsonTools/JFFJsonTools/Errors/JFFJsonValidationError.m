#import "JFFJsonValidationError.h"

@implementation JFFJsonValidationError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"JSON_VALIDATION_ERROR", nil)];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFJsonValidationError *copy = [[[self class]allocWithZone:zone]init];

    if (copy)
    {
        copy->_jsonObject  = [self->_jsonObject  copy];
        copy->_jsonPattern = [self->_jsonPattern copy];
        copy->_message     = [self->_message     copy];
    }

    return copy;
}

@end
