#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface GroupOfAsyncOperationsTest : GHTestCase
@end

@implementation GroupOfAsyncOperationsTest

-(void)setUp
{
   [ JFFCancelAyncOperationBlockHolder     enableInstancesCounting ];
   [ JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting ];

   [ JFFAsyncOperationManager enableInstancesCounting ];
}

-(void)testNormalFinish
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader
                                                         , second_loader_.loader
                                                         , nil );

      __block BOOL group_loader_finished_ = NO;
      loader_( nil, nil, ^( id result_, NSError* error_ )
      {
         if ( result_ && !error_ )
         {
            group_loader_finished_ = YES;
         }
      } );

      GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
      GHAssertFalse( second_loader_.finished, @"Second loader not finished yet" );
      GHAssertFalse( group_loader_finished_, @"Group loader not finished yet" );

      second_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

      GHAssertTrue( second_loader_.finished, @"Second loader finished already" );
      GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
      GHAssertFalse( group_loader_finished_, @"Group loader finished already" );

      first_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

      GHAssertTrue( first_loader_.finished, @"First loader finished already" );
      GHAssertTrue( second_loader_.finished, @"Second loader not finished yet" );
      GHAssertTrue( group_loader_finished_, @"Group loader finished already" );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testFinishWithFirstError
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];
      
      JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );
      
      __block BOOL group_loader_failed_ = NO;
      loader_( nil, nil, ^( id result_, NSError* error_ )
      {
         if ( !result_ && error_ )
         {
            group_loader_failed_ = YES;
         }
      } );

      GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
      GHAssertFalse( second_loader_.finished, @"Second loader not finished yet" );
      GHAssertFalse( group_loader_failed_, @"Group loader not failed yet" );

      second_loader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError errorWithDescription: @"some error" ] );

      GHAssertTrue( second_loader_.finished, @"Second loader finished already" );
      GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
      GHAssertFalse( group_loader_failed_, @"Group loader failed already" );

      first_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

      GHAssertTrue( first_loader_.finished, @"First loader finished already" );
      GHAssertTrue( second_loader_.finished, @"Second loader not finished yet" );
      GHAssertTrue( group_loader_failed_, @"Group loader failed already" );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testFinishWithSecondError
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

      __block BOOL group_loader_failed_ = NO;
      loader_( nil, nil, ^( id result_, NSError* error_ )
      {
         if ( !result_ && error_ )
         {
            group_loader_failed_ = YES;
         }
      } );

      GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
      GHAssertFalse( second_loader_.finished, @"Second loader not finished yet" );
      GHAssertFalse( group_loader_failed_, @"Group loader not failed yet" );

      second_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

      GHAssertTrue( second_loader_.finished, @"Second loader finished already" );
      GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
      GHAssertFalse( group_loader_failed_, @"Group loader failed already" );

      first_loader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError errorWithDescription: @"some error" ] );

      GHAssertTrue( first_loader_.finished, @"First loader finished already" );
      GHAssertTrue( second_loader_.finished, @"Second loader not finished yet" );
      GHAssertTrue( group_loader_failed_, @"Group loader failed already" );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testCancelFirstLoader
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];
      
      JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

      __block BOOL main_canceled_ = NO;
      __block BOOL once_canceled_ = NO;

      loader_( nil, ^( BOOL unsubscribe_only_if_no_ )
      {
         main_canceled_ = unsubscribe_only_if_no_ && !once_canceled_;
         once_canceled_ = YES;
      }, nil );
      
      GHAssertFalse( first_loader_.canceled, @"First loader not canceled yet" );
      GHAssertFalse( second_loader_.canceled, @"Second loader not canceled yet" );
      GHAssertFalse( main_canceled_, @"Group loader not canceled yet" );

      first_loader_.loaderCancelBlock.onceCancelBlock( YES );

      GHAssertTrue( first_loader_.canceled, @"First loader canceled already" );
      GHAssertTrue( first_loader_.cancelFlag, @"First loader canceled already" );
      GHAssertTrue( second_loader_.canceled, @"Second loader canceled already" );
      GHAssertTrue( second_loader_.cancelFlag, @"Second loader canceled already" );
      GHAssertTrue( main_canceled_, @"Group loader canceled already" );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testCancelSecondLoader
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

      __block BOOL main_canceled_ = NO;
      __block BOOL once_canceled_ = NO;

      loader_( nil, ^( BOOL unsubscribe_only_if_no_ )
      {
         main_canceled_ = !unsubscribe_only_if_no_ && !once_canceled_;
         once_canceled_ = YES;
      }, nil );

      GHAssertFalse( first_loader_.canceled, @"First loader not canceled yet" );
      GHAssertFalse( second_loader_.canceled, @"Second loader not canceled yet" );
      GHAssertFalse( main_canceled_, @"Group loader not canceled yet" );

      second_loader_.loaderCancelBlock.onceCancelBlock( NO );

      GHAssertTrue( first_loader_.canceled, @"First loader canceled already" );
      GHAssertFalse( first_loader_.cancelFlag, @"First loader canceled already" );
      GHAssertTrue( second_loader_.canceled, @"Second loader canceled already" );
      GHAssertFalse( second_loader_.cancelFlag, @"Second loader canceled already" );
      GHAssertTrue( main_canceled_, @"Group loader canceled already" );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testCancelMainLoader
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

      __block BOOL main_canceled_ = NO;
      __block BOOL once_canceled_ = NO;

      JFFCancelAsyncOperation cancel_ = loader_( nil, ^( BOOL unsubscribe_only_if_no_ )
      {
         main_canceled_ = unsubscribe_only_if_no_ && !once_canceled_;
         once_canceled_ = YES;
      }, nil );

      GHAssertFalse( first_loader_.canceled, @"First loader not canceled yet" );
      GHAssertFalse( second_loader_.canceled, @"Second loader not canceled yet" );
      GHAssertFalse( main_canceled_, @"Group loader not canceled yet" );

      cancel_( YES );

      GHAssertTrue( first_loader_.canceled, @"First loader canceled already" );
      GHAssertTrue( first_loader_.cancelFlag, @"First loader canceled already" );
      GHAssertTrue( second_loader_.canceled, @"Second loader canceled already" );
      GHAssertTrue( second_loader_.cancelFlag, @"Second loader canceled already" );
      GHAssertTrue( main_canceled_, @"Group loader canceled already" );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testCancelAfterResultFirstLoader
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

      __block BOOL main_canceled_ = NO;
      __block BOOL once_canceled_ = NO;

      JFFCancelAsyncOperationHandler cancel_callback_ = ^( BOOL unsubscribe_only_if_no_ )
      {
         main_canceled_ = unsubscribe_only_if_no_ && !once_canceled_;
         once_canceled_ = YES;
      };

      __block BOOL group_loader_finished_ = NO;

      JFFDidFinishAsyncOperationHandler done_callback_ = ^void( id result_, NSError* error_ )
      {
         group_loader_finished_ = YES;
      };
      JFFCancelAsyncOperation cancel_ = loader_( nil, cancel_callback_, done_callback_ );

      GHAssertFalse( first_loader_.canceled, @"First loader not canceled yet" );
      GHAssertFalse( second_loader_.canceled, @"Second loader not canceled yet" );
      GHAssertFalse( main_canceled_, @"Group loader not canceled yet" );

      second_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

      GHAssertTrue( second_loader_.finished, @"Second loader finished already" );
      GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
      GHAssertFalse( group_loader_finished_, @"Group loader finished already" );

      cancel_( YES );

      GHAssertTrue( first_loader_.canceled, @"First loader canceled already" );
      GHAssertTrue( first_loader_.cancelFlag, @"First loader canceled already" );
      GHAssertFalse( second_loader_.canceled, @"Second loader canceled already" );
      GHAssertTrue( main_canceled_, @"Group loader canceled already" );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

