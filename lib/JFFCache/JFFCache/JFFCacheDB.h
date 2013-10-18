#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@protocol JFFCacheDB <NSObject>

@required

- (NSData *)dataForKey:(id)key;
- (NSData *)dataForKey:(id)key lastUpdateTime:(NSDate **)date;

- (void)setData:(NSData *)data forKey:(id)key;

- (void)removeRecordsForKey:(id)key;
- (void)removeAllRecordsWithCallback:(JFFSimpleBlock)callback;

- (void)migrateDB;

- (NSNumber *)timeToLiveInHours;

@end
