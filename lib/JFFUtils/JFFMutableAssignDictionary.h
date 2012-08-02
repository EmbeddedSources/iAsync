#import <JFFUtils/Dictionary/JUDictionaryHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface JFFMutableAssignDictionary : NSObject

-(void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block_;
-(NSDictionary*)map:( JFFDictMappingBlock )block_;

-(NSUInteger)count;

-(id)objectForKey:( id )key_;
-(id)objectForKeyedSubscript:( id )key_;

-(void)removeObjectForKey:( id )key_;

-(void)setObject:( id )object_ forKey:( id )key_;
-(void)setObject:( id )newValue_ forKeyedSubscript:( id )key_;

-(void)removeAllObjects;

@end