typedef JFFAsyncOperation (*MergeLoadersPtr)( JFFAsyncOperation, ... );

-(void)testResultOfGroupLoadersWithFunc:( MergeLoadersPtr )func_
{
   @autoreleasepool
   {
      for ( int i = 0; i < 3; ++i )
      {
         for ( int j = 0; j < 2; ++j )
         {
            JFFAsyncOperationManager* first_loader_  = [ [ JFFAsyncOperationManager new ] autorelease ];
            JFFAsyncOperationManager* second_loader_ = [ [ JFFAsyncOperationManager new ] autorelease ];
            JFFAsyncOperationManager* third_loader_  = [ [ JFFAsyncOperationManager new ] autorelease ];

            JFFAsyncOperation loader_ = func_( first_loader_  .loader
                                              , second_loader_.loader
                                              , third_loader_ .loader
                                              , nil );

            JFFResultContext* resultContext_ = [ [ JFFResultContext new ] autorelease ];
            JFFDidFinishAsyncOperationHandler done_callback_ = ^void( id result_, NSError* error_ )
            {
               resultContext_.result = result_;
            };
            loader_( nil, nil, done_callback_ );

            NSArray* results_ = [ NSArray arrayWithObjects: @"0", @"1", @"2", nil ];
            NSArray* loadersResults_ = [ NSArray arrayWithObjects:
                                        first_loader_   .loaderFinishBlock.didFinishBlock
                                        , second_loader_.loaderFinishBlock.didFinishBlock
                                        , third_loader_ .loaderFinishBlock.didFinishBlock
                                        , nil ];

            NSMutableArray* indexes_ = [ NSMutableArray arrayWithArray: results_ ];

            NSUInteger firstIndex_ = [ [ indexes_ objectAtIndex: i ] integerValue ];
            [ indexes_ removeObject: [ indexes_ objectAtIndex: i ] ];

            NSUInteger secondIndex_ = [ [ indexes_ objectAtIndex: j ] integerValue ];
            [ indexes_ removeObject: [ indexes_ objectAtIndex: j ] ];

            NSUInteger thirdIndex_ = [ [ indexes_ objectAtIndex: 0 ] integerValue ];

            JFFDidFinishAsyncOperationHandler loader1_ = [ loadersResults_ objectAtIndex: firstIndex_  ];
            JFFDidFinishAsyncOperationHandler loader2_ = [ loadersResults_ objectAtIndex: secondIndex_ ];
            JFFDidFinishAsyncOperationHandler loader3_ = [ loadersResults_ objectAtIndex: thirdIndex_  ];

            loader1_( [ results_ objectAtIndex: firstIndex_  ], nil );
            loader2_( [ results_ objectAtIndex: secondIndex_ ], nil );
            loader3_( [ results_ objectAtIndex: thirdIndex_  ], nil );

            GHAssertTrue( [ resultContext_.result isEqual: results_ ], @"OK" );
         }
      }
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testResultOfGroupLoaders
{
   [ self testResultOfGroupLoadersWithFunc: &groupOfAsyncOperations ];
}

-(void)testResultOfFailOnFirstErrorGroupLoaders
{
   [ self testResultOfGroupLoadersWithFunc: &failOnFirstErrorGroupOfAsyncOperations ];
}

@end
