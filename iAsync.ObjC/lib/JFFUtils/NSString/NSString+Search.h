#import <Foundation/Foundation.h>

@interface NSString (Search)

- (NSUInteger)numberOfCharacterFromString:(NSString *)string;
- (NSUInteger)numberOfStringsFromString:(NSString *)string;

- (BOOL)containsString:(NSString *)string;
- (BOOL)caseInsensitiveContainsString:(NSString *)string;

@end
