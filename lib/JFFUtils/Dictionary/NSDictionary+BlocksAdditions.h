#import <JFFUtils/Dictionary/JUDictionaryHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface NSDictionary (BlocksAdditions)

- (NSDictionary*)map:(JFFDictMappingBlock)block;
- (NSDictionary*)mapKey:(JFFDictMappingBlock)block;

- (NSUInteger)count:(JFFDictPredicateBlock)predicate;

//Calls block once for each element in self, passing that element and key as a parameter.
- (void)each:(JFFDictActionBlock)block;

@end
