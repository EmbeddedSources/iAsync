#import <Foundation/Foundation.h>

@protocol JFFCacheDB;

@interface JFFCaches : NSObject

@property (nonatomic, readonly) NSDictionary *cacheDbByName;

+ (JFFCaches *)sharedCaches;
+ (void)setSharedCaches:(JFFCaches *)caches;

- (instancetype)initWithDBInfoDictionary:(NSDictionary *)cachesInfo;

+ (id<JFFCacheDB>)createCacheForName:(NSString *)name;

- (id<JFFCacheDB>)cacheByName:(NSString *)name;

+ (NSString *)thumbnailDBName;

- (id<JFFCacheDB>)thumbnailDB;

+ (id<JFFCacheDB>)createThumbnailDB;

- (void)migrateDBs;

@end
