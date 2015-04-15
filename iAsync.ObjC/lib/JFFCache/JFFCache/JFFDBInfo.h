#import <Foundation/Foundation.h>

@class CacheDBInfoStorage;

@interface JFFDBInfo : NSObject

@property (atomic, readonly) CacheDBInfoStorage *dbInfoByNames;
@property (atomic, readonly) NSDictionary *currentDbVersionsByName;

- (instancetype)initWithInfoPath:(NSString *)infoPath;
- (instancetype)initWithInfoDictionary:(NSDictionary *)infoDictionry;

+ (void)setSharedDBInfo:(JFFDBInfo *)dbInfo;
+ (JFFDBInfo *)sharedDBInfo;

- (void)saveCurrentDBInfoVersions;

@end
