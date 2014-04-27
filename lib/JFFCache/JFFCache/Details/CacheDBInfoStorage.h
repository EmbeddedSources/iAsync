#import <Foundation/Foundation.h>

@class CacheDBInfo;

@interface CacheDBInfoStorage : NSObject

- (CacheDBInfo *)infoByDBName:(NSString *)dbName;

+ (instancetype)newCacheDBInfoStorageWithPlistInfo:(NSDictionary *)info;

- (NSDictionary *)plistRepresentation;

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(NSString *key, CacheDBInfo *obj, BOOL *stop))block;

@end
