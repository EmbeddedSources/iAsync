#import <JFFUtils/NSArray/JUArrayHelperBlocks.h>
#import <Foundation/Foundation.h>

@interface NSArray( RemoveDuplicates )

-(NSArray*)arrayByRemovingDuplicates; //uses @selector(isEual:)
-(NSArray*)arrayByRemovingDuplicatesUsingIsEqualBlock:( EqualityCheckerBlock )predicate_;

//Same methods using functional programming notation
-(NSArray*)unique; //uses @selector(isEual:)
-(NSArray*)uniqueBy:( EqualityCheckerBlock )predicate_;

@end
