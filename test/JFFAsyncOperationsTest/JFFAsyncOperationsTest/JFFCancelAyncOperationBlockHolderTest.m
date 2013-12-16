#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>

@interface JFFCancelAsyncOperationBlockHolderTest : GHTestCase
@end

@implementation JFFCancelAsyncOperationBlockHolderTest

-(void)testJFFCancelAsyncOperationBlockHolder
{
    __block BOOL holderDeallocated_ = NO;

    @autoreleasepool
    {
        JFFCancelAsyncOperationBlockHolder* holder_ = [JFFCancelAsyncOperationBlockHolder new];
        [holder_ addOnDeallocBlock:^void(void) {
        
            holderDeallocated_ = YES;
        }];
        
        __block BOOL blockContextDeallocated_ = NO;
        __block NSUInteger cancelBlockCallsNumber_ = 0;

        @autoreleasepool
        {
            NSObject* blockContext_ = [ NSObject new ];
            [ blockContext_ addOnDeallocBlock: ^void( void )
            {
                blockContextDeallocated_ = YES;
            } ];

            holder_.cancelBlock = ^( BOOL unsubscribeOnlyIfNo_ )
            {
                if ( [ blockContext_ class ] )
                    ++cancelBlockCallsNumber_;
            };
        }
        
        GHAssertFalse(blockContextDeallocated_, @"context not deallocated");
        
        holder_.onceCancelBlock(NO);

        GHAssertTrue(nil == holder_.cancelBlock, @"cancel block empty"     );
        GHAssertTrue(blockContextDeallocated_, @"context deallocated"      );
        GHAssertTrue(1 == cancelBlockCallsNumber_, @"block once was called");

        holder_.onceCancelBlock( NO );

        GHAssertTrue( 1 == cancelBlockCallsNumber_, @"block still once was called" );
    }

    GHAssertTrue( holderDeallocated_, @"holder deallocated" );
}

@end
