#import <JFFAsyncOperations/Helpers/JFFAsyncOperationHandlerBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface TrySequenceOfAsyncOperationsTest : GHTestCase
@end

@implementation TrySequenceOfAsyncOperationsTest

-(void)setUp
{
    [JFFAsyncOperationHandlerBlockHolder   enableInstancesCounting];
    [JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting];

    [JFFAsyncOperationManager enableInstancesCounting];
}

-(void)testTrySequenceOfAsyncOperations
{
    NSUInteger originalInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
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
        
        GHAssertFalse(firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse(secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse(sequenceLoaderFinished_, @"Sequence loader not finished yet" );

        firstLoader.loaderFinishBlock(nil, [JFFError newErrorWithDescription:@"some error"]);
        
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertFalse( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse( sequenceLoaderFinished_, @"Sequence loader finished already" );
        
        id result_ = [NSObject new];
        secondLoader.loaderFinishBlock(result_, nil);
        
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertTrue( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertTrue( sequenceLoaderFinished_, @"Sequence loader finished already" );
        
        GHAssertTrue( result_ == sequenceResult_, @"Sequence loader finished already" );
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testCancelFirstLoaderOfTrySequence
{
    NSUInteger originalInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = trySequenceOfAsyncOperations(firstLoader.loader,
                                                                secondLoader.loader,
                                                                nil);
        
        JFFAsyncOperationHandler handler = loader(nil, nil, nil);
        
        GHAssertFalse(firstLoader .canceled, @"still not canceled" );
        GHAssertFalse(secondLoader.canceled, @"still not canceled" );
        
        handler(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertTrue(firstLoader.canceled  , @"canceled" );
        GHAssertTrue(firstLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"canceled" );
        GHAssertFalse( secondLoader.canceled, @"still not canceled" );
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testCancelSecondLoaderOfTrySequence
{
    NSUInteger originalInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = trySequenceOfAsyncOperations( firstLoader.loader, secondLoader.loader, nil );
        
        JFFAsyncOperationHandler handler = loader(nil, nil, nil);
        
        GHAssertFalse(firstLoader.canceled, @"still not canceled" );
        GHAssertFalse(secondLoader.canceled, @"still not canceled" );
        
        firstLoader.loaderFinishBlock(nil, [JFFError newErrorWithDescription:@"some error"]);
        
        GHAssertFalse(firstLoader.canceled, @"still not canceled");
        GHAssertFalse(secondLoader.canceled, @"still not canceled");
        
        handler(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertFalse(firstLoader.canceled, @"canceled");
        GHAssertTrue(secondLoader.canceled, @"still not canceled");
        GHAssertTrue(secondLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"canceled");
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testCancelSecondLoaderOfTrySequenceIfFirstInstantFinish
{
    NSUInteger originalInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader = [ JFFAsyncOperationManager new ];
        firstLoader.failAtLoading = YES;
        
        JFFAsyncOperationManager* secondLoader = [ JFFAsyncOperationManager new ];
        
        JFFAsyncOperation loader_ = trySequenceOfAsyncOperations( firstLoader.loader, secondLoader.loader, nil );
        
        JFFAsyncOperationHandler handler = loader_( nil, nil, nil );
        
        GHAssertTrue( firstLoader.finished, @"finished" );
        GHAssertFalse( secondLoader.finished, @"not finished" );
        
        handler(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertFalse(firstLoader.canceled, @"canceled" );
        GHAssertTrue(secondLoader.canceled, @"still not canceled" );
        GHAssertTrue(secondLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"canceled" );
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testFirstLoaderOkOfTrySequence
{
    NSUInteger originalInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader = [JFFAsyncOperationManager new];
        firstLoader.finishAtLoading = YES;
        
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = trySequenceOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL sequenceLoaderFinished = NO;
        
        loader(nil, nil, ^(id result, NSError *error) {
            
            if (result && !error) {
                
                sequenceLoaderFinished = YES;
            }
        });

        GHAssertTrue(sequenceLoaderFinished, @"sequence failed" );
        GHAssertTrue(firstLoader.finished, @"first - finished" );
        GHAssertFalse(secondLoader.finished, @"second - not finished" );
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testTrySequenceWithOneLoader
{
    NSUInteger originalInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
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
        
        GHAssertFalse(sequenceLoaderFinished, @"sequence not finished");
        
        firstLoader.loaderFinishBlock([NSNull new], nil);
        
        GHAssertTrue(sequenceLoaderFinished, @"sequence finished");
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testCriticalErrorOnFailFirstLoaderWhenTrySequenceResultCallbackIsNil
{
    NSUInteger originalInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    __weak JFFAsyncOperationManager *weakFirstLoader;
    __weak JFFAsyncOperationManager *weakSecondLoader;
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        weakFirstLoader  = firstLoader;
        weakSecondLoader = secondLoader;
        
        JFFAsyncOperation loader = trySequenceOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        loader(nil, nil, nil);
        
        firstLoader.loaderFinishBlock([NSNull null], nil);
    }
    
    GHAssertNil(weakFirstLoader , nil);
    GHAssertNil(weakSecondLoader, nil);
    
    GHAssertTrue(originalInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testImmediatelyCancelCallbackOfFirstLoader
{
    NSUInteger originalInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        firstLoader.cancelAtLoading = JFFCancelAsyncOperationManagerWithYesFlag;
        
        JFFAsyncOperation loader = trySequenceOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL progressCallbackCalled = NO;
        JFFAsyncOperationProgressCallback progressCallback = ^(id progressInfo) {
            
            progressCallbackCalled = YES;
        };
        
        __block NSError *finishError;
        
        JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error) {
            
            finishError = error;
        };
        
        loader(progressCallback, nil, doneCallback);
        
        GHAssertFalse(progressCallbackCalled, nil);
        GHAssertTrue([finishError isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]], nil);
        
        GHAssertEquals((NSUInteger)0, secondLoader.loadingCount, nil);
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testImmediatelyCancelCallbackOfSecondLoader
{
    NSUInteger originalInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        secondLoader.cancelAtLoading = JFFCancelAsyncOperationManagerWithYesFlag;
        
        JFFAsyncOperation loader = trySequenceOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL progressCallbackCalled = NO;
        JFFAsyncOperationProgressCallback progressCallback = ^(id progressInfo) {
            
            progressCallbackCalled = YES;
        };
        
        __block NSError *finishError;
        
        JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error) {
            
            finishError = error;
        };
        
        loader(progressCallback, nil, doneCallback);
        
        firstLoader.loaderFinishBlock(nil, [JFFError newErrorWithDescription:@"test"]);
        
        GHAssertFalse(progressCallbackCalled, nil);
        GHAssertTrue([finishError isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]], nil);
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

@end
