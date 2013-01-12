#import "JFFDidFinishAsyncOperationBlockHolder.h"

@implementation JFFDidFinishAsyncOperationBlockHolder

- (void)performDidFinishBlockOnceWithResult:(id)result error:(NSError *)error
{
    if (!self.didFinishBlock)
        return;
    
    JFFDidFinishAsyncOperationHandler block = self.didFinishBlock;
    self.didFinishBlock = nil;
    block(result, error);
}

- (JFFDidFinishAsyncOperationHandler)onceDidFinishBlock
{
    return ^(id result, NSError *error) {
        [self performDidFinishBlockOnceWithResult:result error:error];
    };
}

@end
