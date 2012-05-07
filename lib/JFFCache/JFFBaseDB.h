#import <Foundation/Foundation.h>

@class JFFSQLiteDB;

@interface JFFBaseDB : NSObject

@property ( nonatomic, readonly ) JFFSQLiteDB* db;
@property ( nonatomic, readonly ) NSString* name;

-(id)initWithDBName:( NSString* )dbName_
          cacheName:( NSString* )cacheName_;

-(NSData*)dataForKey:( id )key_;
-(NSData*)dataForKey:( id )key_ lastUpdateTime:( NSDate** )date_;

-(void)setData:( NSData* )data_ forKey:( id )key_;

-(void)removeRecordsToUpdateDate:( NSDate* )date_;
-(void)removeRecordsToAccessDate:( NSDate* )date_;

-(void)removeRecordsForKey:( id )key_;

-(void)removeAllRecords;

@end
