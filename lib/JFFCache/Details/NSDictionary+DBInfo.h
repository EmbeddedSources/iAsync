#import <Foundation/Foundation.h>

@interface NSDictionary (DBInfo)

- (NSNumber*)timeToLiveInHoursForDBWithName:(NSString *)name;
- (NSTimeInterval)autoRemoveByLastAccessDateForDBWithName:(NSString *)name;

- (NSString*)fileNameForDBWithName:(NSString *)name;
- (NSUInteger)versionForDBWithName:(NSString *)name;

@end
