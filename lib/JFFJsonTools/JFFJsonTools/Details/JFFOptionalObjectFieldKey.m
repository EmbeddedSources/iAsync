#import "JFFOptionalObjectFieldKey.h"

@implementation JFFOptionalObjectFieldKey : NSObject

+ (id)newOptionalObjectFieldWithFieldKey:(id)fieldKey
{
    JFFOptionalObjectFieldKey *result = [self new];
    
    if (result) {
        result->_fieldKey = [fieldKey copy];
    }
    
    return result;
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFOptionalObjectFieldKey *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_fieldKey = [self->_fieldKey copyWithZone:zone];
    }
    
    return copy;
}

@end
