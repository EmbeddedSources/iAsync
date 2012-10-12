#import <JFFUtils/Blocks/JUContainersHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface NSOrderedSet (BlocksAdditions)

//Invokes block once for each element of self.
//Creates a new NSOrderedSet containing the values returned by the block.
- (NSOrderedSet*)map:(JFFMappingBlock)block;

@end
