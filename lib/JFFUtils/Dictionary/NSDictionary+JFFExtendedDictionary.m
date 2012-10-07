#import "NSDictionary+JFFExtendedDictionary.h"

#import "JFFClangLiterals.h"

@implementation NSDictionary (JFFExtendedDictionary)

- (NSDictionary *)dictionaryByAddingObjectsFromDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *result = [self mutableCopy];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        result[key] = object;
    }];
    
    return [result copy];
}

@end
