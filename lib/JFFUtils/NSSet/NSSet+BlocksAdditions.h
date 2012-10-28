#import <JFFUtils/Blocks/JUContainersHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface NSSet (BlocksAdditions)

//Invokes block once for each element of self.
//Creates a new NSSet containing the values returned by the block.
- (NSSet*)map:(JFFMappingBlock)block;

//Invokes block once for each element of self.
//Creates a new NSSet containing the values returned by the block.
//if error happens it is suppressed
- (NSSet*)forceMap:(JFFMappingBlock)block;

//Invokes the block passing in successive elements from self,
//Creates a new NSSet containing those elements for which the block returns a YES value
- (NSSet *)select:(JFFPredicateBlock)predicate;

//Invokes the block passing in successive elements from self,
//Creates a new NSArray containing those elements for which the block returns a YES value
- (NSArray *)selectArray:(JFFPredicateBlock)predicate;

//Invokes the block passing in successive elements from self,
//returning the first element for which the block returns a YES value
- (id)firstMatch:(JFFPredicateBlock)predicate;

@end
