#import "NSArray+AsyncMap.h"

#import "JFFAsyncOperationHelpers.h"
#import "JFFAsyncOperationContinuity.h"

@implementation NSArray (AsyncMap)

//STODO add add tolerantAsyncMap:
-(JFFAsyncOperation)asyncMap:( JFFAsyncOperationBinder )block_
{
    NSArray* asyncOperations_ = [ self map: ^id( id object_ )
    {
        return block_( object_ );
    } ];
    return failOnFirstErrorGroupOfAsyncOperationsArray( asyncOperations_ );
}

-(JFFAsyncOperation)tolerantFaultAsyncMap:( JFFAsyncOperationBinder )block_
{
    NSMutableArray* result_ = [ [ NSMutableArray alloc ] initWithCapacity: [ self count ] ];

    NSArray* asyncOperations_ = [ self map: ^id( id object_ )
    {
        JFFAsyncOperation loader_ = block_( object_ );
        JFFDidFinishAsyncOperationHandler finishCallbackBlock_ = ^void( id localResult_, NSError* error_ )
        {
            if ( localResult_ )
                [ result_ addObject: localResult_ ];
        };
        return asyncOperationWithFinishCallbackBlock( loader_, finishCallbackBlock_ );
    } ];

    JFFAsyncOperation loader_ = groupOfAsyncOperationsArray( asyncOperations_ );
    return asyncOperationWithResultOrError( loader_, result_, nil );
}

@end
