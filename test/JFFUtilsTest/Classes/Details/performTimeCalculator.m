#import "performTimeCalculator.h"

#include <float.h>

NSTimeInterval performTimeCalculator( JFFSimpleBlock block_, NSUInteger times_ )
{
    NSTimeInterval result_ = DBL_MAX;

    for ( NSUInteger index_ = 0; index_ < times_; ++index_ )
    {
        NSDate* startDate_ = [ NSDate new ];
        @autoreleasepool
        {
            block_();
        }
        NSDate* endDate_ = [ NSDate new ];
        result_ = fmin( result_, [ endDate_ timeIntervalSinceDate: startDate_ ] );
    }
    return result_;
}
