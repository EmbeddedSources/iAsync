#import "JFFDidFinishAsyncOperationBlockHolder.h"

@implementation JFFDidFinishAsyncOperationBlockHolder

@synthesize didFinishBlock = _did_finish_block;

-(void)performDidFinishBlockOnceWithResult:( id )result_ error:( NSError* )error_
{
    if ( !self.didFinishBlock )
        return;

    JFFDidFinishAsyncOperationHandler block_ = self.didFinishBlock;
    self.didFinishBlock = nil;
    block_( result_, error_ );
}

-(JFFDidFinishAsyncOperationHandler)onceDidFinishBlock
{
    return ^( id result_, NSError* error_ )
    {
        [ self performDidFinishBlockOnceWithResult: result_ error: error_ ];
    };
}

@end
