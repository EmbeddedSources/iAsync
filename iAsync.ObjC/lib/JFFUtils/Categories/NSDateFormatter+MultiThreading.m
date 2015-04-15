#import "NSDateFormatter+MultiThreading.h"

@implementation NSDateFormatter (MultiThreading)

//TODO remove this methods and create thread safe NSDateFormatter
- (NSString *)synchronizedStringFromDate:(NSDate *)date
{
    @synchronized(self) {
        return [self stringFromDate:date];
    }
}

- (NSDate *)synchronizedDateFromString:(NSString *)string
{
    @synchronized(self) {
        return [self dateFromString:string];
    }
}

@end
