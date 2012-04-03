#import "JFFBaseDB.h"
#import "JFFDBCompositeKey.h"

#import "NSString+CompositeKey.h"
#import "NSObject+CompositeKey.h"

#import <sqlite3.h>

static NSString* const createRecords_ =
@"CREATE TABLE IF NOT EXISTS records ( "
@"record_id TEXT primary key"
@", record_data blob"
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

-(id)initWithDBName:( NSString* )db_name_
{
    self = [ super init ];

    if ( self )
    {
        NSString* const db_path_ = [ NSString cachesPathByAppendingPathComponent: db_name_ ];
        if ( sqlite3_open( [ db_path_ UTF8String ], &_db ) != SQLITE_OK )
        {
            NSLog( @"Can't open %@ db", db_path_ );
            return nil;
        }

        const char *cache_size_pragma_ = "PRAGMA cache_size = 100";
        if ( sqlite3_exec( _db, cache_size_pragma_, 0, 0, 0 ) != SQLITE_OK )
        {
            NSAssert1( 0, @"Error: failed to execute pragma statement with message '%s'.", sqlite3_errmsg( _db ) );
        }
    }

    return self;
}

-(BOOL)prepareQuery:( NSString* )sql_
          statement:( sqlite3_stmt** )statement_
{
    return sqlite3_prepare_v2( _db
                              , [ sql_ UTF8String ]
                              , -1
                              , statement_
                              , 0) == SQLITE_OK;
}

-(BOOL)execQuery:( NSString* )sql_
{
    char* error_message_ = 0;
    if ( sqlite3_exec( _db, [ sql_ UTF8String ], 0, 0, &error_message_ ) != SQLITE_OK )
    {
        NSLog( @"%@ error: %s", sql_, error_message_ );

        sqlite3_free( error_message_ );
        return NO;
    }

    return YES;
}

-(NSString*)errorMessage
{
    return [ NSString stringWithUTF8String: sqlite3_errmsg( _db ) ];
}

-(void)dealloc
{
    sqlite3_close( _db );
}

@end

@interface JFFBaseDB ()

@property ( nonatomic, strong ) JFFSQLiteDB* db;
@property ( nonatomic, strong ) NSString* name;

@end

@implementation JFFBaseDB

@synthesize db = _db;
@synthesize name = _name;

-(id)initWithDBName:( NSString* )dbName_
          cacheName:( NSString* )cacheName_
{
    self = [ super init ];

    if ( self )
    {
        _name = cacheName_;

        _db = [ [ JFFSQLiteDB alloc ] initWithDBName: dbName_ ];
        [ _db execQuery: createRecords_ ];
    }

    return self;
}

-(NSTimeInterval)currentTime
{
    return [ [ NSDate date ] timeIntervalSince1970 ];
}

-(BOOL)execQuery:( NSString* )sql_
{
    return [ self.db execQuery: sql_ ];
}

-(BOOL)prepareQuery:( NSString* )sql_
          statement:( sqlite3_stmt** )statement_;
{
    return [ self.db prepareQuery: sql_ statement: statement_ ];
}

-(NSString*)errorMessage
{
    return [ self.db errorMessage ];
}

-(void)updateAccessTime:( NSString* )record_id_
{
    [ self execQuery: [ NSString stringWithFormat: @"UPDATE records SET access_time='%f' WHERE record_id='%@';"
                       , [ self currentTime ]
                       , record_id_ ] ];
}

-(BOOL)hasRecord:( NSString* )record_id_
{
    NSString* query_ = [ NSString stringWithFormat: @"SELECT record_id FROM records WHERE record_id='%@';", record_id_ ];

    sqlite3_stmt* statement_ = 0;

    BOOL result_ = NO;

    if ( [ self.db prepareQuery: query_ statement: &statement_ ] )
    {
        result_ = ( sqlite3_step( statement_ ) == SQLITE_ROW );

        sqlite3_finalize( statement_ );
    }

    return result_;   
}

