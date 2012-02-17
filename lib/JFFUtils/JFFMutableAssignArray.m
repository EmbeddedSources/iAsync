#import "JFFMutableAssignArray.h"

#import "JFFAssignProxy.h"

#import "NSArray+BlocksAdditions.h"
#import "NSObject+OnDeallocBlock.h"

#include "JFFUtilsBlockDefinitions.h"

@interface JFFAutoRemoveAssignProxy : JFFAssignProxy

@property ( nonatomic, copy ) JFFSimpleBlock onDeallocBlock;

@end

@implementation JFFAutoRemoveAssignProxy

@synthesize onDeallocBlock = _on_dealloc_block;

-(void)onAddToMutableAssignArray:( JFFMutableAssignArray* )array_
{
   __unsafe_unretained JFFMutableAssignArray* assign_array_ = array_;
   __unsafe_unretained JFFAutoRemoveAssignProxy* self_ = self;
   self.onDeallocBlock = ^void( void )
   {
      [ assign_array_ removeObject: self_.target ];
   };
   [ self.target addOnDeallocBlock: self.onDeallocBlock ];
}

-(void)onRemoveFromMutableAssignArray:( JFFMutableAssignArray* )array_
{
   [ self.target removeOnDeallocBlock: self.onDeallocBlock ];
   self.onDeallocBlock = nil;
}

@end

@interface JFFMutableAssignArray ()

@property ( nonatomic, strong ) NSMutableArray* mutableArray;

@end

@implementation JFFMutableAssignArray

@synthesize mutableArray = _mutable_array;
@dynamic array;

-(void)dealloc
{
   [ self removeAllObjects ];
}

-(NSMutableArray*)mutableArray
{
   if ( !_mutable_array )
   {
      _mutable_array = [ NSMutableArray new ];
   }
   return _mutable_array;
}

-(NSArray*)array
{
   return [ _mutable_array map: ^id( JFFAutoRemoveAssignProxy* proxy_ )
   {
      return proxy_.target;
   } ];
}

-(void)addObject:( id )object_
{
   JFFAutoRemoveAssignProxy* proxy_ = [ [ JFFAutoRemoveAssignProxy alloc ] initWithTarget: object_ ];
   [ self.mutableArray addObject: proxy_ ];
   [ proxy_ onAddToMutableAssignArray: self ];
}

-(BOOL)containsObject:( id )object_
{
   return [ _mutable_array firstMatch: ^BOOL( id element_ )
   {
      JFFAutoRemoveAssignProxy* proxy_ = element_;
      return proxy_.target == object_;
   } ] != nil;
}

-(void)removeObject:( id )object_
{
   NSUInteger index_ = [ _mutable_array firstIndexOfObjectMatch: ^BOOL( id element_ )
   {
      JFFAutoRemoveAssignProxy* proxy_ = element_;
      return proxy_.target == object_;
   } ];

   if ( index_ != NSNotFound )
   {
      JFFAutoRemoveAssignProxy* proxy_ = [ _mutable_array objectAtIndex: index_ ];
      [  proxy_ onRemoveFromMutableAssignArray: self ];
      [ _mutable_array removeObjectAtIndex: index_ ];
   }
}

-(void)removeAllObjects
{
   for( JFFAutoRemoveAssignProxy* proxy_ in _mutable_array )
   {
      [  proxy_ onRemoveFromMutableAssignArray: self ];
   }
   [ _mutable_array removeAllObjects ];
}

-(NSUInteger)count
{
   return [ _mutable_array count ];
}

+(id)arrayWithObject:( id )anObject_
{
    JFFMutableAssignArray* result_ = [ self new ];
    [ result_ addObject: anObject_ ];
    return result_;
}

@end
