#import <Foundation/Foundation.h>

typedef NSDictionary* (^JFFDictMappingBlock)( id key_, id object_ );
typedef BOOL (^JFFDictPredicateBlock)( id key_, id object_ );

@interface NSDictionary (BlocksAdditions)

-(NSDictionary*)map:( JFFDictMappingBlock )block_;
-(NSDictionary*)mapKey:( JFFDictMappingBlock )block_;

-(NSUInteger)count:( JFFDictPredicateBlock )predicate_;

@end
