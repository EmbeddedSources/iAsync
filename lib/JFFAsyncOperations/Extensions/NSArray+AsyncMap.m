#import "NSArray+AsyncMap.h"

#import "JFFAsyncOperationHelpers.h"
#import "JFFAsyncOperationContinuity.h"

@implementation NSArray (AsyncMap)

-(JFFAsyncOperation)asyncMap:( JFFAsyncOperationBinder )block_
{
    NSArray* asyncOperations_ = [ self map: ^id( id object_ )
    {
        return block_( object_ );
    } ];
    return failOnFirstErrorGroupOfAsyncOperationsArray( asyncOperations_ );
}

- (JFFAsyncOperation)tolerantFaultAsyncMap:(JFFAsyncOperationBinder)block
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    NSArray *asyncOperations = [self map:^id(id object) {
        JFFAsyncOperation loader = block(object);
        JFFDidFinishAsyncOperationHandler finishCallbackBlock = ^void(id localResult, NSError *error)
        {
            if (localResult)
                [result addObject:localResult];
        };
        return asyncOperationWithFinishCallbackBlock(loader, finishCallbackBlock);
    }];
    
    JFFAsyncOperation loader = groupOfAsyncOperationsArray(asyncOperations);
    return asyncOperationWithResultOrError(loader, result, nil);
}

@end
