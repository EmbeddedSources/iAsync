#import "NSDictionary+AsyncMap.h"

#import "JFFAsyncOperationContinuity.h"
#import "JFFAsyncOperationHelpers.h"

@implementation NSDictionary (AsyncMap)

- (JFFAsyncOperation)asyncMap:(JFFAsyncDictMappingBlock)block
{
    NSMutableArray *asyncOperations = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    NSMutableDictionary *finalResult = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        JFFAsyncOperation loader = block(key, object);
        
        JFFDidFinishAsyncOperationHook finishCallbackHook = ^(id result,
                                                              NSError *error,
                                                              JFFDidFinishAsyncOperationHandler doneCallback)
        {
            if (result)
                finalResult[key] = result;
            if (doneCallback)
                doneCallback(result, error);
        };
        loader = asyncOperationWithFinishHookBlock(loader, finishCallbackHook);
        
        [asyncOperations addObject:loader];
    } ];
    
    JFFAsyncOperation loader_ = failOnFirstErrorGroupOfAsyncOperationsArray(asyncOperations);
    JFFChangedResultBuilder resultBuilder_ = ^id(id localResult)
    {
        return [finalResult copy];
    };
    loader_ = asyncOperationWithChangedResult( loader_, resultBuilder_ );

    return loader_;
}

@end
