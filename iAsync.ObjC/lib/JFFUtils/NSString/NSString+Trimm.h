#import <Foundation/Foundation.h>

@interface NSString (Trimm)

- (instancetype)stringByTrimmingWhitespaces;
- (instancetype)stringByTrimmingPunctuation;

- (instancetype)stringByTrimmingQuotes;

@end
