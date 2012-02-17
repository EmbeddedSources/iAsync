#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface TrySequenceOfAsyncOperationsTest : GHTestCase
@end

@implementation TrySequenceOfAsyncOperationsTest

-(void)setUp
{
    [ JFFCancelAyncOperationBlockHolder     enableInstancesCounting ];
    [ JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting ];

    [ JFFAsyncOperationManager enableInstancesCounting ];
}

//TODO test that can not finish "second" before finishing "first"
-(void)testTrySequenceOfAsyncOperations
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        __block JFFAsyncOperationManager* assign_first_loader_ = first_loader_;
        JFFAsyncOperation loader2_ = asyncOperationWithDoneBlock( second_loader_.loader, ^()
        {
            GHAssertTrue( assign_first_loader_.finished, @"First loader finished already" );
        } );

        JFFAsyncOperation loader_ = trySequenceOfAsyncOperations( first_loader_.loader, loader2_, nil );

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

        first_loader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError errorWithDescription: @"some error" ] );

        GHAssertTrue( first_loader_.finished, @"First loader finished already" );
        GHAssertFalse( second_loader_.finished, @"Second loader not finished yet" );
        GHAssertFalse( sequence_loader_finished_, @"Sequence loader finished already" );

        id result_ = [ [ NSObject new ] autorelease ];
        second_loader_.loaderFinishBlock.didFinishBlock( result_, nil );

        GHAssertTrue( first_loader_.finished, @"First loader finished already" );
        GHAssertTrue( second_loader_.finished, @"Second loader not finished yet" );
        GHAssertTrue( sequence_loader_finished_, @"Sequence loader finished already" );

        GHAssertTrue( result_ == sequence_result_, @"Sequence loader finished already" );

        [ second_loader_ release ];
        [ first_loader_ release ];
    }

    GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelFirstLoaderOfTrySequence
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = trySequenceOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

        JFFCancelAsyncOperation cancel_ = loader_( nil, nil, nil );

        GHAssertFalse( first_loader_.canceled, @"still not canceled" );
        GHAssertFalse( second_loader_.canceled, @"still not canceled" );

        cancel_( YES );

        GHAssertTrue( first_loader_.canceled, @"canceled" );
        GHAssertTrue( first_loader_.cancelFlag, @"canceled" );
        GHAssertFalse( second_loader_.canceled, @"still not canceled" );

        [ second_loader_ release ];
        [ first_loader_ release ];
    }

    GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelSecondLoaderOfTrySequence
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = trySequenceOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

        JFFCancelAsyncOperation cancel_ = loader_( nil, nil, nil );

        GHAssertFalse( first_loader_.canceled, @"still not canceled" );
        GHAssertFalse( second_loader_.canceled, @"still not canceled" );

        first_loader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError errorWithDescription: @"some error" ] );

        GHAssertFalse( first_loader_.canceled, @"still not canceled" );
        GHAssertFalse( second_loader_.canceled, @"still not canceled" );

        cancel_( YES );

        GHAssertFalse( first_loader_.canceled, @"canceled" );
        GHAssertTrue( second_loader_.canceled, @"still not canceled" );
        GHAssertTrue( second_loader_.cancelFlag, @"canceled" );

        [ second_loader_ release ];
        [ first_loader_ release ];
    }

    GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelSecondLoaderOfTrySequenceIfFirstInstantFinish
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
        first_loader_.failAtLoading = YES;

        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = trySequenceOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

        JFFCancelAsyncOperation cancel_ = loader_( nil, nil, nil );

        GHAssertTrue( first_loader_.finished, @"finished" );
        GHAssertFalse( second_loader_.finished, @"not finished" );

        cancel_( YES );

        GHAssertFalse( first_loader_.canceled, @"canceled" );
        GHAssertTrue( second_loader_.canceled, @"still not canceled" );
        GHAssertTrue( second_loader_.cancelFlag, @"canceled" );

        [ second_loader_ release ];
        [ first_loader_ release ];
    }

    GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testFirstLoaderOkOfTrySequence
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
        first_loader_.finishAtLoading = YES;

        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = trySequenceOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

        __block BOOL sequence_loader_finished_ = NO;

        loader_( nil, nil, ^( id result_, NSError* error_ )
        {
            if ( result_ && !error_ )
            {
                sequence_loader_finished_ = YES;
            }
        } );

        GHAssertTrue( sequence_loader_finished_, @"sequence failed" );
        GHAssertTrue( first_loader_.finished, @"first - finished" );
        GHAssertFalse( second_loader_.finished, @"second - not finished" );

        [ second_loader_ release ];
        [ first_loader_ release ];
    }

    GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testTrySequenceWithOneLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = trySequenceOfAsyncOperationsArray( [ NSArray arrayWithObject: first_loader_.loader ] );

        __block BOOL sequence_loader_finished_ = NO;

        loader_( nil, nil, ^( id result_, NSError* error_ )
        {
            if ( result_ && !error_ )
            {
                sequence_loader_finished_ = YES;
            }
        } );

        GHAssertFalse( sequence_loader_finished_, @"sequence not finished" );

        first_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

        GHAssertTrue( sequence_loader_finished_, @"sequence finished" );

        [ first_loader_ release ];
    }

    GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testEmptyTrySequence
{
    @autoreleasepool
    {
        JFFAsyncOperation loader_ = trySequenceOfAsyncOperationsArray( nil );
        __block BOOL sequence_loader_finished_ = NO;

        GHAssertFalse( sequence_loader_finished_, @"sequence not finished" );

        loader_( nil, nil, ^( id result_, NSError* error_ )
        {
            if ( result_ && !error_ )
            {
                sequence_loader_finished_ = YES;
            }
        } );

        GHAssertTrue( sequence_loader_finished_, @"sequence finished" );
    }

    GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testCriticalErrorOnFailFirstLoaderWhenTrySequenceResultCallbackIsNil
{
   @autoreleasepool
   {
      JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
      JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

      JFFAsyncOperation loader_ = trySequenceOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

      loader_( nil, nil, nil );

      first_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

      [ second_loader_ release ];
      [ first_loader_ release ];
   }

   GHAssertTrue( 0 == [ JFFCancelAyncOperationBlockHolder     instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

@end
