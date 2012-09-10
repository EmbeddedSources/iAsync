#import "NSArray+BlocksAdditions.h"

#import "JFFClangLiterals.h"

@implementation NSMutableArray (BlocksAdditions)

+(id)converToCurrentTypeMutableArray:( NSMutableArray* )array_
{
    return array_;
}

@end

@implementation NSArray (BlocksAdditions)

+(id)converToCurrentTypeMutableArray:( NSMutableArray* )array_
{
    return [ array_ copy ];
}

+(id)arrayWithSize:( NSUInteger )size_
          producer:( JFFProducerBlock )block_
{
    NSMutableArray* result_ = [ [ NSMutableArray alloc ] initWithCapacity: size_ ];

    for ( NSUInteger index_ = 0; index_ < size_; ++index_ )
    {
        [ result_ addObject: block_( index_ ) ];
    }

    return [ self converToCurrentTypeMutableArray: result_ ];
}

+(id)arrayWithCapacity:( NSUInteger )capacity_
  ignoringNilsProducer:( JFFProducerBlock )block_
{
    NSMutableArray* result_ = [ [ NSMutableArray alloc ] initWithCapacity: capacity_ ];

    for ( NSUInteger index_ = 0; index_ < capacity_; ++index_ )
    {
        id object_ = block_( index_ );
        if ( object_ )
            [ result_ addObject: object_ ];
    }

    return [ self converToCurrentTypeMutableArray: result_ ];
}

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

-(NSArray*)selectWithIndex:( JFFPredicateWithIndexBlock )predicate_
{
    NSIndexSet* indexes_ = [ self indexesOfObjectsPassingTest: ^BOOL( id obj_, NSUInteger idx_, BOOL* stop_ ) 
    {
        return predicate_( obj_, idx_ );
    } ];
    return [ self objectsAtIndexes: indexes_ ];
}

- (NSArray*)map:(JFFMappingBlock)block
{
    NSMutableArray *result = [[NSMutableArray alloc]initWithCapacity:[self count]];

    for (id object in self)
    {
        [result addObject:block(object)];
    }

    return [result copy];
}

-(NSArray*)map:( JFFMappingWithErrorBlock )block_ error:( NSError** )outError_
{
    NSMutableArray* result_ = [ [ NSMutableArray alloc ] initWithCapacity: [ self count ] ];

    for ( id object_ in self )
    {
        id newObject_ = block_( object_, outError_ );
        if ( newObject_ )
        {
            [ result_ addObject: newObject_ ];
        }
        else
        {
            return nil;
        }
    }

    return [ result_ copy ];
}

-(NSArray*)forceMap:( JFFMappingBlock )block_
{
    NSMutableArray* result_ = [ [ NSMutableArray alloc ] initWithCapacity: [ self count ] ];

    for ( id object_ in self )
    {
        id newObject_ = block_( object_ );
        if ( newObject_ )
        {
            [ result_ addObject: newObject_ ];
        }
    }

    return [ result_ copy ];
}

-(NSArray*)mapWithIndex:( JFFMappingWithErrorAndIndexBlock )block_ error:( NSError** )outError_
{
    __block NSMutableArray* result_ = [ [ NSMutableArray alloc ] initWithCapacity: [ self count ] ];

    [ self enumerateObjectsUsingBlock: ^( id object_, NSUInteger idx_, BOOL* stop_ )
    {
        id newObject_ = block_( object_, idx_, outError_ );
        if ( newObject_ )
        {
            [ result_ addObject: newObject_ ];
        }
        else
        {
            result_ = nil;
            *stop_ = YES;
        }
    } ];
  
    return [ result_ copy ];
}

-(NSDictionary*)mapDict:( JFFMappingDictBlock )block_
{
    NSMutableArray* keys_   = [ [ NSMutableArray alloc ] initWithCapacity: [ self count ] ];
    NSMutableArray* values_ = [ [ NSMutableArray alloc ] initWithCapacity: [ self count ] ];

    for ( id object_ in self )
    {
        id key_;
        id value_;
        block_( object_, &key_, &value_ );
        [ keys_   addObject: key_   ];
        [ values_ addObject: value_ ];
    }

    return [ [ NSDictionary alloc ] initWithObjects: values_
                                            forKeys: keys_ ];
}

-(NSArray*)flatten:( JFFFlattenBlock )block_
{
    NSMutableArray* result_ = [ NSMutableArray new ];

    [ self each: ^void( id object_ ) 
    {
        NSArray* objectItems_ = block_( object_ );
        [ result_ addObjectsFromArray: objectItems_ ]; 
    } ];

    return [ result_ copy ];
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
        block_( self[ itemIndex_ ], other_[ itemIndex_ ] );
    }
}

-(NSArray*)devideIntoArrayWithSize:( NSUInteger )size_
                 elementIndexBlock:( JFFElementIndexBlock )block_
{
    NSParameterAssert( size_ > 0 );
    NSParameterAssert( block_    );

    NSMutableArray* mResult_ = [ NSMutableArray arrayWithSize: size_
                                                    producer: ^id( NSUInteger index_ )
    {
        return [ NSMutableArray new ];
    } ];

    [ self enumerateObjectsUsingBlock: ^( id obj_, NSUInteger idx_, BOOL* stop_ )
    {
        NSUInteger inserIndex_ = block_( obj_ );
        [ mResult_[ inserIndex_ ] addObject: obj_ ];
    } ];

    NSArray* result_ = [ mResult_ map: ^id( id object_ )
    {
        return [ object_ copy ];
    } ];

    return result_;
}

@end
