#import "NSArray+AsyncMap.h"

#import "JFFAsyncOperationHelpers.h"
#import "JFFAsyncOperationContinuity.h"

@implementation NSArray (AsyncMap)

- (JFFAsyncOperation)asyncMap:(JFFAsyncOperationBinder)block
{
    NSArray *asyncOperations = [self map:^id(id object) {
        return block(object);
    }];
    return failOnFirstErrorGroupOfAsyncOperationsArray(asyncOperations);
}

- (JFFAsyncOperation)asyncWaitAllMap:(JFFAsyncOperationBinder)block
{
    NSArray *asyncOperations = [self map:^id(id object) {
        return block(object);
    }];
    return groupOfAsyncOperationsArray(asyncOperations);
}

- (JFFAsyncOperation)tolerantFaultAsyncMap:(JFFAsyncOperationBinder)block
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    NSArray *asyncOperations = [self map:^id(id object) {
        
        JFFAsyncOperation loader = block(object);
        JFFDidFinishAsyncOperationCallback finishCallbackBlock = ^void(id localResult, NSError *error) {
            
            if (localResult)
                [result addObject:localResult];
        };
        return asyncOperationWithFinishCallbackBlock(loader, finishCallbackBlock);
    }];
    
    JFFAsyncOperation loader = groupOfAsyncOperationsArray(asyncOperations);
    return asyncOperationWithResultOrError(loader, result, nil);
}

@end
