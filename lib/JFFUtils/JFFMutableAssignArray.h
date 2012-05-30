#import <JFFUtils/NSArray/JUArrayHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface JFFMutableAssignArray : NSObject

@property ( nonatomic, copy, readonly ) NSArray* array;

+(id)arrayWithObject:( id )anObject_;

//compare elements by pointers only
-(void)addObject:( id )object_;
-(BOOL)containsObject:( id )object_;
-(void)removeObject:( id )object_;
-(void)removeAllObjects;

-(NSUInteger)count;

-(id)firstMatch:( JFFPredicateBlock )predicate_;
-(void)enumerateObjectsUsingBlock:( void (^)( id obj, NSUInteger idx, BOOL* stop ) )block_;

@end
