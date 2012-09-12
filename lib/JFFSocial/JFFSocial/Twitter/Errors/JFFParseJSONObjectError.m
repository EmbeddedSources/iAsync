#import "JFFParseJSONObjectError.h"

@implementation JFFParseJSONObjectError

- (id)init
{
    return [ self initWithDescription: NSLocalizedString( @"PARSE_JSON_OBJECT_ERROR", nil ) ];
}

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
