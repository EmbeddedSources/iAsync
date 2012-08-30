#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface TrySequenceOfAsyncOperationsTest : GHTestCase
@end

@implementation TrySequenceOfAsyncOperationsTest

-(void)setUp
{
    [ JFFCancelAsyncOperationBlockHolder    enableInstancesCounting ];
    [ JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting ];

    [ JFFAsyncOperationManager enableInstancesCounting ];
}

//TODO test that can not finish "second" before finishing "first"
-(void)testTrySequenceOfAsyncOperations
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        __weak JFFAsyncOperationManager* assignFirstLoader_ = firstLoader_;
        JFFAsyncOperation loader2_ = asyncOperationWithDoneBlock( secondLoader_.loader, ^()
        {
            GHAssertTrue( assignFirstLoader_.finished, @"First loader finished already" );
        } );

        JFFAsyncOperation loader_ = trySequenceOfAsyncOperations( firstLoader_.loader, loader2_, nil );

        __block id sequenceResult_ = nil;

        __block BOOL sequenceLoaderFinished_ = NO;
        loader_( nil, nil, ^( id result_, NSError* error_ )
        {
            if ( result_ && !error_ )
            {
                sequenceResult_ = result_;
                sequenceLoaderFinished_ = YES;
            }
        } );

        GHAssertFalse( firstLoader_.finished, @"First loader not finished yet" );
        GHAssertFalse( secondLoader_.finished, @"Second loader not finished yet" );
        GHAssertFalse( sequenceLoaderFinished_, @"Sequence loader not finished yet" );

        firstLoader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError newErrorWithDescription: @"some error" ] );

        GHAssertTrue( firstLoader_.finished, @"First loader finished already" );
        GHAssertFalse( secondLoader_.finished, @"Second loader not finished yet" );
        GHAssertFalse( sequenceLoaderFinished_, @"Sequence loader finished already" );

        id result_ = [ NSObject new ];
        secondLoader_.loaderFinishBlock.didFinishBlock( result_, nil );

        GHAssertTrue( firstLoader_.finished, @"First loader finished already" );
        GHAssertTrue( secondLoader_.finished, @"Second loader not finished yet" );
        GHAssertTrue( sequenceLoaderFinished_, @"Sequence loader finished already" );

        GHAssertTrue( result_ == sequenceResult_, @"Sequence loader finished already" );
    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelFirstLoaderOfTrySequence
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = trySequenceOfAsyncOperations( firstLoader_.loader
                                                                 , secondLoader_.loader
                                                                 , nil );

        JFFCancelAsyncOperation cancel_ = loader_( nil, nil, nil );

        GHAssertFalse( firstLoader_.canceled, @"still not canceled" );
        GHAssertFalse( secondLoader_.canceled, @"still not canceled" );

        cancel_( YES );

        GHAssertTrue( firstLoader_.canceled  , @"canceled" );
        GHAssertTrue( firstLoader_.cancelFlag, @"canceled" );
        GHAssertFalse( secondLoader_.canceled, @"still not canceled" );
    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelSecondLoaderOfTrySequence
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = trySequenceOfAsyncOperations( firstLoader_.loader, secondLoader_.loader, nil );

        JFFCancelAsyncOperation cancel_ = loader_( nil, nil, nil );

        GHAssertFalse( firstLoader_.canceled, @"still not canceled" );
        GHAssertFalse( secondLoader_.canceled, @"still not canceled" );

        firstLoader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError newErrorWithDescription: @"some error" ] );

        GHAssertFalse( firstLoader_.canceled, @"still not canceled" );
        GHAssertFalse( secondLoader_.canceled, @"still not canceled" );

        cancel_( YES );

        GHAssertFalse( firstLoader_.canceled, @"canceled" );
        GHAssertTrue( secondLoader_.canceled, @"still not canceled" );
        GHAssertTrue( secondLoader_.cancelFlag, @"canceled" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
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

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
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

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testTrySequenceWithOneLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = trySequenceOfAsyncOperationsArray( @[ first_loader_.loader ] );

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

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testCriticalErrorOnFailFirstLoaderWhenTrySequenceResultCallbackIsNil
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = trySequenceOfAsyncOperations( firstLoader_.loader, secondLoader_.loader, nil );

        loader_( nil, nil, nil );

        firstLoader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

@end
