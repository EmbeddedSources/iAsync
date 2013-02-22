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
@property (nonatomic, readonly) NSString *folder;

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
        
        NSString *const dbPath = [NSString documentsPathByAppendingPathComponent:dbName];
        
        _folder = [dbPath stringByDeletingLastPathComponent];
        
        __block BOOL ok = NO;
        
        safe_dispatch_barrier_sync(self.queue, ^{
            
            BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:_folder
                                                     withIntermediateDirectories:YES
                                                                      attributes:nil
                                                                           error:nil];
            
            NSParameterAssert(created);
            
            if (sqlite3_open([dbPath UTF8String], &_db) != SQLITE_OK) {
                NSLog(@"open - %@ path: %@", [self errorMessage], dbPath);
                return;
            };
            
            [dbPath addSkipBackupAttribute];
            
            const char *cacheSizePragma = "PRAGMA cache_size = 1000";
            
            if (sqlite3_exec(_db, cacheSizePragma, 0, 0, 0) != SQLITE_OK) {
                NSAssert1(0,
                          @"Error: failed to execute pragma statement with message '%s'.",
                          sqlite3_errmsg(_db));
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
    return sqlite3_prepare_v2(_db,
                              [sql UTF8String],
                              -1,
                              statement,
                              0) == SQLITE_OK;
}

- (BOOL)execQuery:(NSString *)sql
{
    char *errorMessage = 0;
    if (sqlite3_exec(_db, [sql UTF8String], 0, 0, &errorMessage) != SQLITE_OK) {
        NSLog(@"%@ error: %s", sql, errorMessage);
        
        sqlite3_free(errorMessage);
        return NO;
    }
    
    return YES;
}

- (NSString *)errorMessage
{
    return @(sqlite3_errmsg(_db));
}

@end

@interface JFFBaseDB ()

@property (nonatomic, readonly) JFFSQLiteDB *db;

@end

@implementation JFFBaseDB
{
    NSString *_cacheFileName;
    NSString *_cachePath;
    JFFSQLiteDB *_db;
}

- (id)initWithCacheFileName:(NSString *)cacheName
{
    NSParameterAssert(cacheName);
    
    self = [super init];
    
    if (self) {
        _cacheFileName = cacheName;
    }
    
    return self;
}

- (JFFSQLiteDB *)db
{
    if (!_db) {
        _db = [[JFFSQLiteDB alloc] initWithDBName:_cacheFileName];
        
        NSParameterAssert(_db);
        if (_db) {
            dispatch_barrier_async(_db.queue, ^ {
                [_db execQuery:createRecords];
            });
        }
    }
    return _db;
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
    NSString *query = [[NSString alloc] initWithFormat:@"SELECT file_link FROM records WHERE record_id='%@';",
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
    [fileLink cacheDBFileLinkRemoveFileWithFolder:self.db.folder];
    
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
    [fileLink cacheDBFileLinkSaveData:data folder:self.db.folder];
    
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
                [fileLink cacheDBFileLinkSaveData:data folder:self.db.folder];
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
                
                @autoreleasepool {
                    
                    const unsigned char *str = sqlite3_column_text(statement, 0);
                    NSString *fileLink = @((const char *)str);
                    
                    [fileLink cacheDBFileLinkRemoveFileWithFolder:self.db.folder];
                }
            }
            sqlite3_finalize(statement);
        }
        
        //////////
        
        {
            NSString* removeQuery = [[NSString alloc] initWithFormat:@"DELETE FROM records WHERE %@ < '%f';",
                                     fieldName,
                                     [date timeIntervalSince1970]];
            
            sqlite3_stmt *statement = 0;
            if ([self prepareQuery:removeQuery statement:&statement]) {
                if(sqlite3_step( statement ) != SQLITE_DONE ) {
                    NSLog(@"%@ - %@", removeQuery, [self errorMessage]);
                }
                
                sqlite3_finalize(statement);
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

- (unsigned long long int)folderSize
{
    NSString *folderPath = self.db.folder;
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        
        @autoreleasepool {
            
            NSString *path = [folderPath stringByAppendingPathComponent:fileName];
            NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
            fileSize += [fileDictionary fileSize];
        }
    }
    
    return fileSize;
}

- (void)removeRecordsWhileTotalSizeMoreThenBytes:(unsigned long long)sizeInBytes
{
    NSString *selectQuery = [[NSString alloc] initWithFormat:@"SELECT file_link FROM records ORDER BY access_time"]; //ORDER BY ASC is default
    
    dispatch_barrier_async([self db].queue, ^ {
        
        unsigned long long int totalSize = [self folderSize];
        unsigned long long int filesRemoved = 0;
        
        if (totalSize > sizeInBytes)
        {
            unsigned long long int sizeToRemove = totalSize - sizeInBytes;
            
            sqlite3_stmt* statement = 0;
            
            NSString *selectQuery2 = [[NSString alloc] initWithFormat:@"%@;", selectQuery]; //ORDER BY ASC is default
            if ([self.db prepareQuery:selectQuery2 statement:&statement]) {
                
                while (sqlite3_step(statement) == SQLITE_ROW && sizeToRemove > 0) {
                    
                    @autoreleasepool {
                    
                        const unsigned char *str = sqlite3_column_text(statement, 0);
                        NSString *fileLink = @((const char *)str);
                        
                        //remove file
                        {
                            NSString *filePath = [fileLink cacheDBFileLinkPathWithFolder:self.db.folder];
                            NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
                            unsigned long long int fileSize = [fileDictionary fileSize];
                            
                            ++filesRemoved;
                            if (sizeToRemove > fileSize) {
                                
                                sizeToRemove -= fileSize;
                            } else {
                                
                                sizeToRemove = 0;
                            }
                            
                            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                            
                        }
                    }
                }
                sqlite3_finalize(statement);
            }
        }
        
        //////////
        
        if (filesRemoved > 0) {
            
            NSString *removeQuery = [[NSString alloc] initWithFormat:@"DELETE FROM records WHERE file_link IN (%@ LIMIT %llu);", selectQuery, filesRemoved];
            
            sqlite3_stmt *statement = 0;
            if ([self prepareQuery:removeQuery statement:&statement]) {
                if(sqlite3_step( statement ) != SQLITE_DONE ) {
                    NSLog(@"%@ - %@", removeQuery, [self errorMessage]);
                }
                
                sqlite3_finalize(statement);
            }
        }
    });
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
                recordData = [fileLink cacheDBFileLinkDataWithFolder:self.db.folder];
                
                if (date && recordData) {
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

- (void)removeAllRecordsWithCallback:(JFFSimpleBlock)callback
{
    callback = [callback copy];
    ///First remove all files
    NSString *query = @"SELECT file_link FROM records;";
    
    dispatch_barrier_async([self db].queue, ^ {
        
        sqlite3_stmt *statement = 0;
        if ([self.db prepareQuery:query statement:&statement]) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                @autoreleasepool {
                    
                    const unsigned char *str = sqlite3_column_text(statement, 0);
                    NSString *fileLink = @((const char *)str);
                    
                    //JTODO remove files in separate tread, do nont wait it
                    [fileLink cacheDBFileLinkRemoveFileWithFolder:self.db.folder];
                }
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
        
        if (callback)
            callback();
    });
}

- (void)setData:(NSData *)data
         forKey:(id)key
{
    NSString *recordId = [key toCompositeKey];
    
    NSString* fileLink = [self fileLinkForRecordId:recordId];
    
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
