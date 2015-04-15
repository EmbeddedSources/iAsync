#import "JFFAsyncOperationProgressBlockHolder.h"

@implementation JFFAsyncOperationProgressBlockHolder

- (void)performProgressBlockWithArgument:(id)progressInfo
{
    if (_progressBlock)
        _progressBlock(progressInfo);
}

@end
