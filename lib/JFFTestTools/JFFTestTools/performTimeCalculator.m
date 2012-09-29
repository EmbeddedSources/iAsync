#import "performTimeCalculator.h"

#include <float.h>

NSTimeInterval performTimeCalculator(JFFSimpleBlock block, NSUInteger times)
{
    NSTimeInterval result = DBL_MAX;
    
    for (NSUInteger index = 0; index < times; ++index) {
        NSDate* startDate = [NSDate new];
        @autoreleasepool {
            block();
        }
        NSDate* endDate = [NSDate new];
        result = fmin(result, [endDate timeIntervalSinceDate:startDate]);
    }
    return result;
}
