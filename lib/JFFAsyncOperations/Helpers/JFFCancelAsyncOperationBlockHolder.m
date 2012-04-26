#import "JFFCancelAsyncOperationBlockHolder.h"

@implementation JFFCancelAsyncOperationBlockHolder

@synthesize cancelBlock;

-(void)performCancelBlockOnceWithArgument:( BOOL )cancel_
{
    if ( !self.cancelBlock )
        return;

    JFFCancelAsyncOperation block_ = self.cancelBlock;
    self.cancelBlock = nil;
    block_( cancel_ );
}

-(JFFCancelAsyncOperation)onceCancelBlock
{
    return ^void( BOOL cancel_ )
    {
        [ self performCancelBlockOnceWithArgument: cancel_ ];
    };
}

@end
