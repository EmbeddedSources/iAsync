#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface SequenceOfAsyncOperationsTest : GHTestCase
@end

@implementation SequenceOfAsyncOperationsTest

-(void)setUp
{
    [ JFFCancelAsyncOperationBlockHolder    enableInstancesCounting ];
    [ JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting ];

    [ JFFAsyncOperationManager enableInstancesCounting ];
}

-(void)testSequenceOfAsyncOperations
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        __weak JFFAsyncOperationManager* assign_first_loader_ = first_loader_;
        JFFAsyncOperation loader2_ = asyncOperationWithDoneBlock( second_loader_.loader, ^()
        {
            GHAssertTrue( assign_first_loader_.finished, @"First loader finished already" );
        } );

        JFFAsyncOperation loader_ = sequenceOfAsyncOperations( first_loader_.loader, loader2_, nil );

        __block id sequence_result_ = nil;

        __block BOOL sequence_loader_finished_ = NO;
        loader_( nil, nil, ^( id result_, NSError* error_ )
        {
            if ( result_ && !error_ )
            {
                sequence_result_ = result_;
                sequence_loader_finished_ = YES;
            }
        } );

        GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
        GHAssertFalse( second_loader_.finished, @"Second loader not finished yet" );
        GHAssertFalse( sequence_loader_finished_, @"Sequence loader not finished yet" );

        first_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

        GHAssertTrue( first_loader_.finished, @"First loader finished already" );
        GHAssertFalse( second_loader_.finished, @"Second loader not finished yet" );
        GHAssertFalse( sequence_loader_finished_, @"Sequence loader finished already" );

        id result_ = [ NSObject new ];
        second_loader_.loaderFinishBlock.didFinishBlock( result_, nil );

        GHAssertTrue( first_loader_.finished, @"First loader finished already" );
        GHAssertTrue( second_loader_.finished, @"Second loader not finished yet" );
        GHAssertTrue( sequence_loader_finished_, @"Sequence loader finished already" );

        GHAssertTrue( result_ == sequence_result_, @"Sequence loader finished already" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testCancelFirstLoaderOfSequence
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = sequenceOfAsyncOperations( first_loader_.loader
                                                              , second_loader_.loader
                                                              , nil );

        JFFCancelAsyncOperation cancel_ = loader_( nil, nil, nil );

        GHAssertFalse( first_loader_.canceled, @"still not canceled" );
        GHAssertFalse( second_loader_.canceled, @"still not canceled" );

        cancel_( YES );

        GHAssertTrue( first_loader_.canceled, @"canceled" );
        GHAssertTrue( first_loader_.cancelFlag, @"canceled" );
        GHAssertFalse( second_loader_.canceled, @"still not canceled" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelSecondLoaderOfSequence
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = sequenceOfAsyncOperations( first_loader_.loader
                                                              , second_loader_.loader, nil );

        JFFCancelAsyncOperation cancel_ = loader_( nil, nil, nil );

        GHAssertFalse( first_loader_.canceled, @"still not canceled" );
        GHAssertFalse( second_loader_.canceled, @"still not canceled" );

        first_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

        GHAssertFalse( first_loader_.canceled, @"still not canceled" );
        GHAssertFalse( second_loader_.canceled, @"still not canceled" );

        cancel_( YES );

        GHAssertFalse( first_loader_.canceled, @"canceled" );
        GHAssertTrue( second_loader_.canceled, @"still not canceled" );
        GHAssertTrue( second_loader_.cancelFlag, @"canceled" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelSecondLoaderOfSequenceIfFirstInstantFinish
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      first_loader_.finishAtLoading = YES;

      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = sequenceOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

      JFFCancelAsyncOperation cancel_ = loader_( nil, nil, nil );

      GHAssertTrue( first_loader_.finished, @"finished" );
      GHAssertFalse( second_loader_.finished, @"not finished" );

      cancel_( YES );

      GHAssertFalse( first_loader_.canceled, @"canceled" );
      GHAssertTrue( second_loader_.canceled, @"still not canceled" );
      GHAssertTrue( second_loader_.cancelFlag, @"canceled" );

   }

   GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testFirstLoaderFailOfSequence
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      first_loader_.failAtLoading = YES;

      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];
      second_loader_.finishAtLoading = YES;

      JFFAsyncOperation loader_ = sequenceOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

      __block BOOL sequence_loader_failed_ = NO;

      loader_( nil, nil, ^( id result_, NSError* error_ )
      {
         if ( !result_ && error_ )
         {
            sequence_loader_failed_ = YES;
         }
      } );

      GHAssertTrue( sequence_loader_failed_, @"sequence failed" );
      GHAssertTrue( first_loader_.finished, @"first - finished" );
      GHAssertFalse( second_loader_.finished, @"second - not finished" );

   }

   GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testSequenceWithOneLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = sequenceOfAsyncOperationsArray( @[ first_loader_.loader ] );

        __block BOOL sequenceLoaderFinished_ = NO;

        loader_( nil, nil, ^( id result_, NSError* error_ )
        {
            if ( result_ && !error_ )
            {
                sequenceLoaderFinished_ = YES;
            }
        } );

        GHAssertFalse( sequenceLoaderFinished_, @"sequence not finished" );

        first_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

        GHAssertTrue( sequenceLoaderFinished_, @"sequence finished" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testSequenceWithTwoLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        NSArray* loaders_ = @[ firstLoader_.loader, secondLoader_.loader ];

        __block id sequenceResult_   = nil;
        id seconBlockResult_ = [ NSObject new ];

        JFFAsyncOperation loader_ = sequenceOfAsyncOperationsArray( loaders_ );

        __block BOOL sequenceLoaderFinished_ = NO;

        loader_( nil, nil, ^( id result_, NSError* error_ )
        {
            if ( result_ && !error_ )
            {
                sequenceResult_ = result_;
                sequenceLoaderFinished_ = YES;
            }
        } );

        GHAssertFalse( sequenceLoaderFinished_, @"sequence not finished" );
        GHAssertFalse( firstLoader_.finished  , @"firstLoader not finished" );
        GHAssertFalse( secondLoader_.finished , @"firstLoader not finished" );

        firstLoader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

        GHAssertFalse( sequenceLoaderFinished_, @"sequence not finished" );
        GHAssertTrue( firstLoader_.finished   , @"firstLoader not finished" );
        GHAssertFalse( secondLoader_.finished , @"secondLoader not finished" );

        secondLoader_.loaderFinishBlock.didFinishBlock( seconBlockResult_, nil );

        GHAssertTrue( sequenceLoaderFinished_, @"sequence finished" );
        GHAssertTrue( firstLoader_.finished  , @"firstLoader finished" );
        GHAssertTrue( secondLoader_.finished , @"secondLoader finished" );


        GHAssertTrue( seconBlockResult_ == sequenceResult_, @"secondLoader finished" );
    }
    
    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCriticalErrorOnFailFirstLoaderWhenSequenceResultCallbackIsNil
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = sequenceOfAsyncOperations( firstLoader_.loader, second_loader_.loader, nil );

        loader_( nil, nil, nil );

        firstLoader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError newErrorWithDescription: @"some error" ] );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

@end
