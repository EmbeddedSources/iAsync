#import <Foundation/Foundation.h>

@class JFFSQLiteDB;

@interface JFFBaseDB : NSObject

- (instancetype)initWithCacheFileName:(NSString *)cacheName;

- (NSData *)dataForKey:(id)key;
- (NSData *)dataForKey:(id)key lastUpdateTime:(NSDate **)date;

- (void)setData:(NSData *)data forKey:(id)key;

- (void)removeRecordsToUpdateDate:(NSDate *)date;
- (void)removeRecordsToAccessDate:(NSDate *)date;

- (void)removeRecordsForKey:(id)key;

- (void)removeRecordsWhileTotalSizeMoreThenBytes:(unsigned long long)sizeInBytes;

- (void)removeAllRecordsWithCallback:(JFFSimpleBlock)callback;

@end
