#import <Foundation/Foundation.h>

@protocol JFFCacheDB;

@interface JFFCaches : NSObject

@property (nonatomic, readonly) NSDictionary *cacheDbByName;

+ (JFFCaches *)sharedCaches;
+ (void)setSharedCaches:(JFFCaches *)caches;

- (id)initWithDBInfoDictionary:(NSDictionary *)cachesInfo;

+ (id< JFFCacheDB >)createCacheForName:(NSString *)name;

- (id< JFFCacheDB >)cacheByName:(NSString *)name;

- (id< JFFCacheDB >)thumbnailDB;

+ (id< JFFCacheDB >)createThumbnailDB;

@end
