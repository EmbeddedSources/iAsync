#import <Foundation/Foundation.h>

@interface NSDictionary (DBInfo)

- (NSNumber *)timeToLiveInHoursForDBWithName:(NSString *)name;
- (instancetype)autoRemoveProperiesForDBWithName:(NSString *)name;

- (NSString *)fileNameForDBWithName:(NSString *)name;
- (NSUInteger)versionForDBWithName:(NSString *)name;

@end

@interface NSDictionary (DBInfo_Autoremove)

- (NSTimeInterval)autoRemoveByLastAccessDate;
- (double)autoRemoveByMaxSizeInMB;

@end
