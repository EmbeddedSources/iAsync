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

+(NSNumber*)timeIntervalSince1970WithTimeZone:( NSTimeZone* )time_zone_
{
    NSDate* date_with_timezone_ = [ [ NSDate date ] dateByAdjustingFromLocalTimeZoneToTimeZone: time_zone_ ];

    unsigned long long time_interval_since_1970_ = [ date_with_timezone_ timeIntervalSince1970 ] * 1000;

    return [ NSNumber numberWithUnsignedLongLong: time_interval_since_1970_ ];
}

@end
