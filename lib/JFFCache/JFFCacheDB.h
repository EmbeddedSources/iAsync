#import <Foundation/Foundation.h>

@protocol JFFCacheDB < NSObject >

@required

@property (nonatomic, readonly) NSString *name;

- (NSData *)dataForKey:(id)key;
- (NSData *)dataForKey:(id)key lastUpdateTime:(NSDate **)date;
- (NSDate *)lastUpdateTimeForKey:(id)key;

- (void)setData:(NSData *)data forKey:(id)key;

- (void)removeRecordsForKey:(id)key;

- (void)migrateDB;

- (NSNumber*)timeToLiveInHours;

@end
