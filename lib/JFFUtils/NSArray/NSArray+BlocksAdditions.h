#import <JFFUtils/NSArray/JUArrayHelperBlocks.h>
#import <Foundation/Foundation.h>

@interface NSArray (BlocksAdditions)

#pragma mark -
#pragma mark BlocksAdditions
//Calls block once for number from 0(zero) to (size_ - 1)
//Creates a new NSArray containing the values returned by the block.
+(id)arrayWithSize:( NSUInteger )size_
          producer:( ProducerBlock )block_;

//Calls block once for each element in self, passing that element as a parameter.
-(void)each:( ActionBlock )block_;

//Invokes block once for each element of self.
//Creates a new NSArray containing the values returned by the block.
-(NSArray*)map:( MappingBlock )block_;

//Invokes the block passing in successive elements from self,
//Creates a new NSArray containing those elements for which the block returns a YES value 
-(NSArray*)select:( PredicateBlock )predicate_;

//Invokes the block passing in successive elements from self,
//Creates a new NSArray containing all elements of all arrays returned the block
-(NSArray*)flatten:( FlattenBlock )block_;

//Invokes the block passing in successive elements from self,
//returning a count of those elements for which the block returns a YES value 
-(NSUInteger)count:( PredicateBlock )predicate_;

//Invokes the block passing in successive elements from self,
//returning the first element for which the block returns a YES value 
-(id)firstMatch:( PredicateBlock )predicate_;

-(NSUInteger)firstIndexOfObjectMatch:( PredicateBlock )predicate_;

//Invokes the block passing parallel in successive elements from self and other NSArray,
-(void)transformWithArray:( NSArray* )other_
                withBlock:( TransformBlock )block_;

@end
