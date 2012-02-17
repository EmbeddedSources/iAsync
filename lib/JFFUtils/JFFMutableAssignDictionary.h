#import <Foundation/Foundation.h>

@interface JFFMutableAssignDictionary : NSObject

//JTODO remove
//should return native object, not assign wrapper
@property ( nonatomic, copy, readonly ) NSDictionary* dictionary;

-(NSUInteger)count;
-(id)objectForKey:( id )key_;

-(void)removeObjectForKey:( id )key_;
-(void)setObject:( id )object_ forKey:( id )key_;

-(void)removeAllObjects;

-(NSArray*)allKeys;
-(NSArray*)allValues;

@end
