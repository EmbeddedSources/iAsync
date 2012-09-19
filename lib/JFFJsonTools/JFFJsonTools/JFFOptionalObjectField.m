#import "JFFOptionalObjectField.h"

@implementation JFFOptionalObjectField : NSObject

+ (id)newOptionalObjectFieldWithFieldKey:(id)fieldKey
{
    JFFOptionalObjectField *result = [self new];
    
    if (result)
    {
        result->_fieldKey = [fieldKey copy];
    }
    
    return result;
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFOptionalObjectField *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy)
    {
        copy->_fieldKey = [self->_fieldKey copyWithZone:zone];
    }
    
    return copy;
}

@end
