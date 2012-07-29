#import <JFFUtils/NSArray/JUArrayHelperBlocks.h>
#import <Foundation/Foundation.h>

@interface NSArray (BlocksAdditions)

#pragma mark -
#pragma mark BlocksAdditions
//Calls block once for number from 0(zero) to (size_ - 1)
//Creates a new NSArray containing the values returned by the block.
+(id)arrayWithSize:( NSUInteger )size_
          producer:( JFFProducerBlock )block_;

//Calls block once for each element in self, passing that element as a parameter.
-(void)each:( JFFActionBlock )block_;

//Invokes block once for each element of self.
//Creates a new NSArray containing the values returned by the block.
-(NSArray*)map:( JFFMappingBlock )block_;


//Invokes block once for each element of self.
//Creates a new NSArray containing the values returned by the block.
//if error happens it is suppressed
-(NSArray*)forceMap:( JFFMappingBlock )block_;


//Invokes block once for each element of self.
//Creates a new NSArray containing the values returned by the block.
//or return nil if error happens
-(NSArray*)map:( JFFMappingWithErrorBlock )block_ error:( NSError** )outError_;
-(NSArray*)mapIgnoringNilError:( JFFMappingWithErrorBlock )block_ error:( NSError** )outError_;


//Invokes block once for each element of self.
//Creates a new NSDictionary containing the values and keys returned by the block.
-(NSDictionary*)mapDict:( JFFMappingDictBlock )block_;

//Invokes the block passing in successive elements from self,
//Creates a new NSArray containing those elements for which the block returns a YES value 
-(NSArray*)select:( JFFPredicateBlock )predicate_;

-(NSArray*)selectWithIndex:( JFFPredicateWithIndexBlock )predicate_;

//Invokes the block passing in successive elements from self,
//Creates a new NSArray containing all elements of all arrays returned the block
-(NSArray*)flatten:( JFFFlattenBlock )block_;

//Invokes the block passing in successive elements from self,
//returning a count of those elements for which the block returns a YES value 
-(NSUInteger)count:( JFFPredicateBlock )predicate_;

//Invokes the block passing in successive elements from self,
//returning the first element for which the block returns a YES value 
-(id)firstMatch:( JFFPredicateBlock )predicate_;

-(NSUInteger)firstIndexOfObjectMatch:( JFFPredicateBlock )predicate_;

//Invokes the block passing parallel in successive elements from self and other NSArray,
-(void)transformWithArray:( NSArray* )other_
                withBlock:( JFFTransformBlock )block_;

@end
