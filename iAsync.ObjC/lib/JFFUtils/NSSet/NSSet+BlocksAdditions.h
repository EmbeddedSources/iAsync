#import <JFFUtils/Blocks/JUContainersHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface NSSet (BlocksAdditions)

//Calls block once for number from 0(zero) to (size_ - 1)
//Creates a new NSArray containing the values returned by the block.
+ (instancetype)setWithSize:(NSUInteger)size
                   producer:(JFFProducerBlock)block;

//Invokes block once for each element of self.
//Creates a new NSSet containing the values returned by the block.
- (instancetype)map:(JFFMappingBlock)block;

//Invokes block once for each element of self.
//Creates a new NSSet containing the values returned by the block.
//if error happens it is suppressed
- (instancetype)forceMap:(JFFMappingBlock)block;

//Invokes the block passing in successive elements from self,
//Creates a new NSSet containing those elements for which the block returns a YES value
- (instancetype)filter:(JFFPredicateBlock)predicate;

//Invokes the block passing in successive elements from self,
//Creates a new NSArray containing those elements for which the block returns a YES value
- (NSArray *)filterArray:(JFFPredicateBlock)predicate;

//Invokes the block passing in successive elements from self,
//returning the first element for which the block returns a YES value
- (id)firstMatch:(JFFPredicateBlock)predicate;

@end
