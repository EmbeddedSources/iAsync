#import "JFFParseJSONObjectError.h"

@implementation JFFParseJSONObjectError

- (id)copyWithZone:(NSZone *)zone
{
    JFFParseJSONObjectError *copy = [[self class] allocWithZone:zone];

    if (copy)
    {
        copy->_jsonObject = [self->_jsonObject copy];
    }

    return copy;
}

@end
