#import <Foundation/Foundation.h>

@interface NSDictionary (XQueryComponents)

- (NSString *)stringFromQueryComponents;
- (NSData *)dataFromQueryComponents;
- (NSString *)firstValueIfExsistsForKey:(NSString *)key;

@end
