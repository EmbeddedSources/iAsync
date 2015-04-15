#import "JFFDidFinishAsyncOperationBlockHolder.h"

@implementation JFFDidFinishAsyncOperationBlockHolder

- (void)performDidFinishBlockOnceWithResult:(id)result error:(NSError *)error
{
    if (!_didFinishBlock)
        return;
    
    JFFDidFinishAsyncOperationCallback block = _didFinishBlock;
    _didFinishBlock = nil;
    block(result, error);
}

- (JFFDidFinishAsyncOperationCallback)onceDidFinishBlock
{
    return ^(id result, NSError *error) {
        [self performDidFinishBlockOnceWithResult:result error:error];
    };
}

@end
