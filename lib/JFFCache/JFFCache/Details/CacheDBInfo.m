#import "CacheDBInfo.h"

@implementation CacheDBInfo
{
    NSString *_dbPropertyName;
    NSDictionary *_info;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithPlistInfo:(NSDictionary *)info
                   dbPropertyName:(NSString *)dbPropertyName
{
    self = [super init];
    
    if (self) {
        
        _dbPropertyName = dbPropertyName;
        _info = [info copy];
    }
    
    return self;
}

+ (instancetype)newCacheDBInfoWithPlistInfo:(NSDictionary *)info
                             dbPropertyName:(NSString *)dbPropertyName
{
    return [[self alloc] initWithPlistInfo:info dbPropertyName:dbPropertyName];
}

- (NSString *)fileName
{
    return _info[@"fileName"];
}

- (NSUInteger)version
{
    return [_info[@"version"] intValue];
}

- (NSNumber *)timeToLiveInHours
{
    NSNumber *result = _info[@"timeToLiveInHours"];
    return result;
}

- (NSDictionary *)autoRemove
{
    return _info[@"autoRemove"];
}

- (NSTimeInterval)autoRemoveByLastAccessDate
{
    NSNumber* number = [self autoRemove][@"lastAccessDateInHours"];
    return number?[number doubleValue] * 3600. : 0.;
}

- (double)autoRemoveByMaxSizeInMB
{
    NSNumber* number = [self autoRemove][@"maxSizeInMB"];
    return number?[number doubleValue]:0.;
}

@end
