#import "JFFAsyncOperationProgressBlockHolder.h"

@implementation JFFAsyncOperationProgressBlockHolder

- (void)performProgressBlockWithArgument:(id)progressInfo
{
    if ( self.progressBlock )
        self.progressBlock(progressInfo);
}

@end
