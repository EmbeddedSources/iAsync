#import "NSMutableDictionary+IgnoringAddNilValue.h"

@implementation NSMutableDictionary (IgnoringAddNilValue)

- (void)setObjectWithIgnoreNillValue:(id)anObject forKey:(id)aKey
{
    if (anObject)
    {
        [self setObject:anObject forKey:aKey];
    }
}

@end
