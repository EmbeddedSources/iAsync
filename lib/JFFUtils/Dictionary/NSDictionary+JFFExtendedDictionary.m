#import "NSDictionary+JFFExtendedDictionary.h"

@implementation NSDictionary (JFFExtendedDictionary)

- (instancetype)dictionaryByAddingObjectsFromDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *result = [self mutableCopy];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        result[key] = object;
    }];
    
    return [result copy];
}

@end
