#import <Foundation/Foundation.h>

@interface NSDictionary (ValueWithType)

- (NSString *)stringForKey:(NSString *)key;
- (NSString *)stringForKeyPath:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;

- (NSNumber *)numberWithIntegerForKey:(NSString *)key;
- (NSNumber *)numberWithBoolForKey:(NSString *)key;
- (NSNumber *)numberWithDoubleForKey:(NSString *)key;

- (NSDictionary *)dictionaryForKey:(NSString *)key;

- (NSArray *)arrayForKey:(NSString *)key;

@end
