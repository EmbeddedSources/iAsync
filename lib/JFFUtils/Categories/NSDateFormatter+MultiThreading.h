#import <Foundation/Foundation.h>

@interface NSDateFormatter (MultiThreading)

- (NSString *)synchronizedStringFromDate:(NSDate *)date;
- (NSDate *)synchronizedDateFromString:(NSString *)string;

@end
