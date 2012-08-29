#import "JFFBaseDB.h"
#import "JFFDBCompositeKey.h"

#import "NSString+CompositeKey.h"
#import "NSObject+CompositeKey.h"

#import <sqlite3.h>

static NSString* const createRecords_ =
@"CREATE TABLE IF NOT EXISTS records ( "
@"record_id TEXT primary key"
@", file_link varchar(100)"
@", update_time real"
@", access_time real );";

@interface JFFSQLiteDB : NSObject
{
    sqlite3* _db;
}

-(id)initWithDBName:( NSString* )db_name_;

-(BOOL)prepareQuery:( NSString* )sql_
          statement:( sqlite3_stmt** )statement_;

-(BOOL)execQuery:( NSString* )sql_;

-(NSString*)errorMessage;

@end

@implementation JFFSQLiteDB

-(id)initWithDBName:( NSString* )dbName_
{
    self = [ super init ];

    if ( self )
    {
        NSString* const dbPath_ = [ NSString cachesPathByAppendingPathComponent: dbName_ ];
        if ( sqlite3_open( [ dbPath_ UTF8String ], &self->_db ) != SQLITE_OK )
        {
            NSLog( @"Can't open %@ db", dbPath_ );
            return nil;
        }

        const char *cacheSizePragma_ = "PRAGMA cache_size = 1000";
        if ( sqlite3_exec( self->_db, cacheSizePragma_, 0, 0, 0 ) != SQLITE_OK )
        {
            NSAssert1( 0, @"Error: failed to execute pragma statement with message '%s'."
                      , sqlite3_errmsg( self->_db ) );
        }
    }

    return self;
}

-(BOOL)prepareQuery:( NSString* )sql_
          statement:( sqlite3_stmt** )statement_
{
    return sqlite3_prepare_v2( self->_db
                              , [ sql_ UTF8String ]
                              , -1
                              , statement_
                              , 0) == SQLITE_OK;
}

-(BOOL)execQuery:( NSString* )sql_
{
    char* error_message_ = 0;
    if ( sqlite3_exec( self->_db, [ sql_ UTF8String ], 0, 0, &error_message_ ) != SQLITE_OK )
    {
        NSLog( @"%@ error: %s", sql_, error_message_ );

        sqlite3_free( error_message_ );
        return NO;
    }

    return YES;
}

-(NSString*)errorMessage
{
    return [ [ NSString alloc ] initWithUTF8String: sqlite3_errmsg( _db ) ];
}

-(void)dealloc
{
    sqlite3_close( self->_db );
}

@end

@interface JFFBaseDB ()

@property ( nonatomic ) JFFSQLiteDB* db;
@property ( nonatomic ) NSString* name;

@end

@implementation JFFBaseDB

-(id)initWithDBName:( NSString* )dbName_
          cacheName:( NSString* )cacheName_
{
    self = [ super init ];

    if ( self )
    {
        self->_name = cacheName_;

        self->_db = [ [ JFFSQLiteDB alloc ] initWithDBName: dbName_ ];
        [ self->_db execQuery: createRecords_ ];
    }

    return self;
}

-(NSTimeInterval)currentTime
{
    return [ [ NSDate new ] timeIntervalSince1970 ];
}

-(BOOL)execQuery:( NSString* )sql_
{
    return [ self->_db execQuery: sql_ ];
}

-(BOOL)prepareQuery:( NSString* )sql_
          statement:( sqlite3_stmt** )statement_;
{
    return [ self->_db prepareQuery: sql_ statement: statement_ ];
}

-(NSString*)errorMessage
{
    return [ self->_db errorMessage ];
}

-(void)updateAccessTime:( NSString* )record_id_
{
    [ self execQuery: [ [ NSString alloc ] initWithFormat: @"UPDATE records SET access_time='%f' WHERE record_id='%@';"
                       , [ self currentTime ]
                       , record_id_ ] ];
}

-(NSString*)fileLinkForRecordId:( NSString* )recordId_
{
    NSString* query_ = [ [ NSString alloc ] initWithFormat: @"SELECT file_link FROM records WHERE record_id='%@';"
                        , recordId_ ];

    sqlite3_stmt* statement_ = 0;

    NSString* result_ = nil;

    if ( [ self->_db prepareQuery: query_ statement: &statement_ ] )
    {
        if ( sqlite3_step( statement_ ) == SQLITE_ROW )
        {
            const unsigned char * str_ = sqlite3_column_text( statement_, 0 );
             result_ = [ [ NSString alloc ] initWithUTF8String: (const char *)str_ ];
        }
        sqlite3_finalize( statement_ );
    }

    return result_;   
}

