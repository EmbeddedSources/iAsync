#import "NSDictionary+DBInfo.h"

@implementation NSDictionary (DBInfo)

- (NSString *)fileNameForDBWithName:(NSString *)name
{
    return self[name][@"fileName"];
}

- (NSNumber *)timeToLiveInHoursForDBWithName:(NSString *)name
{
    NSNumber *result = self[name][@"timeToLiveInHours"];
    return result;
}

- (NSTimeInterval)autoRemoveByLastAccessDateForDBWithName:(NSString *)name
{
    NSNumber* number = self[name][@"autoRemoveByLastAccessDateInHours"];
    return number?[number doubleValue] * 3600. : 0.;
}

- (NSUInteger)versionForDBWithName:(NSString *)name
{
    return [self[name][@"version"] intValue];
}

@end
