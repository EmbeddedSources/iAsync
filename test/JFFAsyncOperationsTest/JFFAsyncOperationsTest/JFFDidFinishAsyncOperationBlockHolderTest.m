#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface JFFDidFinishAsyncOperationBlockHolderTest : GHTestCase
@end

@implementation JFFDidFinishAsyncOperationBlockHolderTest

-(void)testDidFinishAsyncOperationBlockHolder
{
   __block BOOL holder_deallocated_ = NO;

   @autoreleasepool
   {
      JFFDidFinishAsyncOperationBlockHolder* holder_ = [ JFFDidFinishAsyncOperationBlockHolder new ];
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

      __block NSUInteger finish_block_calls_number_ = 0;
      holder_.didFinishBlock = ^( id result_, NSError* error_ )
      {
         if ( [ block_context_ class ] )
            ++finish_block_calls_number_;
      };

      [ block_context_ release ];

      GHAssertFalse( block_context_deallocated_, @"context not deallocated" );

      holder_.onceDidFinishBlock( nil, nil );

      GHAssertTrue( nil == holder_.didFinishBlock, @"finish block empty" );
      GHAssertTrue( block_context_deallocated_, @"context deallocated" );
      GHAssertTrue( 1 == finish_block_calls_number_, @"block once was called" );

      holder_.onceDidFinishBlock( nil, nil );

      GHAssertTrue( 1 == finish_block_calls_number_, @"block still once was called" );

      [ holder_ release ];
   }

   GHAssertTrue( holder_deallocated_, @"holder deallocated" );
}

@end
