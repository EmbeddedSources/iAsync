#import <Foundation/Foundation.h>

@class JFFSQLiteDB;

@interface JFFBaseDB : NSObject

@property (nonatomic, readonly) JFFSQLiteDB *db;
@property (nonatomic, readonly) NSString    *name;

- (id)initWithDBName:(NSString *)dbName
           cacheName:(NSString *)cacheName;

- (NSData*)dataForKey:(id)key;
- (NSData*)dataForKey:(id)key lastUpdateTime:(NSDate **)date;

- (void)setData:(NSData *)data forKey:(id)key;

- (void)removeRecordsToUpdateDate:(NSDate *)date;
- (void)removeRecordsToAccessDate:(NSDate *)date;

- (void)removeRecordsForKey:(id)key;

- (void)removeAllRecords;

@end
