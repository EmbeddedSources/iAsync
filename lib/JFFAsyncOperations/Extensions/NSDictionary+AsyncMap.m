#import "NSDictionary+AsyncMap.h"

#import "JFFAsyncOperationContinuity.h"
#import "JFFAsyncOperationHelpers.h"

@implementation NSDictionary (AsyncMap)

-(JFFAsyncOperation)asyncMap:( JFFAsyncDictMappingBlock )block_
{
    NSMutableArray* asyncOperations_ = [ NSMutableArray arrayWithCapacity: [ self count ] ];

    NSMutableDictionary* finalResult_ = [ NSMutableDictionary dictionaryWithCapacity: [ self count ] ];

    for ( id key_ in self )
    {
        id object_ = [ self objectForKey: key_ ];
        JFFAsyncOperation loader_ = block_( key_, object_ );

        JFFDidFinishAsyncOperationHook finishCallbackHook_ = ^( id result_
                                                               , NSError* error_
                                                               , JFFDidFinishAsyncOperationHandler doneCallback_ )
        {
            if ( result_ )
                [ finalResult_ setObject: result_ forKey: key_ ];
            if ( doneCallback_ )
                doneCallback_( result_, error_ );
        };
        loader_ = asyncOperationWithFinishHookBlock( loader_, finishCallbackHook_ );

        [ asyncOperations_ addObject: loader_ ];
    }

    JFFAsyncOperation loader_ = failOnFirstErrorGroupOfAsyncOperationsArray( asyncOperations_ );
    JFFChangedResultBuilder resultBuilder_ = ^id( id localResult_ )
    {
        return [ NSDictionary dictionaryWithDictionary: finalResult_ ];
    };
    loader_ = asyncOperationWithChangedResult( loader_, resultBuilder_ );

    return loader_;
}

@end
