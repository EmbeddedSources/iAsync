#import <JFFAsyncOperations/Helpers/JFFAsyncOperationHandlerBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface FailOnFirstErrorGroupOfAsyncOperationsTest : GHTestCase
@end

@implementation FailOnFirstErrorGroupOfAsyncOperationsTest

- (void)setUp
{
    [JFFAsyncOperationHandlerBlockHolder   enableInstancesCounting];
    [JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting];
    
    [JFFAsyncOperationManager enableInstancesCounting];
}

//TODO cancel on fail one of sub loaders
- (void)testNormalFinish
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = failOnFirstErrorGroupOfAsyncOperations(firstLoader.loader,
                                                                          secondLoader.loader,
                                                                          nil );
        
        __block BOOL groupLoaderFinished = NO;
        loader( nil, nil, ^(id result, NSError *error) {
            
            if (result && !error) {
                
                groupLoaderFinished = YES;
            }
        });
        
        GHAssertFalse(firstLoader.finished , @"First loader not finished yet" );
        GHAssertFalse(secondLoader.finished, @"Second loader not finished yet");
        GHAssertFalse(groupLoaderFinished  , @"Group loader not finished yet" );
        
        secondLoader.loaderFinishBlock([NSNull null], nil);
        
        GHAssertTrue (secondLoader.finished, @"Second loader finished already");
        GHAssertFalse(firstLoader.finished , @"First loader not finished yet" );
        GHAssertFalse(groupLoaderFinished  , @"Group loader finished already" );
        
        firstLoader.loaderFinishBlock([NSNull null], nil);
        
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertTrue( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertTrue( groupLoaderFinished, @"Group loader finished already" );
        
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testFinishWithSecondError
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = failOnFirstErrorGroupOfAsyncOperations(firstLoader.loader,
                                                                           secondLoader.loader,
                                                                           nil);
        
        __block BOOL mainCanceled = NO;
        __block BOOL mainFinished = NO;
        
        JFFAsyncOperationChangeStateCallback stateCallback = ^(JFFAsyncOperationState state) {
            
            mainCanceled = YES;
        };
        JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error) {
            
            mainFinished = (result == nil) && (error != nil);
        };
        
        loader(nil, stateCallback, doneCallback);
        
        GHAssertFalse(firstLoader.canceled, @"First loader not canceled yet" );
        GHAssertFalse(secondLoader.canceled, @"Second loader not canceled yet" );
        GHAssertFalse(mainCanceled, @"Group loader not canceled yet" );
        GHAssertFalse(mainFinished, @"Group loader finished" );
        
        secondLoader.loaderFinishBlock(nil, [JFFError newErrorWithDescription:@"some error"]);
        
        GHAssertTrue (secondLoader.finished, @"Second loader finished already");
        GHAssertTrue (firstLoader.canceled, @"First loader not finished yet"  );
        GHAssertTrue (firstLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"First loader not finished yet");
        GHAssertFalse(mainCanceled, @"Group loader canceled");
        GHAssertTrue (mainFinished, @"Group loader finished");
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testFinishWithFirstError
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoade   = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = failOnFirstErrorGroupOfAsyncOperations(firstLoade.loader,
                                                                          secondLoader.loader,
                                                                          nil);
        
        __block BOOL mainCanceled = NO;
        __block BOOL mainFinished = NO;
        
        JFFAsyncOperationChangeStateCallback stateCallback = ^(JFFAsyncOperationState state) {
            
            mainCanceled = YES;
        };
        JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error) {
            
            mainFinished = (result == nil) && (error != nil);
        };
        
        loader( nil, stateCallback, doneCallback );
        
        GHAssertFalse(firstLoade.canceled, @"First loader not canceled yet" );
        GHAssertFalse(secondLoader.canceled, @"Second loader not canceled yet" );
        GHAssertFalse(mainCanceled, @"Group loader not canceled yet" );
        GHAssertFalse(mainFinished, @"Group loader finished" );
        
        firstLoade.loaderFinishBlock(nil, [JFFError newErrorWithDescription:@"some error"]);
        
        GHAssertTrue(firstLoade.finished, @"First loader finished already" );
        GHAssertTrue(secondLoader.canceled, @"Second loader not finished yet" );
        GHAssertTrue(secondLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"Second loader not finished yet");
        GHAssertFalse(mainCanceled, @"Group loader canceled" );
        GHAssertTrue (mainFinished, @"Group loader finished" );

    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testCancelFirstLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = failOnFirstErrorGroupOfAsyncOperations(firstLoader.loader,
                                                                          secondLoader.loader,
                                                                          nil);
        
        __block BOOL mainCanceled = NO;
        __block BOOL onceCanceled = NO;
        
        loader(nil, nil, ^(id result, NSError *error) {
            
            mainCanceled = [error isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]] && !onceCanceled;
            onceCanceled = YES;
        });
        
        GHAssertFalse(firstLoader .canceled, @"First loader not canceled yet" );
        GHAssertFalse(secondLoader.canceled, @"Second loader not canceled yet");
        GHAssertFalse(mainCanceled, @"Group loader not canceled yet" );
        
        firstLoader.loaderHandlerBlock(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertTrue(firstLoader.canceled, @"First loader canceled already" );
        GHAssertTrue(firstLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"First loader canceled already" );
        GHAssertTrue(secondLoader.canceled, @"Second loader canceled already" );
        GHAssertTrue(secondLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"Second loader canceled already" );
        GHAssertTrue(mainCanceled, @"Group loader canceled already" );
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testCancelSecondLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = failOnFirstErrorGroupOfAsyncOperations(firstLoader.loader,
                                                                          secondLoader.loader,
                                                                          nil);
        
        __block BOOL mainCanceled = NO;
        __block BOOL onceCanceled = NO;
        
        loader(nil, nil, ^(id result, NSError *error) {
            
            mainCanceled = [error isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]] && !onceCanceled;
            onceCanceled = YES;
        });
        
        GHAssertFalse(firstLoader.canceled , @"First loader not canceled yet" );
        GHAssertFalse(secondLoader.canceled, @"Second loader not canceled yet");
        GHAssertFalse(mainCanceled, @"Group loader not canceled yet" );
        
        secondLoader.loaderHandlerBlock(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertTrue(firstLoader.canceled, @"First loader canceled already" );//not obligatory
        GHAssertTrue(firstLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"First loader canceled already" );
        GHAssertTrue(secondLoader.canceled, @"Second loader canceled already" );
        GHAssertTrue(secondLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"Second loader canceled already" );
        GHAssertTrue(mainCanceled, @"Group loader canceled already" );
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testCancelMainLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = failOnFirstErrorGroupOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL mainCanceled = NO;
        __block BOOL onceCanceled = NO;
        
        JFFAsyncOperationHandler cancel = loader(nil, nil, ^(id result, NSError *error) {
            
            mainCanceled = [error isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]] && !onceCanceled;
            onceCanceled = YES;
        });
        
        GHAssertFalse(firstLoader.canceled, @"First loader not canceled yet" );
        GHAssertFalse(secondLoader.canceled, @"Second loader not canceled yet" );
        GHAssertFalse(mainCanceled, @"Group loader not canceled yet" );
        
        cancel(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertTrue(firstLoader.canceled   , @"First loader canceled already" );
        GHAssertTrue(firstLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"First loader canceled already" );
        GHAssertTrue(secondLoader.canceled  , @"Second loader canceled already");
        GHAssertTrue(secondLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"Second loader canceled already");
        GHAssertTrue(mainCanceled, @"Group loader canceled already");
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testImmediatelyCancelCallbackOfFirstLoader
{
    NSUInteger initialInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger initialInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger initialInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        firstLoader.cancelAtLoading = JFFCancelAsyncOperationManagerWithYesFlag;
        
        JFFAsyncOperation loader = failOnFirstErrorGroupOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL progressCallbackCalled = NO;
        JFFAsyncOperationProgressCallback progressCallback = ^(id progressInfo) {
            
            progressCallbackCalled = YES;
        };
        
        __block NSError *finishError;
        __block NSUInteger cancelCallbackNumberOfCalls = 0;
        
        JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error) {
            
            if ([error isKindOfClass:[JFFAsyncOperationAbstractFinishError class]])
                ++cancelCallbackNumberOfCalls;
            
            finishError = error;
        };
        
        loader(progressCallback, nil, doneCallback);
        
        GHAssertFalse(progressCallbackCalled, nil);
        GHAssertTrue([finishError isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]], nil);
        GHAssertEquals((NSUInteger)1, cancelCallbackNumberOfCalls, nil);
        
        GHAssertTrue (firstLoader .canceled, nil);
        GHAssertFalse(secondLoader.canceled, nil);
        
        GHAssertEquals((NSUInteger)1, firstLoader .loadingCount, nil);
        GHAssertEquals((NSUInteger)0, secondLoader.loadingCount, nil);
    }
    
    GHAssertTrue(initialInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(initialInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(initialInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testImmediatelyCancelCallbackOfSecondLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        secondLoader.cancelAtLoading = JFFCancelAsyncOperationManagerWithYesFlag;
        
        JFFAsyncOperation loader = failOnFirstErrorGroupOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL progressCallbackCalled = NO;
        JFFAsyncOperationProgressCallback progressCallback = ^(id progressInfo) {
            
            progressCallbackCalled = YES;
        };
        
        __block NSError *finishError = NO;
        __block NSUInteger cancelCallbackNumberOfCalls = 0;
        
        JFFDidFinishAsyncOperationCallback doneCallback = ^(id result, NSError *error) {
            
            if ([error isKindOfClass:[JFFAsyncOperationAbstractFinishError class]])
                ++cancelCallbackNumberOfCalls;
            
            finishError = error;
        };
        
        loader(progressCallback, nil, doneCallback);
        
        GHAssertFalse(progressCallbackCalled, nil);
        GHAssertTrue ([finishError isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]], nil);
        GHAssertEquals((NSUInteger)1, cancelCallbackNumberOfCalls, nil);
        
        GHAssertTrue(firstLoader .canceled, nil);
        GHAssertTrue(secondLoader.canceled, nil);
        
        GHAssertEquals((NSUInteger)1, firstLoader .loadingCount, nil);
        GHAssertEquals((NSUInteger)1, secondLoader.loadingCount, nil);
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

@end
