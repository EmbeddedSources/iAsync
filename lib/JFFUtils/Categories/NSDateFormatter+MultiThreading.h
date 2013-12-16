#import <Foundation/Foundation.h>

@interface NSDateFormatter (JFFMultiThreading)

- (NSString *)synchronizedStringFromDate:(NSDate *)date;
- (NSDate *)synchronizedDateFromString:(NSString *)string;

@end
