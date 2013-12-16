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

@end
