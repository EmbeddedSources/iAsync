#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface FailOnFirstErrorGroupOfAsyncOperationsTest : GHTestCase
@end

@implementation FailOnFirstErrorGroupOfAsyncOperationsTest

-(void)setUp
{
   [ JFFCancelAyncOperationBlockHolder     enableInstancesCounting ];
   [ JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting ];

   [ JFFAsyncOperationManager enableInstancesCounting ];
}

//TODO cancel on fail one of sub loaders
-(void)testNormalFinish
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = failOnFirstErrorGroupOfAsyncOperations( first_loader_.loader
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

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testFinishWithSecondError
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = failOnFirstErrorGroupOfAsyncOperations( firstLoader_.loader
                                                                           , secondLoader_.loader
                                                                           , nil );

        __block BOOL mainCanceled_ = NO;
        __block BOOL mainFinished_ = NO;

        JFFCancelAsyncOperationHandler cancelCallback_ = ^( BOOL canceled_ )
        {
            mainCanceled_ = YES;
        };
        JFFDidFinishAsyncOperationHandler doneCallback_ = ^( id result_, NSError* error_ )
        {
            mainFinished_ = ( result_ == nil ) && ( error_ != nil );
        };

        loader_( nil, cancelCallback_, doneCallback_ );

        GHAssertFalse( firstLoader_.canceled, @"First loader not canceled yet" );
        GHAssertFalse( secondLoader_.canceled, @"Second loader not canceled yet" );
        GHAssertFalse( mainCanceled_, @"Group loader not canceled yet" );
        GHAssertFalse( mainFinished_, @"Group loader finished" );

        secondLoader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError errorWithDescription: @"some error" ] );

        GHAssertTrue ( secondLoader_.finished, @"Second loader finished already" );
        GHAssertTrue ( firstLoader_.canceled, @"First loader not finished yet" );
        GHAssertTrue ( firstLoader_.cancelFlag, @"First loader not finished yet" );
        GHAssertFalse( mainCanceled_, @"Group loader canceled" );
        GHAssertTrue ( mainFinished_, @"Group loader finished" );

        [ secondLoader_ release ];
        [ firstLoader_ release ];
    }

    GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testFinishWithFirstError
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = failOnFirstErrorGroupOfAsyncOperations( firstLoader_.loader
                                                                           , secondLoader_.loader
                                                                           , nil );

        __block BOOL mainCanceled_ = NO;
        __block BOOL mainFinished_ = NO;

        JFFCancelAsyncOperationHandler cancelCallback_ = ^( BOOL canceled_ )
        {
            mainCanceled_ = YES;
        };
        JFFDidFinishAsyncOperationHandler doneCallback_ = ^( id result_, NSError* error_ )
        {
            mainFinished_ = ( result_ == nil ) && ( error_ != nil );
        };

        loader_( nil, cancelCallback_, doneCallback_ );

        GHAssertFalse( firstLoader_.canceled, @"First loader not canceled yet" );
        GHAssertFalse( secondLoader_.canceled, @"Second loader not canceled yet" );
        GHAssertFalse( mainCanceled_, @"Group loader not canceled yet" );
        GHAssertFalse( mainFinished_, @"Group loader finished" );

        firstLoader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError errorWithDescription: @"some error" ] );

        GHAssertTrue( firstLoader_.finished, @"First loader finished already" );
        GHAssertTrue( secondLoader_.canceled, @"Second loader not finished yet" );
        GHAssertTrue( secondLoader_.cancelFlag, @"Second loader not finished yet" );
        GHAssertFalse( mainCanceled_, @"Group loader canceled" );
        GHAssertTrue ( mainFinished_, @"Group loader finished" );

        [ secondLoader_ release ];
        [ firstLoader_ release ];
    }

    GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelFirstLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = failOnFirstErrorGroupOfAsyncOperations( firstLoader_.loader
                                                                           , secondLoader_.loader
                                                                           , nil );

        __block BOOL mainCanceled_ = NO;
        __block BOOL onceCanceled_ = NO;

        loader_( nil, ^( BOOL unsubscribe_only_if_no_ )
        {
            mainCanceled_ = unsubscribe_only_if_no_ && !onceCanceled_;
            onceCanceled_ = YES;
        }, nil );

        GHAssertFalse( firstLoader_.canceled, @"First loader not canceled yet" );
        GHAssertFalse( secondLoader_.canceled, @"Second loader not canceled yet" );
        GHAssertFalse( mainCanceled_, @"Group loader not canceled yet" );

        firstLoader_.loaderCancelBlock.onceCancelBlock( YES );

        GHAssertTrue( firstLoader_.canceled, @"First loader canceled already" );
        GHAssertTrue( firstLoader_.cancelFlag, @"First loader canceled already" );
        GHAssertTrue( secondLoader_.canceled, @"Second loader canceled already" );
        GHAssertTrue( secondLoader_.cancelFlag, @"Second loader canceled already" );
        GHAssertTrue( mainCanceled_, @"Group loader canceled already" );

        GHAssertTrue( 0 != [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
        GHAssertTrue( 0 != [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
        GHAssertTrue( 0 != [ JFFAsyncOperationManager              instancesCount ], @"OK" );

        [ secondLoader_ release ];
        [ firstLoader_ release ];
    }

    GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelSecondLoader
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = failOnFirstErrorGroupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

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

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelMainLoader
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = failOnFirstErrorGroupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

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

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

@end
