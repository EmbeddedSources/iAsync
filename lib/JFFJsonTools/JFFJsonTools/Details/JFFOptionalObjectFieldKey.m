#import "JFFOptionalObjectFieldKey.h"

@implementation JFFOptionalObjectFieldKey : NSObject

+ (instancetype)newOptionalObjectFieldWithFieldKey:(id)fieldKey
{
    JFFOptionalObjectFieldKey *result = [self new];
    
    if (result) {
        result->_fieldKey = [fieldKey copy];
    }
    
    return result;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    JFFOptionalObjectFieldKey *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_fieldKey = [_fieldKey copyWithZone:zone];
    }
    
    return copy;
}

- (BOOL)isEqual:(JFFOptionalObjectFieldKey *)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [NSObject object:_fieldKey isEqualTo:object->_fieldKey];
}

- (NSUInteger)hash
{
    return [_fieldKey hash];
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"<%@: %p fieldKey: %@>", [self class], self, _fieldKey];
}

@end
