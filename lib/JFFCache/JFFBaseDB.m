#import "JFFBaseDB.h"
#import "JFFDBCompositeKey.h"

#import "NSString+CompositeKey.h"
#import "NSObject+CompositeKey.h"
#import "NSString+CacheFSManager.h"

#import <sqlite3.h>

static NSString *const createRecords =
@"CREATE TABLE IF NOT EXISTS records ( "
@"record_id TEXT primary key"
@", file_link varchar(100)"
@", update_time real"
@", access_time real );";

static dispatch_queue_t getOrCreateDispatchQueueForFile(NSString *file)
{
    NSString *queueName = [[NSString alloc] initWithFormat:@"com.jff.embedded_sources.dynamic.%@", file];
    const char *queueNameCStr = [queueName cStringUsingEncoding:NSUTF8StringEncoding];
    dispatch_queue_t result = dispatch_queue_get_or_create(queueNameCStr,
                                                           DISPATCH_QUEUE_CONCURRENT);
    
    return result;
}

@interface JFFSQLiteDB : NSObject
{
    sqlite3 *_db;
    dispatch_queue_t _dispatchQueue;
}

@property (nonatomic, readonly) dispatch_queue_t queue;

- (id)initWithDBName:(NSString *)dbName;

- (BOOL)prepareQuery:(NSString *)sql
           statement:(sqlite3_stmt **)statement;

- (BOOL)execQuery:(NSString *)sql;

- (NSString *)errorMessage;

@end

@implementation JFFSQLiteDB

- (void)dealloc
{
    sqlite3_close(_db);
    dispatch_release(_dispatchQueue);
}

- (id)initWithDBName:(NSString *)dbName
{
    self = [super init];
    
    if (self) {
        
        _dispatchQueue = getOrCreateDispatchQueueForFile(dbName);
        dispatch_retain(_dispatchQueue);
        
        __block BOOL ok = NO;
        
        safe_dispatch_barrier_sync(self.queue, ^ {
            NSString *const dbPath = [NSString documentsPathByAppendingPathComponent:dbName];
            
            if (sqlite3_open([dbPath UTF8String], &self->_db) != SQLITE_OK) {
                NSLog(@"open - %@ path: %@", [self errorMessage], dbPath);
                return;
            };
            
            [dbPath addSkipBackupAttribute];
            
            const char *cacheSizePragma = "PRAGMA cache_size = 1000";
            
            if (sqlite3_exec(self->_db, cacheSizePragma, 0, 0, 0) != SQLITE_OK) {
                NSAssert1(0,
                          @"Error: failed to execute pragma statement with message '%s'.",
                          sqlite3_errmsg(self->_db));
            }
            ok = YES;
        });
        
        if (!ok)
            return nil;
    }
    
    return self;
}

- (dispatch_queue_t)queue
{
    return _dispatchQueue;
}

- (BOOL)prepareQuery:(NSString *)sql
           statement:(sqlite3_stmt **)statement
{
    return sqlite3_prepare_v2(self->_db,
                              [sql UTF8String],
                              -1,
                              statement,
                              0) == SQLITE_OK;
}

- (BOOL)execQuery:(NSString *)sql
{
    char *errorMessage = 0;
    if (sqlite3_exec(self->_db, [sql UTF8String], 0, 0, &errorMessage) != SQLITE_OK) {
        NSLog(@"%@ error: %s", sql, errorMessage);
        
        sqlite3_free(errorMessage);
        return NO;
    }
    
    return YES;
}

- (NSString *)errorMessage
{
    return @(sqlite3_errmsg(self->_db));
}

@end

@interface JFFBaseDB ()

@property (nonatomic, readonly) JFFSQLiteDB *db;

@end

@implementation JFFBaseDB
{
    NSString *_cacheName;
    JFFSQLiteDB *_db;
}

- (id)initWithCacheFileName:(NSString *)cacheName
{
    self = [super init];
    
    if (self) {
        self->_cacheName = cacheName;
    }
    
    return self;
}

- (JFFSQLiteDB *)db
{
    if (!self->_db) {
        self->_db = [[JFFSQLiteDB alloc] initWithDBName:self->_cacheName];
        
        dispatch_barrier_async(self->_db.queue, ^ {
            [self->_db execQuery:createRecords];
        });
    }
    return self->_db;
}

- (NSTimeInterval)currentTime
{
    return [[NSDate new] timeIntervalSince1970];
}

- (BOOL)execQuery:(NSString *)sql
{
    return [[self db] execQuery:sql];
}

- (BOOL)prepareQuery:(NSString *)sql
           statement:(sqlite3_stmt **)statement;
{
    return [[self db] prepareQuery:sql statement:statement];
}