-(void)removeRecordsForKey:( id )key_ 
{
    NSString* recordId_ = [ key_ toCompositeKey ];

    NSString* fileLink_ = [ self fileLinkForRecordId: recordId_ ];
    if ( !fileLink_ )
        return;

    [ self removeRecordsForRecordId: recordId_ 
                           fileLink: fileLink_ ];
}

-(void)removeRecordsForRecordId:( id )recordId_ 
                       fileLink:( NSString* )fileLink_
{
    fileLink_ = [ NSString cachesPathByAppendingPathComponent: fileLink_ ];
    [ [ NSFileManager defaultManager ] removeItemAtPath: fileLink_ error: nil ];

    NSString* removeQuery_ = [ [ NSString alloc ] initWithFormat: @"DELETE FROM records WHERE record_id LIKE '%@';"
                              , recordId_ ];

    sqlite3_stmt* statement_ = 0;
    if ( [ self prepareQuery: removeQuery_ statement: &statement_ ] )
    {
        if( sqlite3_step( statement_ ) != SQLITE_DONE )
        {
            NSLog( @"%@", [ self errorMessage ] );
        }

        sqlite3_finalize( statement_ );
    }
}

-(void)updateData:( NSData* )data_
        forRecord:( NSString* )recordId_
         fileLink:( NSString* )fileLink_
{
    fileLink_ = [ NSString cachesPathByAppendingPathComponent: fileLink_ ];
    NSURL* url_ = [ NSURL fileURLWithPath: fileLink_ ];
    [ data_ writeToURL: url_ atomically: NO ];

    NSString* updateQuery_ = [ [ NSString alloc ] initWithFormat: @"UPDATE records SET update_time='%f', access_time='%f' WHERE record_id='%@';"
                               , [ self currentTime ]
                               , [ self currentTime ]
                               , recordId_ ];

    sqlite3_stmt* statement_ = 0;
    if ( [ self prepareQuery: updateQuery_ statement: &statement_ ] )
    {
        if( sqlite3_step( statement_ ) != SQLITE_DONE )
        {
            NSLog( @"%@", [ self errorMessage ] );
        }

        sqlite3_finalize( statement_ );
    }
}

-(void)addData:( NSData* )data_ forRecord:( NSString* )recordId_
{
    NSString* fileLink_ = [ NSString createUuid ];

    NSString* addQuery_ = [ [ NSString alloc ] initWithFormat: @"INSERT INTO records (record_id, file_link, update_time, access_time) VALUES ('%@', '%@', '%f', '%f');"
                           , recordId_
                           , fileLink_
                           , [ self currentTime ]
                           , [ self currentTime ] ];

    sqlite3_stmt* statement_ = 0;
    if ( [ self prepareQuery: addQuery_ statement: &statement_ ] )
    {
        if ( sqlite3_step( statement_ ) == SQLITE_DONE )
        {
            fileLink_ = [ NSString cachesPathByAppendingPathComponent: fileLink_ ];
            NSURL* url_ = [ NSURL fileURLWithPath: fileLink_ ];
            [ data_ writeToURL: url_ atomically: NO ];
        }
        else
        {
            NSLog( @"%@", [ self errorMessage ] );
        }

        sqlite3_finalize( statement_ );
    }
    else
    {
        NSLog( @"%@", [ self errorMessage ] );
    }
}

//JTODO test !!!!
-(void)removeRecordsToDate:( NSDate* )date_
             dateFieldName:( NSString* )fieldName_
{
    ///First remove all files
    NSString* query_ = [ [ NSString alloc ] initWithFormat: @"SELECT file_link FROM records WHERE %@ < '%f';"
                        , fieldName_
                        , [ date_ timeIntervalSince1970 ] ];

    sqlite3_stmt* statement_ = 0;

    if ( [ self.db prepareQuery: query_ statement: &statement_ ] )
    {
        while ( sqlite3_step( statement_ ) == SQLITE_ROW )
        {
            const unsigned char * str_ = sqlite3_column_text( statement_, 0 );
            NSString* fileLink_ = [ [ NSString alloc ] initWithUTF8String: (const char *)str_ ];

            fileLink_ = [ NSString cachesPathByAppendingPathComponent: fileLink_ ];
            [ [ NSFileManager defaultManager ] removeItemAtPath: fileLink_ error: nil ];
        }
        sqlite3_finalize( statement_ );
    }

    //////////

    {
        NSString* removeQuery_ = [ [ NSString alloc ] initWithFormat: @"DELETE FROM records WHERE %@ < '%f';"
                                   , fieldName_
                                   , [ date_ timeIntervalSince1970 ] ];

        sqlite3_stmt* statement_ = 0;
        if ( [ self prepareQuery: removeQuery_ statement: &statement_ ] )
        {
            if( sqlite3_step( statement_ ) != SQLITE_DONE )
            {
                NSLog( @"%@", [ self errorMessage ] );
            }

            sqlite3_finalize( statement_ );
        }
    }
}

