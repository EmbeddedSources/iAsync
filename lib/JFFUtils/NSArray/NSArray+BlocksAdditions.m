#import "NSArray+BlocksAdditions.h"

@implementation NSArray (BlocksAdditions)

-(void)each:( JFFActionBlock )block_
{
    [ self enumerateObjectsUsingBlock: ^void( id obj_, NSUInteger idx_, BOOL* stop_ )
    {
        block_( obj_ );
    } ];
}

-(NSArray*)select:( JFFPredicateBlock )predicate_
{
    return [ self selectWithIndex: ^( id obj_, NSUInteger idx_ )
    {
        return predicate_( obj_ );
    } ];
}

-(NSArray*)selectWithIndex:( JFFPredicateWithIndexBlock )predicate_;
{
    NSIndexSet* indexes_ = [ self indexesOfObjectsPassingTest: ^BOOL( id obj_, NSUInteger idx_, BOOL* stop_ ) 
    {
        return predicate_( obj_, idx_ );
    } ];
    return [ self objectsAtIndexes: indexes_ ];
}

-(NSArray*)map:( JFFMappingBlock )block_
{
    NSMutableArray* result_ = [ NSMutableArray arrayWithCapacity: [ self count ] ];

    [ self each: ^void( id object_ ) { [ result_ addObject: block_( object_ ) ]; } ];

    return [ [ NSArray alloc ] initWithArray: result_ ];
}

-(NSArray*)flatten:( JFFFlattenBlock )block_
{
    NSMutableArray* result_ = [ NSMutableArray new ];

    [ self each: ^void( id object_ ) 
    {
        NSArray* objectItems_ = block_( object_ );
        [ result_ addObjectsFromArray: objectItems_ ]; 
    } ];

    return [ [ NSArray alloc ] initWithArray: result_ ];
}

+(id)arrayWithSize:( NSUInteger )size_
          producer:( JFFProducerBlock )block_
{
    NSMutableArray* result_ = [ NSMutableArray arrayWithCapacity: size_ ];

    for ( NSUInteger index_ = 0; index_ < size_; ++index_ )
    {
        [ result_ addObject: block_( index_ ) ];
    }

    return result_;
}

-(NSUInteger)count:( JFFPredicateBlock )predicate_
{
    __block NSUInteger count_ = 0;

    [ self each: ^void( id object_ ) { if ( predicate_( object_ ) ) ++count_; } ];

    return count_;
}

-(id)firstMatch:( JFFPredicateBlock )predicate_
{
    for ( id object_ in self )
    {
        if ( predicate_( object_ ) )
            return object_;
    }
    return nil;
}

-(NSUInteger)firstIndexOfObjectMatch:( JFFPredicateBlock )predicate_
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
                withBlock:( JFFTransformBlock )block_
{
    NSAssert( [ self count ] == [ other_ count ], @"Dimensions must match to perform transform action" );

    NSUInteger arraySize_ = [ self count ];
    for ( NSUInteger itemIndex_ = 0; itemIndex_ < arraySize_; ++itemIndex_ )
    {
        block_( [ self objectAtIndex: itemIndex_ ], [ other_ objectAtIndex: itemIndex_ ] );
    }
}

@end