- (NSString *)errorMessage
{
    return [[self db] errorMessage];
}

- (void)updateAccessTime:(NSString *)recordID
{
    dispatch_barrier_async([self db].queue, ^ {
        [self execQuery:[[NSString alloc] initWithFormat:@"UPDATE records SET access_time='%f' WHERE record_id='%@';",
                         [self currentTime],
                         recordID]];
    });
}

- (NSString *)fileLinkForRecordId:(NSString *)recordId
{
    NSString *query = [[NSString alloc] initWithFormat: @"SELECT file_link FROM records WHERE record_id='%@';",
                       recordId];
    
    __block NSString *result;
    
    safe_dispatch_sync([self db].queue, ^{
        
        sqlite3_stmt *statement = 0;
        if ([[self db] prepareQuery:query statement:&statement]) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                result = @((const char *)sqlite3_column_text(statement, 0));
            }
            sqlite3_finalize(statement);
        }
    });
    
    return result;
}

- (void)removeRecordsForKey:(id)key
{
    NSString *recordId = [key toCompositeKey];
    
    NSString *fileLink = [self fileLinkForRecordId:recordId];
    if (!fileLink)
        return;
    
    [self removeRecordsForRecordId:recordId
                          fileLink:fileLink];
}

- (void)removeRecordsForRecordId:(id)recordId
                        fileLink:(NSString *)fileLink
{
    [fileLink cacheDBFileLinkRemoveFile];
    
    NSString *removeQuery = [[NSString alloc] initWithFormat:@"DELETE FROM records WHERE record_id LIKE '%@';",
                             recordId];
    
    dispatch_barrier_async([self db].queue, ^ {
    
        sqlite3_stmt *statement = 0;
        if ([self prepareQuery:removeQuery statement:&statement]) {
            if(sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"%@ - %@", removeQuery, [self errorMessage]);
            }
            
            sqlite3_finalize(statement);
        }
    });
}

- (void)updateData:(NSData *)data
         forRecord:(NSString *)recordId
          fileLink:(NSString *)fileLink
{
    [fileLink cacheDBFileLinkSaveData:data];
    
    NSString *updateQuery = [[NSString alloc] initWithFormat:@"UPDATE records SET update_time='%f', access_time='%f' WHERE record_id='%@';",
                             [self currentTime],
                             [self currentTime],
                             recordId];
    
    dispatch_barrier_async([self db].queue, ^ {
        
        sqlite3_stmt *statement = 0;
        if ([self prepareQuery:updateQuery statement:&statement]) {
            if(sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"%@ - %@", updateQuery, [self errorMessage]);
            }
            
            sqlite3_finalize(statement);
        }
    });
}

- (void)addData:(NSData *)data forRecord:(NSString *)recordId
{
    NSString *fileLink = [NSString createUuid];
    
    static NSString *const addQueryFormat = @"INSERT INTO records (record_id, file_link, update_time, access_time) VALUES ('%@', '%@', '%f', '%f');";
    NSString *addQuery = [[NSString alloc] initWithFormat:addQueryFormat,
                          recordId,
                          fileLink,
                          [self currentTime],
                          [self currentTime]];
    
    dispatch_barrier_async([self db].queue, ^ {
        sqlite3_stmt *statement = 0;
        
        if ([self prepareQuery:addQuery statement:&statement]) {
            if (sqlite3_step(statement) == SQLITE_DONE) {
                [fileLink cacheDBFileLinkSaveData: data];
            } else {
                NSLog(@"%@ - %@", addQuery, [self errorMessage]);
            }
            
            sqlite3_finalize(statement);
        } else {
            NSLog(@"%@ - %@", addQuery, [self errorMessage]);
        }
    });
}

//JTODO test !!!!
- (void)removeRecordsToDate:(NSDate *)date
              dateFieldName:(NSString *)fieldName
{
    ///First remove all files
    NSString *query = [[NSString alloc] initWithFormat:@"SELECT file_link FROM records WHERE %@ < '%f';",
                       fieldName,
                       [date timeIntervalSince1970]];
    
    dispatch_barrier_async([self db].queue, ^ {
        
        sqlite3_stmt* statement = 0;
        
        if ([self.db prepareQuery:query statement:&statement]) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                const unsigned char *str = sqlite3_column_text(statement, 0);
                NSString *fileLink = @((const char *)str);
                
                [fileLink cacheDBFileLinkRemoveFile];
            }
            sqlite3_finalize(statement);
        }
        
        //////////
        
        {
            NSString* removeQuery = [[NSString alloc] initWithFormat:@"DELETE FROM records WHERE %@ < '%f';",
                                     fieldName,
                                     [date timeIntervalSince1970]];
            
            sqlite3_stmt *statement_ = 0;
            if ( [ self prepareQuery: removeQuery statement: &statement_ ] ) {
                if( sqlite3_step( statement_ ) != SQLITE_DONE ) {
                    NSLog(@"%@ - %@", removeQuery, [self errorMessage]);
                }
                
                sqlite3_finalize( statement_ );
            }
        }
    });
}

