#import <Foundation/Foundation.h>

@protocol JFFCacheDB < NSObject >

@required

- (NSData *)dataForKey:(id)key;
- (NSData *)dataForKey:(id)key lastUpdateTime:(NSDate **)date;
- (NSDate *)lastUpdateTimeForKey:(id)key;

- (void)setData:(NSData *)data forKey:(id)key;

- (void)removeRecordsForKey:(id)key;
- (void)removeAllRecords;

- (void)migrateDB;

- (NSNumber*)timeToLiveInHours;

@end
