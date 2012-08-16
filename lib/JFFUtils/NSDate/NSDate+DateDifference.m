#import "NSDate+DateDifference.h"

#import "NSString+Search.h"

@implementation NSDate (DateDifference)

-(NSString*)dateDifferenceStringFromDate:( NSDate* )fromDate_
{
    NSComparisonResult order_ = [ self compare: fromDate_ ];
    if ( order_ != NSOrderedDescending )
    {
        NSParameterAssert( NO );
        return nil;
    }

    NSCalendar* gregorian_ = [ [ NSCalendar alloc ] initWithCalendarIdentifier: NSGregorianCalendar ];
    unsigned int unitFlags_ = NSYearCalendarUnit | NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit |
    NSSecondCalendarUnit;

    NSDateComponents* components_ = [ gregorian_ components: unitFlags_
                                                   fromDate: fromDate_
                                                     toDate: self
                                                    options: 0 ];

    NSString* result_;
    NSUInteger dateComponent_;

    if ( [ components_ year ] )
    {
        dateComponent_ = [ components_ year ];
        result_        = dateComponent_ == 1
            ? NSLocalizedString( @"YEAR", nil )
            : NSLocalizedString( @"YEARS", nil );
    }
    else if ( [ components_ month ] )
    {
        dateComponent_ = [ components_ month ];
        result_        = dateComponent_ == 1
            ? NSLocalizedString( @"MONTH", nil )
            : NSLocalizedString( @"MONTHS", nil );
    }
    else if ( [ components_ day ] )
    {
        dateComponent_ = [ components_ day ];
        result_        = dateComponent_ == 1
            ? NSLocalizedString( @"DAY", nil )
            : NSLocalizedString( @"DAYS", nil );
    }
    else if ( [ components_ minute ] )
    {
        dateComponent_ = [ components_ minute ];
        result_        = dateComponent_ == 1
            ? NSLocalizedString( @"MINUTE", nil )
            : NSLocalizedString( @"MINUTES", nil );
    }
    else
    {
        dateComponent_ = [ components_ second ];
        dateComponent_ = dateComponent_ < 1 ? 1 : dateComponent_;
        result_        = dateComponent_ == 1
            ? NSLocalizedString( @"SECOND", nil )
            : NSLocalizedString( @"SECONDS", nil );
    }

    NSString* numberStr_ = [ [ NSString alloc ] initWithFormat: @"%d ", dateComponent_ ];
    result_ = [ numberStr_ stringByAppendingString: result_ ];

    return result_;
}

@end
