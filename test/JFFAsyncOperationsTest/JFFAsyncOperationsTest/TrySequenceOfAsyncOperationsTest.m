#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface TrySequenceOfAsyncOperationsTest : GHTestCase
@end

@implementation TrySequenceOfAsyncOperationsTest

-(void)setUp
{
    [JFFCancelAsyncOperationBlockHolder    enableInstancesCounting];
    [JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting];

    [JFFAsyncOperationManager enableInstancesCounting];
}

-(void)testTrySequenceOfAsyncOperations
{
    NSUInteger originalInstanceCount1 = [JFFCancelAsyncOperationBlockHolder    instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        __weak JFFAsyncOperationManager* assignFirstLoader_ = firstLoader;
        JFFAsyncOperation loader2_ = asyncOperationWithDoneBlock( secondLoader.loader, ^()
        {
            GHAssertTrue( assignFirstLoader_.finished, @"First loader finished already" );
        } );
        
        JFFAsyncOperation loader_ = trySequenceOfAsyncOperations( firstLoader.loader, loader2_, nil );

        __block id sequenceResult_ = nil;

        __block BOOL sequenceLoaderFinished_ = NO;
        loader_( nil, nil, ^(id result, NSError *error) {
            if (result && !error ) {
                sequenceResult_ = result;
                sequenceLoaderFinished_ = YES;
            }
        } );
        
        GHAssertFalse( firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse( sequenceLoaderFinished_, @"Sequence loader not finished yet" );

        firstLoader.loaderFinishBlock.didFinishBlock( nil, [ JFFError newErrorWithDescription: @"some error" ] );
        
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertFalse( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse( sequenceLoaderFinished_, @"Sequence loader finished already" );
        
        id result_ = [NSObject new];
        secondLoader.loaderFinishBlock.didFinishBlock( result_, nil );
        
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertTrue( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertTrue( sequenceLoaderFinished_, @"Sequence loader finished already" );
        
        GHAssertTrue( result_ == sequenceResult_, @"Sequence loader finished already" );
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

-(void)testCancelFirstLoaderOfTrySequence
{
    NSUInteger originalInstanceCount1 = [JFFCancelAsyncOperationBlockHolder    instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
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
    
    GHAssertTrue(originalInstanceCount1 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

-(void)testCancelSecondLoaderOfTrySequence
{
    NSUInteger originalInstanceCount1 = [JFFCancelAsyncOperationBlockHolder    instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
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
    
    GHAssertTrue(originalInstanceCount1 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

-(void)testCancelSecondLoaderOfTrySequenceIfFirstInstantFinish
{
    NSUInteger originalInstanceCount1 = [JFFCancelAsyncOperationBlockHolder    instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
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
    
    GHAssertTrue(originalInstanceCount1 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

-(void)testFirstLoaderOkOfTrySequence
{
    NSUInteger originalInstanceCount1 = [JFFCancelAsyncOperationBlockHolder    instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
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
    
    GHAssertTrue(originalInstanceCount1 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

-(void)testTrySequenceWithOneLoader
{
    NSUInteger originalInstanceCount1 = [JFFCancelAsyncOperationBlockHolder    instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = trySequenceOfAsyncOperationsArray(@[firstLoader.loader]);
        
        __block BOOL sequenceLoaderFinished = NO;
        
        loader(nil, nil, ^(id result, NSError *error) {
            
            if (result && !error) {
                
                sequenceLoaderFinished = YES;
            }
        });
        
        GHAssertFalse( sequenceLoaderFinished, @"sequence not finished" );
        
        firstLoader.loaderFinishBlock.didFinishBlock([NSNull new], nil);
        
        GHAssertTrue( sequenceLoaderFinished, @"sequence finished" );
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testCriticalErrorOnFailFirstLoaderWhenTrySequenceResultCallbackIsNil
{
    NSUInteger originalInstanceCount1 = [JFFCancelAsyncOperationBlockHolder    instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = trySequenceOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        loader(nil, nil, nil);
        
        firstLoader.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testImmediatelyCancelCallbackOfFirstLoader
{
    NSUInteger originalInstanceCount1 = [JFFCancelAsyncOperationBlockHolder    instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        firstLoader.cancelAtLoading = JFFCancelAsyncOperationManagerWithYesFlag;
        
        JFFAsyncOperation loader = trySequenceOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
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
        
        GHAssertFalse(progressCallbackCalled, nil);
        GHAssertEqualObjects(@YES, cancelCallbackCallFlag, nil);
        GHAssertFalse(doneCallbackCalled, nil);
        
        GHAssertEquals((NSUInteger)0, secondLoader.loadingCount, nil);
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testImmediatelyCancelCallbackOfSecondLoader
{
    NSUInteger originalInstanceCount1 = [JFFCancelAsyncOperationBlockHolder    instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        secondLoader.cancelAtLoading = JFFCancelAsyncOperationManagerWithYesFlag;
        
        JFFAsyncOperation loader = trySequenceOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
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
        
        firstLoader.loaderFinishBlock.didFinishBlock(nil, [JFFError newErrorWithDescription:@"test"]);
        
        GHAssertFalse(progressCallbackCalled, nil);
        GHAssertEqualObjects(@YES, cancelCallbackCallFlag, nil);
        GHAssertFalse(doneCallbackCalled, nil);
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

@end