-(void)removeRecordsForKey:( id )key_ 
{
    NSString* recordId_ = [ key_ toCompositeKey ];
    NSString* remove_query_ = [ NSString stringWithFormat: @"DELETE FROM records WHERE record_id LIKE '%@';"
                               , recordId_ ];

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

-(void)updateData:( NSData* )data_ forRecord:( NSString* )record_id_
{
    NSString* update_query_ = [ NSString stringWithFormat: @"UPDATE records SET record_data=?, update_time='%f', access_time='%f' WHERE record_id='%@';"
                               , [ self currentTime ]
                               , [ self currentTime ]
                               , record_id_ ];

    sqlite3_stmt* statement_ = 0;
    if ( [ self prepareQuery: update_query_ statement: &statement_ ] )
    {
        sqlite3_bind_blob( statement_, 1, [ data_ bytes ], [ data_ length ], 0 );

        if( sqlite3_step( statement_ ) != SQLITE_DONE )
        {
            NSLog( @"%@", [ self errorMessage ] );
        }

        sqlite3_finalize( statement_ );
    }
}

-(void)addData:( NSData* )data_ forRecord:( NSString* )record_id_
{
    NSString* add_query_ = [ NSString stringWithFormat: @"INSERT INTO records (record_id, record_data, update_time, access_time) VALUES ('%@', ?, '%f', '%f');"
                            , record_id_
                            , [ self currentTime ]
                            , [ self currentTime ] ];

    sqlite3_stmt* statement_ = 0;
    if ( [ self prepareQuery: add_query_ statement: &statement_ ] )
    {
        sqlite3_bind_blob( statement_, 1, [ data_ bytes ], [ data_ length ], 0 );

        if( sqlite3_step( statement_ ) != SQLITE_DONE )
        {
            NSLog( @"%@", [ self errorMessage ] );
        }

        sqlite3_finalize( statement_ );
    }
}

-(void)removeRecordsToDate:( NSDate* )date_
             dateFieldName:( NSString* )field_name_
{
    NSString* remove_query_ = [ NSString stringWithFormat: @"DELETE FROM records WHERE %@ < '%f';"
                               , field_name_
                               , [ date_ timeIntervalSince1970 ] ];

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
    NSString* record_id_ = [ key_ toCompositeKey ];

    static const NSUInteger data_index_ = 0;
    static const NSUInteger date_index_ = 1;

    NSString* query_ = [ NSString stringWithFormat: @"SELECT record_data, update_time FROM records WHERE record_id='%@';", record_id_ ];

    NSData* record_data_ = nil;

    sqlite3_stmt* statement_ = 0;
    if ( [ self.db prepareQuery: query_ statement: &statement_ ] )
    {
        if ( sqlite3_step( statement_ ) == SQLITE_ROW )
        {
            NSUInteger data_length_ = sqlite3_column_bytes( statement_, data_index_ );
            record_data_ = [ NSData dataWithBytes: sqlite3_column_blob( statement_, data_index_ ) 
                                           length: data_length_ ];

            if ( date_ )
            {
                NSTimeInterval dateInetrval_ = sqlite3_column_double( statement_, date_index_ );
                *date_ = [ NSDate dateWithTimeIntervalSince1970: dateInetrval_ ];
            }
        }
        sqlite3_finalize( statement_ );
    }

    if ( record_data_ )
    {
        [ self updateAccessTime: record_id_ ];
    }

    return record_data_;
}

-(void)removeAllRecords
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

-(void)setData:( NSData* )data_
        forKey:( id )key_
{
    NSString* record_id_ = [ key_ toCompositeKey ];

    if ( [ self hasRecord: record_id_ ] )
    {
        [ self updateData: data_ forRecord: record_id_ ];
    }
    else
    {
        [ self addData: data_ forRecord: record_id_ ];
    }
}

@end
