#import "JFFMutableAssignArray.h"

#import "JFFAssignProxy.h"

#import "NSArray+BlocksAdditions.h"
#import "NSObject+OnDeallocBlock.h"

#include "JFFUtilsBlockDefinitions.h"

@interface JFFAutoRemoveAssignProxy : JFFAssignProxy

@property ( nonatomic, copy ) JFFSimpleBlock onDeallocBlock;

@end

@implementation JFFAutoRemoveAssignProxy

@synthesize onDeallocBlock = _onDeallocBlock;

-(void)onAddToMutableAssignArray:( JFFMutableAssignArray* )array_
{
    __unsafe_unretained JFFMutableAssignArray* unretainedArray_ = array_;
    __unsafe_unretained JFFAutoRemoveAssignProxy* self_ = self;
    self.onDeallocBlock = ^void( void )
    {
        [ unretainedArray_ removeObject: self_.target ];
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

@property ( nonatomic ) NSMutableArray* mutableArray;

@end

@implementation JFFMutableAssignArray

@synthesize mutableArray = _mutableArray;
@dynamic array;

-(void)dealloc
{
    [ self removeAllObjects ];
}

-(NSMutableArray*)mutableArray
{
    if ( !_mutableArray )
    {
        _mutableArray = [ NSMutableArray new ];
    }
    return _mutableArray;
}

-(NSArray*)array
{
    return [ _mutableArray map: ^id( JFFAutoRemoveAssignProxy* proxy_ )
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
    return [ _mutableArray firstMatch: ^BOOL( id element_ )
    {
        JFFAutoRemoveAssignProxy* proxy_ = element_;
        return proxy_.target == object_;
    } ] != nil;
}

-(void)removeObject:( id )object_
{
    NSUInteger index_ = [ _mutableArray firstIndexOfObjectMatch: ^BOOL( id element_ )
    {
        JFFAutoRemoveAssignProxy* proxy_ = element_;
        return proxy_.target == object_;
    } ];

    if ( index_ != NSNotFound )
    {
        JFFAutoRemoveAssignProxy* proxy_ = [ _mutableArray objectAtIndex: index_ ];
        [  proxy_ onRemoveFromMutableAssignArray: self ];
        [ _mutableArray removeObjectAtIndex: index_ ];
    }
}

-(void)removeAllObjects
{
    for( JFFAutoRemoveAssignProxy* proxy_ in _mutableArray )
    {
        [  proxy_ onRemoveFromMutableAssignArray: self ];
    }
    [ _mutableArray removeAllObjects ];
}

-(NSUInteger)count
{
    return [ _mutableArray count ];
}

+(id)arrayWithObject:( id )anObject_
{
    JFFMutableAssignArray* result_ = [ self new ];
    [ result_ addObject: anObject_ ];
    return result_;
}

-(id)firstMatch:( JFFPredicateBlock )predicate_
{
    for ( JFFAutoRemoveAssignProxy* proxy_ in _mutableArray )
    {
        if ( predicate_( proxy_.target ) )
            return proxy_.target;
    }
    return nil;
}

-(void)enumerateObjectsUsingBlock:( void (^)( id, NSUInteger, BOOL* ) )block_
{
    [ _mutableArray enumerateObjectsUsingBlock: ^void( JFFAutoRemoveAssignProxy* proxy_
                                                      , NSUInteger midx_
                                                      , BOOL* mstop_ )
    {
        block_( proxy_.target, midx_, mstop_ );
    } ];
}

@end
