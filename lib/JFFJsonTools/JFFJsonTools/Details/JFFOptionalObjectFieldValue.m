#import "JFFOptionalObjectFieldValue.h"

@implementation JFFOptionalObjectFieldValue : NSObject

+ (id)newOptionalObjectFieldWithFieldValue:(id)fieldValue
{
    JFFOptionalObjectFieldValue *result = [self new];
    
    if (result) {
        result->_fieldValue = fieldValue;
    }
    
    return result;
}

@end
