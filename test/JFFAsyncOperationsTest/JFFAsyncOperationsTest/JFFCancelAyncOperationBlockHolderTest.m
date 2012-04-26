#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>

@interface JFFCancelAsyncOperationBlockHolderTest : GHTestCase
@end

@implementation JFFCancelAsyncOperationBlockHolderTest

-(void)testJFFCancelAsyncOperationBlockHolder
{
   __block BOOL holder_deallocated_ = NO;

   @autoreleasepool
   {
      JFFCancelAsyncOperationBlockHolder* holder_ = [ JFFCancelAsyncOperationBlockHolder new ];
      [ holder_ addOnDeallocBlock: ^void( void )
      {
         holder_deallocated_ = YES;
      } ];

      __block BOOL block_context_deallocated_ = NO;
      NSObject* block_context_ = [ NSObject new ];
      [ block_context_ addOnDeallocBlock: ^void( void )
      {
         block_context_deallocated_ = YES;
      } ];

      __block NSUInteger cancel_block_calls_number_ = 0;
      holder_.cancelBlock = ^( BOOL unsubscribe_only_if_no_ )
      {
         if ( [ block_context_ class ] )
            ++cancel_block_calls_number_;
      };

      [ block_context_ release ];

      GHAssertFalse( block_context_deallocated_, @"context not deallocated" );

      holder_.onceCancelBlock( NO );

      GHAssertTrue( nil == holder_.cancelBlock, @"cancel block empty" );
      GHAssertTrue( block_context_deallocated_, @"context deallocated" );
      GHAssertTrue( 1 == cancel_block_calls_number_, @"block once was called" );

      holder_.onceCancelBlock( NO );

      GHAssertTrue( 1 == cancel_block_calls_number_, @"block still once was called" );

      [ holder_ release ];
   }

   GHAssertTrue( holder_deallocated_, @"holder deallocated" );
}

@end