-(void)removeRecordsToUpdateDate:( NSDate* )date_
{
    [ self removeRecordsToDate: date_ dateFieldName: @"update_time" ];
}

-(void)removeRecordsToAccessDate:( NSDate* )date_
{
    [ self removeRecordsToDate: date_ dateFieldName: @"access_time" ];
}

-(NSData*)dataForKey:( id )key_
{
    return [ self dataForKey: key_ lastUpdateTime: nil ];
}

-(NSData*)dataForKey:( id )key_ lastUpdateTime:( NSDate** )date_
{
    NSString* recordId_ = [ key_ toCompositeKey ];

    static const NSUInteger linkIndex_ = 0;
    static const NSUInteger dateIndex_ = 1;

    NSString* query_ = [ [ NSString alloc ] initWithFormat: @"SELECT file_link, update_time FROM records WHERE record_id='%@';", recordId_ ];

    NSData* recordData_ = nil;

    sqlite3_stmt* statement_ = 0;
    if ( [ self.db prepareQuery: query_ statement: &statement_ ] )
    {
        if ( sqlite3_step( statement_ ) == SQLITE_ROW )
        {
            const unsigned char * str_ = sqlite3_column_text( statement_, linkIndex_ );
            NSString* fileLink_ = [ [ NSString alloc ] initWithUTF8String: (const char *)str_ ];
            fileLink_ = [ NSString cachesPathByAppendingPathComponent: fileLink_ ];
            recordData_ = [ NSData dataWithContentsOfFile: fileLink_ ];

            if ( date_ && recordData_ )
            {
                NSTimeInterval dateInetrval_ = sqlite3_column_double( statement_, dateIndex_ );
                *date_ = [ NSDate dateWithTimeIntervalSince1970: dateInetrval_ ];
            }
        }
        sqlite3_finalize( statement_ );
    }

    if ( recordData_ )
    {
        [ self updateAccessTime: recordId_ ];
    }

    return recordData_;
}

//JTODO test
-(void)removeAllRecords
{
    ///First remove all files
    NSString* query_ = @"SELECT file_link FROM records;";

    sqlite3_stmt* statement_ = 0;

    if ( [ self.db prepareQuery: query_ statement: &statement_ ] )
    {
        while ( sqlite3_step( statement_ ) == SQLITE_ROW )
        {
            const unsigned char * str_ = sqlite3_column_text( statement_, 0 );
            NSString* fileLink_ = @((const char *)str_);

            fileLink_ = [ NSString cachesPathByAppendingPathComponent: fileLink_ ];
            [ [ NSFileManager defaultManager ] removeItemAtPath: fileLink_ error: nil ];
        }
        sqlite3_finalize( statement_ );
    }

    ////////
    {
        static NSString* const remove_query_ = @"DELETE * FROM records;";

        sqlite3_stmt* statement_ = 0;
        if ( [ self prepareQuery: remove_query_ statement: &statement_ ] )
        {
            if( sqlite3_step( statement_ ) != SQLITE_DONE )
            {
                NSLog( @"%@", [ self errorMessage ] );
            }

            sqlite3_finalize( statement_ );
        }
    }
}

-(void)setData:( NSData* )data_
        forKey:( id )key_
{
    NSString* recordId_ = [ key_ toCompositeKey ];

    NSString* fileLink_ = [ self fileLinkForRecordId: recordId_ ];

    if ( !data_ && [ fileLink_ length ] != 0 )
    {
        [ self removeRecordsForRecordId: recordId_ 
                               fileLink: fileLink_ ];
        return;
    }

    if ( [ fileLink_ length ] != 0 )
    {
        [ self updateData: data_
                forRecord: recordId_
                 fileLink: fileLink_ ];
    }
    else
    {
        [ self addData: data_ forRecord: recordId_ ];
    }
}

@end
