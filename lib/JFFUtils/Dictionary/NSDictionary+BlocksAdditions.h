#import <JFFUtils/Dictionary/JUDictionaryHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface NSDictionary (BlocksAdditions)

-(NSDictionary*)map:( JFFDictMappingBlock )block_;
-(NSDictionary*)mapKey:( JFFDictMappingBlock )block_;

-(NSUInteger)count:( JFFDictPredicateBlock )predicate_;

//Calls block once for each element in self, passing that element and key as a parameter.
-(void)each:( JFFDictActionBlock )block_;

@end
