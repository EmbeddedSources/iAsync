#import "NSDictionary+AsyncMap.h"

#import "JFFAsyncOperationHelpers.h"
#import "JFFAsyncOperationContinuity.h"

@implementation NSDictionary (AsyncMap)

- (JFFAsyncOperation)asyncMap:(JFFAsyncDictMappingBlock)block
{
    NSMutableArray *asyncOperations = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    NSMutableDictionary *finalResult = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        
        JFFAsyncOperation loader = block(key, object);
        
        JFFDidFinishAsyncOperationHook finishCallbackHook = ^(id result,
                                                              NSError *error,
                                                              JFFDidFinishAsyncOperationCallback doneCallback) {
            
            if (result)
                finalResult[key] = result;
            
            doneCallback(result, error);
        };
        loader = asyncOperationWithFinishHookBlock(loader, finishCallbackHook);
        
        [asyncOperations addObject:loader];
    }];
    
    JFFAsyncOperation loader = failOnFirstErrorGroupOfAsyncOperationsArray(asyncOperations);
    JFFChangedResultBuilder resultBuilder = ^id(id localResult) {
        
        return [finalResult copy];
    };
    loader = asyncOperationWithChangedResult(loader, resultBuilder);
    
    return loader;
}

@end
