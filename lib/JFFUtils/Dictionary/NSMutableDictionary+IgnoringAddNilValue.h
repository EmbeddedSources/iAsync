#import <Foundation/Foundation.h>

@interface NSMutableDictionary (IgnoringAddNilValue)

- (void)setObjectWithIgnoreNillValue:(id)anObject forKey:(id)aKey;

@end
