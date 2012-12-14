#import "JFFDidFinishAsyncOperationBlockHolder.h"

@implementation JFFDidFinishAsyncOperationBlockHolder

-(void)performDidFinishBlockOnceWithResult:( id )result_ error:(NSError *)error
{
    if (!self.didFinishBlock)
        return;

    JFFDidFinishAsyncOperationHandler block = self.didFinishBlock;
    self.didFinishBlock = nil;
    block(result_, error);
}

-(JFFDidFinishAsyncOperationHandler)onceDidFinishBlock
{
    return ^(id result_, NSError *error) {
        [ self performDidFinishBlockOnceWithResult: result_ error:error];
    };
}

@end
