#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface JFFDidFinishAsyncOperationBlockHolderTest : GHTestCase
@end

@implementation JFFDidFinishAsyncOperationBlockHolderTest

-(void)testDidFinishAsyncOperationBlockHolder
{
    __block BOOL holderDeallocated = NO;

    @autoreleasepool
    {
        JFFDidFinishAsyncOperationBlockHolder *holder = [JFFDidFinishAsyncOperationBlockHolder new];
        [holder addOnDeallocBlock:^void(void) {
            
            holderDeallocated = YES;
        }];
        
        __block BOOL blockContextDeallocated = NO;
        __block NSUInteger finishBlockCallsNumber = 0;
        
        @autoreleasepool
        {
            NSObject *blockContext = [NSObject new];
            [blockContext addOnDeallocBlock:^void(void) {
                
                blockContextDeallocated = YES;
            }];
            
            holder.didFinishBlock = ^(id result, NSError *error) {
                
                if ([blockContext class])
                    ++finishBlockCallsNumber;
            };
        }
        
        GHAssertFalse( blockContextDeallocated, @"context not deallocated" );

        holder.onceDidFinishBlock( nil, nil );

        GHAssertTrue(nil == holder.didFinishBlock, @"finish block empty"   );
        GHAssertTrue(blockContextDeallocated     , @"context deallocated"  );
        GHAssertTrue(1 == finishBlockCallsNumber , @"block once was called");
        
        holder.onceDidFinishBlock(nil, nil);
        
        GHAssertTrue(1 == finishBlockCallsNumber, @"block still once was called");
    }
    
    GHAssertTrue( holderDeallocated, @"holder deallocated" );
}

@end
