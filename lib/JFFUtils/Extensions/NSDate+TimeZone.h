#import <Foundation/Foundation.h>

@interface NSDate (TimeZone)

-(NSDate*)dateByAdjustingFromTimeZone:( NSTimeZone* )from_
                           toTimeZone:( NSTimeZone* )to_;

-(NSDate*)dateByAdjustingToLocalTimeZoneFromTimeZone:( NSTimeZone* )from_;
-(NSDate*)dateByAdjustingFromLocalTimeZoneToTimeZone:( NSTimeZone* )to_;

+(NSNumber*)timeIntervalSince1970WithTimeZone:( NSTimeZone* )time_zone_;

@end
