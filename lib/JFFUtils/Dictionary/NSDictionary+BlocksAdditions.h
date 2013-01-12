#import <JFFUtils/Dictionary/JUDictionaryHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface NSDictionary (BlocksAdditions)

- (NSDictionary*)map:(JFFDictMappingBlock)block;
- (NSDictionary*)mapKey:(JFFDictMappingBlock)block;

- (NSDictionary *)map:(JFFDictMappingWithErrorBlock)block error:(NSError **)outError;

- (NSUInteger)count:(JFFDictPredicateBlock)predicate;

//Calls block once for each element in self, passing that element and key as a parameter.
- (void)each:(JFFDictActionBlock)block;

//Invokes the block passing in successive elements from self,
//Creates a new NSDictionary containing those elements for which the block returns a YES value
- (NSDictionary*)select:(JFFDictPredicateBlock)predicate;

@end
