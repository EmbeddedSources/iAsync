#import <JFFUtils/Blocks/JUContainersHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface NSOrderedSet (BlocksAdditions)

//Invokes block once for each element of self.
//Creates a new NSOrderedSet containing the values returned by the block.
- (NSOrderedSet*)map:(JFFMappingBlock)block;

- (NSOrderedSet *)forceMap:(JFFMappingBlock)block;

- (id)firstMatch:(JFFPredicateBlock)predicate;
- (BOOL)any:(JFFPredicateBlock)predicate;
- (BOOL)all:(JFFPredicateBlock)predicate;

//Invokes the block passing in successive elements from self,
//Creates a new NSSet containing those elements for which the block returns a YES value
- (NSOrderedSet *)select:(JFFPredicateBlock)predicate;

@end
