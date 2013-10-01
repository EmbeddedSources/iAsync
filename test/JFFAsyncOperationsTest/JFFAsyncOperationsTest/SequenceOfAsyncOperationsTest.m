#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface SequenceOfAsyncOperationsTest : GHTestCase
@end

@implementation SequenceOfAsyncOperationsTest

- (void)setUp
{
    [JFFCancelAsyncOperationBlockHolder    enableInstancesCounting];
    [JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting];
    
    [JFFAsyncOperationManager enableInstancesCounting];
}

- (void)testSequenceOfAsyncOperations
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        __weak JFFAsyncOperationManager* assign_first_loader_ = firstLoader;
        JFFAsyncOperation loader2_ = asyncOperationWithDoneBlock( secondLoader.loader, ^() {
            
            GHAssertTrue( assign_first_loader_.finished, @"First loader finished already" );
        } );
        
        JFFAsyncOperation loader_ = sequenceOfAsyncOperations( firstLoader.loader, loader2_, nil );

        __block id sequenceResult = nil;

        __block BOOL sequenceLoaderFinished = NO;
        loader_( nil, nil, ^( id result_, NSError* error_ ) {
            
            if ( result_ && !error_ ) {
                
                sequenceResult = result_;
                sequenceLoaderFinished = YES;
            }
        } );
        
        GHAssertFalse( firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse( sequenceLoaderFinished, @"Sequence loader not finished yet" );
        
        firstLoader.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );
        
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertFalse( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse( sequenceLoaderFinished, @"Sequence loader finished already" );
        
        id result = [NSObject new];
        secondLoader.loaderFinishBlock.didFinishBlock( result, nil );
        
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertTrue( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertTrue( sequenceLoaderFinished, @"Sequence loader finished already" );
        
        GHAssertTrue( result == sequenceResult, @"Sequence loader finished already" );
    }
    
    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testCancelFirstLoaderOfSequence
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager* secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = sequenceOfAsyncOperations(firstLoader.loader,
                                                             secondLoader.loader,
                                                             nil);
        
        JFFCancelAsyncOperation cancel = loader(nil, nil, nil);
        
        GHAssertFalse( firstLoader.canceled, @"still not canceled" );
        GHAssertFalse( secondLoader.canceled, @"still not canceled" );
        
        cancel( YES );
        
        GHAssertTrue( firstLoader.canceled, @"canceled" );
        GHAssertTrue( firstLoader.cancelFlag, @"canceled" );
        GHAssertFalse( secondLoader.canceled, @"still not canceled" );
    }
    
    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testCancelSecondLoaderOfSequence
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader_ = sequenceOfAsyncOperations( firstLoader.loader
                                                              , secondLoader.loader, nil );

        JFFCancelAsyncOperation cancel_ = loader_( nil, nil, nil );

        GHAssertFalse( firstLoader.canceled, @"still not canceled" );
        GHAssertFalse( secondLoader.canceled, @"still not canceled" );

        firstLoader.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

        GHAssertFalse( firstLoader.canceled, @"still not canceled" );
        GHAssertFalse( secondLoader.canceled, @"still not canceled" );

        cancel_( YES );

        GHAssertFalse( firstLoader.canceled, @"canceled" );
        GHAssertTrue( secondLoader.canceled, @"still not canceled" );
        GHAssertTrue( secondLoader.cancelFlag, @"canceled" );

    }

    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testCancelSecondLoaderOfSequenceIfFirstInstantFinish
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

    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testFirstLoaderFailOfSequence
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

    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testSequenceWithOneLoader
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

    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testSequenceWithTwoLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        NSArray* loaders_ = @[ firstLoader_.loader, secondLoader_.loader ];

        __block id sequenceResult   = nil;
        id seconBlockResult = [ NSObject new ];

        JFFAsyncOperation loader_ = sequenceOfAsyncOperationsArray( loaders_ );

        __block BOOL sequenceLoaderFinished_ = NO;

        loader_( nil, nil, ^( id result_, NSError* error_ )
        {
            if ( result_ && !error_ )
            {
                sequenceResult = result_;
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
        
        secondLoader_.loaderFinishBlock.didFinishBlock( seconBlockResult, nil );
        
        GHAssertTrue( sequenceLoaderFinished_, @"sequence finished" );
        GHAssertTrue( firstLoader_.finished  , @"firstLoader finished" );
        GHAssertTrue( secondLoader_.finished , @"secondLoader finished" );
        
        GHAssertTrue( seconBlockResult == sequenceResult, @"secondLoader finished" );
    }
    
    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testCriticalErrorOnFailFirstLoaderWhenSequenceResultCallbackIsNil
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader_ = sequenceOfAsyncOperations( firstLoader.loader, secondLoader.loader, nil );
        
        loader_( nil, nil, nil );
        
        firstLoader.loaderFinishBlock.didFinishBlock( nil, [JFFError newErrorWithDescription:@"some error"]);
    }
    
    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testImmediatelyCancelCallbackOfFirstLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        firstLoader.cancelAtLoading = JFFCancelAsyncOperationManagerWithYesFlag;
        
        JFFAsyncOperation loader = sequenceOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL progressCallbackCalled = NO;
        JFFAsyncOperationProgressHandler progressCallback = ^(id progressInfo) {
            
            progressCallbackCalled = YES;
        };

        __block NSNumber *cancelCallbackCallFlag = NO;
        JFFCancelAsyncOperationHandler cancelCallback = ^(BOOL canceled) {
            
            cancelCallbackCallFlag = @(canceled);
        };
        
        __block BOOL doneCallbackCalled = NO;
        JFFDidFinishAsyncOperationHandler doneCallback = ^(id result, NSError *error) {
            
            doneCallbackCalled = YES;
        };
        
        loader(progressCallback, cancelCallback, doneCallback);
        
        GHAssertFalse(progressCallbackCalled, @"progressCallback mismatch");
        GHAssertEqualObjects(@YES, cancelCallbackCallFlag, @"cancelCallback mismatch");
        GHAssertFalse(doneCallbackCalled, @"doneCallback mismatch");
        
        GHAssertEquals((NSUInteger)0, secondLoader.loadingCount, @"unwanted invocation - second loader");
    }
    
    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testImmediatelyCancelCallbackOfSecondLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        secondLoader.cancelAtLoading = JFFCancelAsyncOperationManagerWithYesFlag;
        
        JFFAsyncOperation loader = sequenceOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL progressCallbackCalled = NO;
        JFFAsyncOperationProgressHandler progressCallback = ^(id progressInfo) {
            
            progressCallbackCalled = YES;
        };
        
        __block NSNumber *cancelCallbackCallFlag = NO;
        JFFCancelAsyncOperationHandler cancelCallback = ^(BOOL canceled) {
            
            cancelCallbackCallFlag = @(canceled);
        };
        
        __block BOOL doneCallbackCalled = NO;
        JFFDidFinishAsyncOperationHandler doneCallback = ^(id result, NSError *error) {
            
            doneCallbackCalled = YES;
        };
        
        loader(progressCallback, cancelCallback, doneCallback);
        
        firstLoader.loaderFinishBlock.didFinishBlock([NSNull new], nil);
        
        GHAssertFalse(progressCallbackCalled, nil);
        GHAssertEqualObjects(@YES, cancelCallbackCallFlag, nil);
        GHAssertFalse(doneCallbackCalled, nil);
    }
    
    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

@end
