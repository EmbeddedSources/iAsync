#import <JFFAsyncOperations/Helpers/JFFAsyncOperationHandlerBlockHolder.h>

@interface JFFAsyncOperationHandlerBlockHolderTest : GHTestCase
@end

@implementation JFFAsyncOperationHandlerBlockHolderTest

-(void)testJFFCancelAsyncOperationBlockHolder
{
    __block BOOL holderDeallocated = NO;
    
    @autoreleasepool
    {
        JFFAsyncOperationHandlerBlockHolder *holder = [JFFAsyncOperationHandlerBlockHolder new];
        [holder addOnDeallocBlock:^void(void) {
        
            holderDeallocated = YES;
        }];
        
        __block BOOL blockContextDeallocated = NO;
        __block NSUInteger cancelBlockCallsNumber = 0;
        
        @autoreleasepool
        {
            NSObject *blockContext = [NSObject new];
            [blockContext addOnDeallocBlock:^void(void) {
                
                blockContextDeallocated = YES;
            }];
            
            holder.loaderHandler = ^(JFFAsyncOperationHandlerTask task) {
                
                if ([blockContext class])
                    ++cancelBlockCallsNumber;
            };
        }
        
        GHAssertFalse(blockContextDeallocated, @"context not deallocated");
        
        holder.smartLoaderHandler(JFFAsyncOperationHandlerTaskUnsubscribe);
        
        GHAssertTrue(nil == holder.loaderHandler, @"cancel block empty"  );
        GHAssertTrue(blockContextDeallocated, @"context deallocated"     );
        GHAssertTrue(1 == cancelBlockCallsNumber, @"block once was called");
        
        holder.smartLoaderHandler(JFFAsyncOperationHandlerTaskUnsubscribe);
        
        GHAssertTrue(1 == cancelBlockCallsNumber, @"block still once was called" );
    }
    
    GHAssertTrue(holderDeallocated, @"holder deallocated");
}

@end
