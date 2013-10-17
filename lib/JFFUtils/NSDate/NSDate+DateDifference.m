#import "NSDate+DateDifference.h"

#import "NSString+Search.h"

@implementation NSDate (DateDifference)

//TODO may be can be removed with using NSDateFormatter
- (NSString *)dateDifferenceStringFromDate:(NSDate *)fromDate
{
    NSComparisonResult order = [self compare:fromDate];
    if (order != NSOrderedDescending) {
        NSParameterAssert(NO);
        return nil;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:fromDate
                                                  toDate:self
                                                 options:0];
    
    NSString *result;
    NSUInteger dateComponent;
    
    if ([components year]) {
        dateComponent = [components year];
        result        = dateComponent == 1
        ? NSLocalizedString(@"YEAR", nil)
        : NSLocalizedString(@"YEARS", nil);
    } else if ([components month]) {
        dateComponent = [components month];
        result        = dateComponent == 1
        ? NSLocalizedString(@"MONTH", nil)
        : NSLocalizedString(@"MONTHS", nil);
    } else if ([components day]) {
        dateComponent = [components day];
        result        = dateComponent == 1
        ? NSLocalizedString(@"DAY", nil)
        : NSLocalizedString(@"DAYS", nil);
    } else if ([components minute]) {
        dateComponent = [components minute];
        result        = dateComponent == 1
        ? NSLocalizedString(@"MINUTE", nil)
        : NSLocalizedString(@"MINUTES", nil);
    } else {
        dateComponent = [components second];
        dateComponent = dateComponent < 1 ? 1 : dateComponent;
        result        = dateComponent == 1
        ? NSLocalizedString(@"SECOND", nil)
        : NSLocalizedString(@"SECONDS", nil);
    }
    
    NSString *numberStr = [[NSString alloc] initWithFormat:@"%lu ", (unsigned long)dateComponent];
    result = [numberStr stringByAppendingString:result];
    
    return result;
}

@end
