#import <Foundation/Foundation.h>

@interface CacheDBInfo : NSObject

@property (nonatomic, readonly) NSString *dbPropertyName;
@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, readonly) NSUInteger version;
@property (nonatomic, readonly) NSNumber *timeToLiveInHours;

@property (nonatomic, readonly) NSTimeInterval autoRemoveByLastAccessDate;
@property (nonatomic, readonly) double autoRemoveByMaxSizeInMB;

+ (instancetype)newCacheDBInfoWithPlistInfo:(NSDictionary *)info
                             dbPropertyName:(NSString *)dbPropertyName;

@end
