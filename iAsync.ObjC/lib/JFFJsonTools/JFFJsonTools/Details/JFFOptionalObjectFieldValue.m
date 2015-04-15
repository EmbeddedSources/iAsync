#import "JFFOptionalObjectFieldValue.h"

@implementation JFFOptionalObjectFieldValue : NSObject

+ (instancetype)newOptionalObjectFieldWithFieldValue:(id)fieldValue
{
    JFFOptionalObjectFieldValue *result = [self new];
    
    if (result) {
        result->_fieldValue = fieldValue;
    }
    
    return result;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"<%@: %p fieldValue: %@>", [self class], self, _fieldValue];
}

@end
