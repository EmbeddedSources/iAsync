#import "CacheDBInfoStorage.h"

#import "CacheDBInfo.h"

@implementation CacheDBInfoStorage
{
    NSDictionary *_plistRepresentation;
    NSDictionary *_info;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithPlistInfo:(NSDictionary *)info
{
    self = [super init];
    
    if (self) {
        
        _plistRepresentation = info;
        _info = [info map:^id(NSString *dbPropertyName, NSDictionary *info) {
            
            return [CacheDBInfo newCacheDBInfoWithPlistInfo:info dbPropertyName:dbPropertyName];
        }];
    }
    
    return self;
}

+ (instancetype)newCacheDBInfoStorageWithPlistInfo:(NSDictionary *)info
{
    return [[self alloc] initWithPlistInfo:info];
}

- (CacheDBInfo *)infoByDBName:(NSString *)dbName
{
    return _info[dbName];
}

- (NSDictionary *)plistRepresentation
{
    return _plistRepresentation;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(NSString *key, CacheDBInfo *obj, BOOL *stop))block
{
    [_info enumerateKeysAndObjectsUsingBlock:block];
}

@end
