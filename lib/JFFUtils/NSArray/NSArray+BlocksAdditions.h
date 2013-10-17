#import <JFFUtils/Blocks/JUContainersHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface NSArray (BlocksAdditions)

#pragma mark -
#pragma mark BlocksAdditions
//Calls block once for number from 0(zero) to (size_ - 1)
//Creates a new NSArray containing the values returned by the block.
+ (instancetype)arrayWithSize:(NSUInteger)size
                     producer:(JFFProducerBlock)block;

//Calls block once for number from 0(zero) to (size_ - 1)
//Creates a new NSArray containing the values returned by the block.
+ (instancetype)arrayWithCapacity:(NSUInteger)size
             ignoringNilsProducer:(JFFProducerBlock)block;

//Calls block once for each element in self, passing that element as a parameter.
- (void)each:(JFFActionBlock)block;

//Invokes block once for each element of self.
//Creates a new NSArray containing the values returned by the block.
- (instancetype)map:(JFFMappingBlock)block;

//Invokes block once for each element of self.
//Creates a new NSArray containing the values returned by the block.
//if error happens it is suppressed
- (instancetype)forceMap:(JFFMappingBlock)block;

//Invokes block once for each element of self.
//Creates a new NSArray containing the values returned by the block.
//or return nil if error happens
- (instancetype)map:(JFFMappingWithErrorBlock)block
              error:(NSError *__autoreleasing *)outError;
-(NSArray*)mapIgnoringNilError:( JFFMappingWithErrorBlock )block_ error:( NSError** )outError_;

//Invokes block once for each element of self.
//Creates a new NSArray containing the values returned by the block. Passes index of element in block as argument.
//or return nil if error happens
- (instancetype)mapWithIndex:(JFFMappingWithErrorAndIndexBlock)block
                       error:(NSError *__autoreleasing *)outError;

//Invokes block once for each element of self.
//Creates a new NSDictionary containing the values and keys returned by the block.
- (NSDictionary *)mapDict:(JFFMappingDictBlock)block;

//Invokes the block passing in successive elements from self,
//Creates a new NSArray containing those elements for which the block returns a YES value 
- (instancetype)select:(JFFPredicateBlock)predicate;

- (instancetype)selectWithIndex:(JFFPredicateWithIndexBlock)predicate;

//Invokes the block passing in successive elements from self,
//Creates a new NSArray containing all elements of all arrays returned the block
- (instancetype)flatten:(JFFFlattenBlock)block;

//Invokes the block passing in successive elements from self,
//returning a count of those elements for which the block returns a YES value 
- (NSUInteger)count:(JFFPredicateBlock)predicate;

//Invokes the block passing in successive elements from self,
//returning the first element for which the block returns a YES value 
- (id)firstMatch:(JFFPredicateBlock)predicate;

//Invokes the block passing in successive elements from self,
//returning the last element for which the block returns a YES value
- (id)lastMatch:(JFFPredicateBlock)predicate;

- (NSUInteger)firstIndexOfObjectMatch:(JFFPredicateBlock)predicate;

//Invokes the block passing parallel in successive elements from self and other NSArray,
- (void)transformWithArray:(NSArray *)other
                 withBlock:(JFFTransformBlock)block;

//Invokes the block passing parallel in successive elements from self and other NSArray,
- (instancetype)devideIntoArrayWithSize:(NSUInteger)size
                      elementIndexBlock:(JFFElementIndexBlock)block;

- (BOOL)any:(JFFPredicateBlock)predicate;

- (BOOL)all:(JFFPredicateBlock)predicate;

@end
