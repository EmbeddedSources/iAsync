#import <JFFUtils/Blocks/JUContainersHelperBlocks.h>
#import <Foundation/Foundation.h>

@interface NSArray( RemoveDuplicates )

- (instancetype)arrayByRemovingDuplicates; //uses @selector(isEual:)
- (instancetype)arrayByRemovingDuplicatesUsingIsEqualBlock:(JFFEqualityCheckerBlock)predicate;

//Same methods using functional programming notation
- (instancetype)unique; //uses @selector(isEual:)
- (instancetype)uniqueBy:(JFFEqualityCheckerBlock)predicate;

@end
