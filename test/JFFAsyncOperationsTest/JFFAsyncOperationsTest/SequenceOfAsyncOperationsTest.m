#import <JFFAsyncOperations/Helpers/JFFAsyncOperationHandlerBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface SequenceOfAsyncOperationsTest : GHTestCase
@end

@implementation SequenceOfAsyncOperationsTest

- (void)setUp
{
    [JFFAsyncOperationHandlerBlockHolder   enableInstancesCounting];
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
        loader_(nil, nil, ^(id result_, NSError *error_) {
            
            if (result_ && !error_) {
                
                sequenceResult = result_;
                sequenceLoaderFinished = YES;
            }
        });
        
        GHAssertFalse(firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse(secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse(sequenceLoaderFinished, @"Sequence loader not finished yet" );
        
        firstLoader.loaderFinishBlock([NSNull null], nil);
        
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertFalse( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse( sequenceLoaderFinished, @"Sequence loader finished already" );
        
        id result = [NSObject new];
        secondLoader.loaderFinishBlock(result, nil);
        
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertTrue( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertTrue( sequenceLoaderFinished, @"Sequence loader finished already" );
        
        GHAssertTrue( result == sequenceResult, @"Sequence loader finished already" );
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testCancelFirstLoaderOfSequence
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = sequenceOfAsyncOperations(firstLoader.loader,
                                                             secondLoader.loader,
                                                             nil);
        
        JFFAsyncOperationHandler cancel = loader(nil, nil, nil);
        
        GHAssertFalse(firstLoader .canceled, @"still not canceled");
        GHAssertFalse(secondLoader.canceled, @"still not canceled");
        
        cancel(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertTrue(firstLoader.canceled, @"canceled" );
        GHAssertTrue(firstLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"canceled");
        GHAssertFalse(secondLoader.canceled, @"still not canceled");
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
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
        
        JFFAsyncOperationHandler cancel_ = loader_( nil, nil, nil );
        
        GHAssertFalse( firstLoader.canceled, @"still not canceled" );
        GHAssertFalse( secondLoader.canceled, @"still not canceled" );

        firstLoader.loaderFinishBlock([NSNull null], nil);

        GHAssertFalse( firstLoader.canceled, @"still not canceled" );
        GHAssertFalse( secondLoader.canceled, @"still not canceled" );

        cancel_(JFFAsyncOperationHandlerTaskCancel);

        GHAssertFalse(firstLoader.canceled, @"canceled" );
        GHAssertTrue(secondLoader.canceled, @"still not canceled" );
        GHAssertTrue(secondLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"canceled" );
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testCancelSecondLoaderOfSequenceIfFirstInstantFinish
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader = [JFFAsyncOperationManager new];
        firstLoader.finishAtLoading = YES;
        
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = sequenceOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        JFFAsyncOperationHandler cancel = loader(nil, nil, nil);
        
        GHAssertTrue(firstLoader.finished, @"finished" );
        GHAssertFalse(secondLoader.finished, @"not finished" );
        
        cancel(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertFalse(firstLoader.canceled, @"canceled");
        GHAssertTrue(secondLoader.canceled, @"still not canceled");
        GHAssertTrue(secondLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"canceled");
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testFirstLoaderFailOfSequence
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader = [JFFAsyncOperationManager new];
        firstLoader.failAtLoading = YES;
        
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        secondLoader.finishAtLoading = YES;
        
        JFFAsyncOperation loader = sequenceOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL sequenceLoaderFailed = NO;
        
        loader(nil, nil, ^(id result, NSError *error) {
            
            if (!result && error) {
                
                sequenceLoaderFailed = YES;
            }
        });
        
        GHAssertTrue(sequenceLoaderFailed, @"sequence failed");
        GHAssertTrue(firstLoader.finished, @"first - finished");
        GHAssertFalse(secondLoader.finished, @"second - not finished");
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testSequenceWithOneLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = sequenceOfAsyncOperationsArray(@[firstLoader.loader]);
        
        __block BOOL sequenceLoaderFinished = NO;
        
        loader( nil, nil, ^(id result, NSError *error) {
            
            if (result && !error ) {
                
                sequenceLoaderFinished = YES;
            }
        });
        
        GHAssertFalse(sequenceLoaderFinished, @"sequence not finished" );
        
        firstLoader.loaderFinishBlock([NSNull null], nil);
        
        GHAssertTrue(sequenceLoaderFinished, @"sequence finished" );
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testSequenceWithTwoLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        NSArray *loaders = @[firstLoader.loader, secondLoader.loader];

        __block id sequenceResult = nil;
        id seconBlockResult = [NSObject new];
        
        JFFAsyncOperation loader = sequenceOfAsyncOperationsArray(loaders);
        
        __block BOOL sequenceLoaderFinished = NO;
        
        loader(nil, nil, ^(id result_, NSError *error_) {
            
            if (result_ && !error_) {
                
                sequenceResult = result_;
                sequenceLoaderFinished = YES;
            }
        });
        
        GHAssertFalse(sequenceLoaderFinished, @"sequence not finished");
        GHAssertFalse(firstLoader.finished  , @"firstLoader not finished");
        GHAssertFalse(secondLoader.finished , @"firstLoader not finished");

        firstLoader.loaderFinishBlock([NSNull new], nil);

        GHAssertFalse( sequenceLoaderFinished, @"sequence not finished" );
        GHAssertTrue( firstLoader.finished   , @"firstLoader not finished" );
        GHAssertFalse( secondLoader.finished , @"secondLoader not finished" );
        
        secondLoader.loaderFinishBlock( seconBlockResult, nil );
        
        GHAssertTrue( sequenceLoaderFinished, @"sequence finished" );
        GHAssertTrue( firstLoader.finished  , @"firstLoader finished" );
        GHAssertTrue( secondLoader.finished , @"secondLoader finished" );
        
        GHAssertTrue( seconBlockResult == sequenceResult, @"secondLoader finished" );
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
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
        
        firstLoader.loaderFinishBlock( nil, [JFFError newErrorWithDescription:@"some error"]);
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
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
        JFFAsyncOperationProgressCallback progressCallback = ^(id progressInfo) {
            
            progressCallbackCalled = YES;
        };

        __block NSError *finishError;
        
        JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error) {
            
            finishError = error;
        };
        
        loader(progressCallback, nil, doneCallback);
        
        GHAssertFalse(progressCallbackCalled, @"progressCallback mismatch");
        GHAssertTrue([finishError isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]], @"cancelCallback mismatch");
        
        GHAssertEquals((NSUInteger)0, secondLoader.loadingCount, @"unwanted invocation - second loader");
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
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
        JFFAsyncOperationProgressCallback progressCallback = ^(id progressInfo) {
            
            progressCallbackCalled = YES;
        };
        
        __block NSError *finishError;
        
        JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error) {
            
            finishError = error;
        };
        
        loader(progressCallback, nil, doneCallback);
        
        firstLoader.loaderFinishBlock([NSNull new], nil);
        
        GHAssertFalse(progressCallbackCalled, nil);
        GHAssertTrue([finishError isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]], nil);
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

@end
