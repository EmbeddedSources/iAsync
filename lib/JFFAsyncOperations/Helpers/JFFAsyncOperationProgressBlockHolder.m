#import "JFFAsyncOperationProgressBlockHolder.h"

@implementation JFFAsyncOperationProgressBlockHolder

-(void)performProgressBlockWithArgument:( id )progressInfo_
{
    if ( self.progressBlock )
        self.progressBlock( progressInfo_ );
}

@end
