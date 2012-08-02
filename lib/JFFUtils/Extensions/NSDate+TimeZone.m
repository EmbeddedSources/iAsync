#import "NSDate+TimeZone.h"

#import <UIKit/UIDevice.h>

@implementation NSDate (TimeZone)

-(NSDate*)dateByAdjustingFromTimeZone:( NSTimeZone* )from_
                           toTimeZone:( NSTimeZone* )to_
{
    return [ self dateByAddingTimeInterval: ( [ to_ secondsFromGMT ] - [ from_ secondsFromGMT ] ) ];
}

-(NSDate*)dateByAdjustingToLocalTimeZoneFromTimeZone:( NSTimeZone* )from_
{
    return [ self dateByAdjustingFromTimeZone: from_ toTimeZone: [ NSTimeZone localTimeZone ] ];
}

-(NSDate*)dateByAdjustingFromLocalTimeZoneToTimeZone:( NSTimeZone* )to_
{
    return [ self dateByAdjustingFromTimeZone: [ NSTimeZone localTimeZone ] toTimeZone: to_ ];
}

+(NSNumber*)timeIntervalSince1970WithTimeZone:( NSTimeZone* )timeZone_
{
    NSDate* dateWithTimeZone_ = [ [ NSDate new ] dateByAdjustingFromLocalTimeZoneToTimeZone: timeZone_ ];

    unsigned long long timeIntervalSince_1970_ = [ dateWithTimeZone_ timeIntervalSince1970 ] * 1000;

    return @( timeIntervalSince_1970_ );
}

@end
