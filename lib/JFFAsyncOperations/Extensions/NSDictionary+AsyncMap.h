#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef JFFAsyncOperation (^JFFAsyncDictMappingBlock)( id key_, id object_ );

@interface NSDictionary (AsyncMap)

-(JFFAsyncOperation)asyncMap:( JFFAsyncDictMappingBlock )block_;

@end
