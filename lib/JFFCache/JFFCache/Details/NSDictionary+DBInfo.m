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

- (instancetype)autoRemoveProperiesForDBWithName:(NSString *)name
{
    return self[name][@"autoRemove"];
}

- (NSUInteger)versionForDBWithName:(NSString *)name
{
    return [self[name][@"version"] intValue];
}

@end

@implementation NSDictionary (DBInfo_Autoremove)

- (NSTimeInterval)autoRemoveByLastAccessDate
{
    NSNumber* number = self[@"lastAccessDateInHours"];
    return number?[number doubleValue] * 3600. : 0.;
}

- (double)autoRemoveByMaxSizeInMB
{
    NSNumber* number = self[@"maxSizeInMB"];
    return number?[number doubleValue]:0.;
}

@end
