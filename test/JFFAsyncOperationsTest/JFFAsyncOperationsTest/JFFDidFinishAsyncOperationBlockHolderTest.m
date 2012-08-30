#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface JFFDidFinishAsyncOperationBlockHolderTest : GHTestCase
@end

@implementation JFFDidFinishAsyncOperationBlockHolderTest

-(void)testDidFinishAsyncOperationBlockHolder
{
    __block BOOL holderDeallocated_ = NO;

    @autoreleasepool
    {
        JFFDidFinishAsyncOperationBlockHolder* holder_ = [ JFFDidFinishAsyncOperationBlockHolder new ];
        [ holder_ addOnDeallocBlock: ^void( void )
        {
            holderDeallocated_ = YES;
        } ];

        __block BOOL blockContextDeallocated_ = NO;
        __block NSUInteger finishBlockCallsNumber_ = 0;

        @autoreleasepool
        {
            NSObject* blockContext_ = [ NSObject new ];
            [ blockContext_ addOnDeallocBlock: ^void( void )
            {
                blockContextDeallocated_ = YES;
            } ];

            holder_.didFinishBlock = ^( id result_, NSError* error_ )
            {
                if ( [ blockContext_ class ] )
                    ++finishBlockCallsNumber_;
            };
        }

        GHAssertFalse( blockContextDeallocated_, @"context not deallocated" );

        holder_.onceDidFinishBlock( nil, nil );

        GHAssertTrue( nil == holder_.didFinishBlock, @"finish block empty" );
        GHAssertTrue( blockContextDeallocated_, @"context deallocated" );
        GHAssertTrue( 1 == finishBlockCallsNumber_, @"block once was called" );

        holder_.onceDidFinishBlock( nil, nil );

        GHAssertTrue( 1 == finishBlockCallsNumber_, @"block still once was called" );
    }

    GHAssertTrue( holderDeallocated_, @"holder deallocated" );
}

@end
