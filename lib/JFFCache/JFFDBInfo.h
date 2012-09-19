#import <Foundation/Foundation.h>

@interface NSDictionary (DBInfo)

- (NSNumber*)timeToLiveInHoursForDBWithName:(NSString *)name;
- (NSTimeInterval)autoRemoveByLastAccessDateForDBWithName:(NSString *)name;

- (NSString*)fileNameForDBWithName:(NSString *)name;
- (NSUInteger)versionForDBWithName:(NSString *)name;

@end

@interface JFFDBInfo : NSObject

@property (nonatomic, readonly) NSDictionary *dbInfo;
@property (nonatomic) NSDictionary *currentDbInfo;

- (id)initWithInfoPath:(NSString *)infoPath;
- (id)initWithInfoDictionary:(NSDictionary *)infoDictionry;

+ (void)setSharedDBInfo:(JFFDBInfo *)dbInfo;
+ (JFFDBInfo*)sharedDBInfo;

@end
