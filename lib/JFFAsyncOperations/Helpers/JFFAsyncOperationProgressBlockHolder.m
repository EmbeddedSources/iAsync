#import "JFFAsyncOperationProgressBlockHolder.h"

@implementation JFFAsyncOperationProgressBlockHolder

-(void)performProgressBlockWithArgument:( id )progress_info_
{
    if ( self.progressBlock )
        self.progressBlock( progress_info_ );
}

@end
