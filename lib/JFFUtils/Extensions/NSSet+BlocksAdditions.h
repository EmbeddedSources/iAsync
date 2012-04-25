#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface NSSet (BlocksAdditions)

//Invokes the block passing in successive elements from self,
//Creates a new NSSet containing those elements for which the block returns a YES value 
-(NSSet*)select:( JFFPredicateBlock )predicate_;

//Invokes the block passing in successive elements from self,
//Creates a new NSArray containing those elements for which the block returns a YES value 
-(NSArray*)selectArray:( JFFPredicateBlock )predicate_;

@end