- (void)removeRecordsToUpdateDate:(NSDate *)date
{
    [self removeRecordsToDate:date dateFieldName:@"update_time"];
}

- (void)removeRecordsToAccessDate:(NSDate *)date
{
    [self removeRecordsToDate:date dateFieldName:@"access_time"];
}

- (NSData *)dataForKey:(id)key
{
    return [self dataForKey:key lastUpdateTime:nil];
}

- (NSData *)dataForKey:(id)key lastUpdateTime:(NSDate *__autoreleasing *)date
{
    NSString *recordId = [key toCompositeKey];
    
    static const NSUInteger linkIndex = 0;
    static const NSUInteger dateIndex = 1;
    
    static NSString *const queryFormat = @"SELECT file_link, update_time FROM records WHERE record_id='%@';";
    NSString *query = [[NSString alloc] initWithFormat:queryFormat, recordId];
    
    __block NSData *recordData;
    
    safe_dispatch_sync([self db].queue, ^ {
    
        sqlite3_stmt *statement = 0;
        if ([self.db prepareQuery:query statement:&statement]) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                const unsigned char *str = sqlite3_column_text(statement, linkIndex);
                NSString *fileLink = @((const char *)str);
                recordData = [fileLink cacheDBFileLinkData];
                
                if (date && recordData)
                {
                    NSTimeInterval dateInetrval = sqlite3_column_double(statement, dateIndex);
                    *date = [[NSDate alloc] initWithTimeIntervalSince1970:dateInetrval];
                }
            }
            sqlite3_finalize(statement);
        }
    });
    
    if (recordData) {
        [self updateAccessTime:recordId];
    }
    
    return recordData;
}

- (NSDate *)lastUpdateTimeForKey:(id)key
{
    NSString *recordId = [key toCompositeKey];
    
    static const NSUInteger dateIndex = 0;
    
    static NSString *const queryFormat = @"SELECT update_time FROM records WHERE record_id='%@';";
    NSString *query = [[NSString alloc]initWithFormat:queryFormat, recordId];
    
    __block NSDate *result;
    
    safe_dispatch_sync([self db].queue, ^ {
    
        sqlite3_stmt *statement = 0;
        if ([self.db prepareQuery:query statement:&statement]) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                NSTimeInterval dateInetrval = sqlite3_column_double(statement, dateIndex);
                result = [[NSDate alloc] initWithTimeIntervalSince1970:dateInetrval];
            }
            sqlite3_finalize(statement);
        }
    });
    
    return result;
}

//JTODO test
- (void)removeAllRecords
{
    ///First remove all files
    NSString *query = @"SELECT file_link FROM records;";
    
    dispatch_barrier_async([self db].queue, ^ {
        
        sqlite3_stmt *statement = 0;
        if ([self.db prepareQuery:query statement:&statement]) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                const unsigned char *str = sqlite3_column_text(statement, 0);
                NSString *fileLink = @((const char *)str);
                
                //TODO remove files in separate tread, do nont wait it
                [fileLink cacheDBFileLinkRemoveFile];
            }
            sqlite3_finalize(statement);
        }
        
        // remove records in sqlite
        {
            static NSString *const removeQuery = @"DELETE * FROM records;";
            
            sqlite3_stmt *statement = 0;
            if ([self prepareQuery:removeQuery statement:&statement]) {
                if( sqlite3_step( statement ) != SQLITE_DONE ) {
                    NSLog(@"%@ - %@", removeQuery, [self errorMessage]);
                }
                
                sqlite3_finalize( statement );
            }
        }
    });
}

- (void)setData:(NSData *)data
         forKey:(id)key
{
    NSString *recordId = [key toCompositeKey];
    
    NSString* fileLink = [self fileLinkForRecordId: recordId];
    
    if (!data && [fileLink length] != 0) {
        [self removeRecordsForRecordId:recordId
                              fileLink:fileLink];
        return;
    }
    
    if ([fileLink length] != 0 ) {
        [self updateData:data
               forRecord:recordId
                fileLink:fileLink];
    } else {
        [self addData:data forRecord:recordId];
    }
}

@end
