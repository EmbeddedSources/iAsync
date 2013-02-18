#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef JFFAsyncOperation (^JFFAsyncDictMappingBlock)(id key, id object);

@interface NSDictionary (AsyncMap)

- (JFFAsyncOperation)asyncMap:(JFFAsyncDictMappingBlock)block;

@end
