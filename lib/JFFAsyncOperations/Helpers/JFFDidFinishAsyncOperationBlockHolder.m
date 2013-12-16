#import "JFFDidFinishAsyncOperationBlockHolder.h"

@implementation JFFDidFinishAsyncOperationBlockHolder

- (void)performDidFinishBlockOnceWithResult:(id)result error:(NSError *)error
{
    if (!_didFinishBlock)
        return;
    
    JFFDidFinishAsyncOperationHandler block = _didFinishBlock;
    _didFinishBlock = nil;
    block(result, error);
}

- (JFFDidFinishAsyncOperationHandler)onceDidFinishBlock
{
    return ^(id result, NSError *error) {
        [self performDidFinishBlockOnceWithResult:result error:error];
    };
}

@end
