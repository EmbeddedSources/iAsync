#import "NSArray+BlocksAdditions.h"

@implementation NSArray (BlocksAdditions)

-(void)each:( ActionBlock )block_
{
    [ self enumerateObjectsUsingBlock: ^void( id obj_, NSUInteger idx_, BOOL* stop_ )
    {
        block_( obj_ );
    } ];
}

-(NSArray*)select:( PredicateBlock )predicate_
{
    NSIndexSet* indexes_ = [ self indexesOfObjectsPassingTest: ^BOOL( id obj_, NSUInteger idx_, BOOL* stop_ ) 
    {
        return predicate_( obj_ );
    } ];
    return [ self objectsAtIndexes: indexes_ ];
}

-(NSArray*)map:( MappingBlock )block_
{
    NSMutableArray* result_ = [ NSMutableArray arrayWithCapacity: [ self count ] ];

    [ self each: ^void( id object_ ) { [ result_ addObject: block_( object_ ) ]; } ];

    return [ NSArray arrayWithArray: result_ ];
}

-(NSArray*)flatten:( FlattenBlock )block_
{
    NSMutableArray* result_ = [ NSMutableArray array ];

    [ self each: ^void( id object_ ) 
    {
        NSArray* object_items_ = block_( object_ );
        [ result_ addObjectsFromArray: object_items_ ]; 
    } ];

    return [ NSArray arrayWithArray: result_ ];
}

+(id)arrayWithSize:( NSUInteger )size_
          producer:( ProducerBlock )block_
{
    NSMutableArray* result_ = [ NSMutableArray arrayWithCapacity: size_ ];

    for ( NSUInteger index_ = 0; index_ < size_; ++index_ )
    {
        [ result_ addObject: block_( index_ ) ];
    }

    return result_;
}

-(NSUInteger)count:( PredicateBlock )predicate_
{
    __block NSUInteger count_ = 0;

    [ self each: ^void( id object_ ) { if ( predicate_( object_ ) ) ++count_; } ];

    return count_;
}

-(id)firstMatch:( PredicateBlock )predicate_
{
    for ( id object_ in self )
    {
        if ( predicate_( object_ ) )
            return object_;
    }
    return nil;
}

-(NSUInteger)firstIndexOfObjectMatch:( PredicateBlock )predicate_
{
    NSUInteger result_ = 0;
    for ( id object_ in self )
    {
        if ( predicate_( object_ ) )
            return result_;
        ++result_;
    }
    return NSNotFound;
}

-(void)transformWithArray:( NSArray* )other_
                withBlock:( TransformBlock )block_
{
    NSAssert( [ self count ] == [ other_ count ], @"Dimensions must match to perform transform action" );

    NSUInteger array_size_ = [ self count ];
    for ( NSUInteger item_index_ = 0; item_index_ < array_size_; ++item_index_ )
    {
        block_( [ self objectAtIndex: item_index_], [ other_ objectAtIndex: item_index_ ] );
    }
}

@end
