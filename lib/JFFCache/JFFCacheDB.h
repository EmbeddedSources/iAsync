#import <Foundation/Foundation.h>

@protocol JFFCacheDB < NSObject >

@required

@property ( nonatomic, retain, readonly ) NSString* name;

-(NSData*)dataForKey:( id )key_;
-(NSData*)dataForKey:( id )key_ lastUpdateTime:( NSDate** )date_;

-(void)setData:( NSData* )data_ forKey:( id )key_;

-(void)removeRecordsForKey:( id )key_;

-(void)migrateDB;

@end
