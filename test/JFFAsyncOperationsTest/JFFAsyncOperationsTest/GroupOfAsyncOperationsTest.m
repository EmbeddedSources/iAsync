#import <JFFAsyncOperations/Helpers/JFFAsyncOperationHandlerBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface GroupOfAsyncOperationsTest : GHTestCase
@end

@implementation GroupOfAsyncOperationsTest

- (void)setUp
{
    [JFFAsyncOperationHandlerBlockHolder   enableInstancesCounting];
    [JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting];
    
    [JFFAsyncOperationManager enableInstancesCounting];
}

- (void)testNormalFinish
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = groupOfAsyncOperations(firstLoader.loader,
                                                          secondLoader.loader,
                                                          nil);
        
        __block BOOL group_loader_finished_ = NO;
        loader(nil, nil, ^(id result_, NSError *error_) {
        
            if ( result_ && !error_ ) {
            
                group_loader_finished_ = YES;
            }
        });
        
        GHAssertFalse(firstLoader.finished, @"First loader not finished yet"  );
        GHAssertFalse(secondLoader.finished, @"Second loader not finished yet");
        GHAssertFalse(group_loader_finished_, @"Group loader not finished yet");
        
        secondLoader.loaderFinishBlock([ NSNull new], nil);
        
        GHAssertTrue( secondLoader.finished, @"Second loader finished already" );
        GHAssertFalse( firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse( group_loader_finished_, @"Group loader finished already" );

        firstLoader.loaderFinishBlock([NSNull new], nil);

        GHAssertTrue( firstLoader.finished , @"First loader finished already" );
        GHAssertTrue( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertTrue( group_loader_finished_, @"Group loader finished already" );
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testFinishWithFirstError
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = groupOfAsyncOperations( firstLoader.loader, secondLoader.loader, nil );
      
        __block BOOL groupLoaderFailed = NO;
        loader( nil, nil, ^(id result, NSError *error) {
            
            if (!result && error) {
                
                groupLoaderFailed = YES;
            }
        });
        
        GHAssertFalse(firstLoader .finished, @"First loader not finished yet" );
        GHAssertFalse(secondLoader.finished, @"Second loader not finished yet");
        GHAssertFalse(groupLoaderFailed, @"Group loader not failed yet" );
        
        secondLoader.loaderFinishBlock(nil, [JFFError newErrorWithDescription:@"some error"]);
        
        GHAssertTrue( secondLoader.finished, @"Second loader finished already" );
        GHAssertFalse( firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse( groupLoaderFailed, @"Group loader failed already" );
        
        firstLoader.loaderFinishBlock([NSNull null], nil);
        
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertTrue( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertTrue( groupLoaderFailed, @"Group loader failed already" );
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testFinishWithSecondError
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *first_loader_  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *second_loader_ = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader_ = groupOfAsyncOperations(first_loader_.loader, second_loader_.loader, nil);
        
        __block BOOL groupLoaderFailed = NO;
        loader_( nil, nil, ^( id result_, NSError* error_ ) {
        
            if (!result_ && error_) {
            
                groupLoaderFailed = YES;
            }
        } );
        
        GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
        GHAssertFalse( second_loader_.finished, @"Second loader not finished yet" );
        GHAssertFalse( groupLoaderFailed, @"Group loader not failed yet" );
        
        second_loader_.loaderFinishBlock([NSNull null], nil);
        
        GHAssertTrue( second_loader_.finished, @"Second loader finished already" );
        GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
        GHAssertFalse( groupLoaderFailed, @"Group loader failed already" );
        
        first_loader_.loaderFinishBlock(nil, [JFFError newErrorWithDescription:@"some error"]);
        
        GHAssertTrue( first_loader_.finished, @"First loader finished already" );
        GHAssertTrue( second_loader_.finished, @"Second loader not finished yet" );
        GHAssertTrue( groupLoaderFailed, @"Group loader failed already" );
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
        
        JFFAsyncOperation loader = groupOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL mainCanceled = NO;
        __block BOOL onceCanceled = NO;
        
        loader(nil, nil, ^(id result, NSError *error) {
            
            mainCanceled = [error isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]] && !onceCanceled;
            onceCanceled = YES;
        });
        
        GHAssertFalse(firstLoader.canceled , @"First loader not canceled yet" );
        GHAssertFalse(secondLoader.canceled, @"Second loader not canceled yet");
        GHAssertFalse(mainCanceled, @"Group loader not canceled yet");
        
        firstLoader.loaderHandlerBlock(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertTrue(firstLoader.canceled, @"First loader canceled already" );
        GHAssertTrue(firstLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"First loader canceled already");
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
        
        JFFAsyncOperation loader = groupOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL mainCanceled = NO;
        __block BOOL onceCanceled = NO;
        
        loader(nil, nil, ^(id result, NSError *error) {
            
            mainCanceled = [error isKindOfClass:[JFFAsyncOpFinishedByUnsubscriptionError class]] && !onceCanceled;
            onceCanceled = YES;
        });
        
        GHAssertFalse(firstLoader.canceled , @"First loader not canceled yet" );
        GHAssertFalse(secondLoader.canceled, @"Second loader not canceled yet");
        GHAssertFalse(mainCanceled, @"Group loader not canceled yet");
        
        secondLoader.loaderHandlerBlock(JFFAsyncOperationHandlerTaskUnsubscribe);
        
        GHAssertTrue(firstLoader.canceled, @"First loader canceled already" );
        GHAssertTrue(firstLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"First loader canceled already");
        GHAssertTrue(secondLoader.canceled, @"Second loader canceled already");
        GHAssertFalse(secondLoader.lastHandleFlag, @"Second loader canceled already" );
        GHAssertTrue(mainCanceled, @"Group loader canceled already");
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
        
        JFFAsyncOperation loader = groupOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL mainCanceled = NO;
        __block BOOL onceCanceled = NO;
        
        JFFAsyncOperationHandler cancel = loader(nil, nil, ^(id result, NSError *error) {
            
            mainCanceled = [error isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]] && !onceCanceled;
            onceCanceled = YES;
        });
        
        GHAssertFalse(firstLoader .canceled, @"First loader not canceled yet" );
        GHAssertFalse(secondLoader.canceled, @"Second loader not canceled yet");
        GHAssertFalse(mainCanceled, @"Group loader not canceled yet" );
        
        cancel(JFFAsyncOperationHandlerTaskCancel);
        
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

- (void)testCancelAfterResultFirstLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];

        JFFAsyncOperation loader = groupOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);

        __block BOOL mainCanceled = NO;
        __block BOOL onceCanceled = NO;
        __block BOOL groupLoaderFinished = NO;
        
        JFFDidFinishAsyncOperationCallback doneCallback = ^void(id result, NSError *error) {
        
            mainCanceled = [error isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]] && !onceCanceled;
            onceCanceled = YES;
            groupLoaderFinished = YES;
        };
        JFFAsyncOperationHandler cancel = loader(nil, nil, doneCallback);
        
        GHAssertFalse(firstLoader.canceled , @"First loader not canceled yet" );
        GHAssertFalse(secondLoader.canceled, @"Second loader not canceled yet");
        GHAssertFalse(mainCanceled, @"Group loader not canceled yet" );
        
        secondLoader.loaderFinishBlock([NSNull new], nil);
        
        GHAssertTrue(secondLoader.finished, @"Second loader finished already");
        GHAssertFalse(firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse(groupLoaderFinished, @"Group loader finished already" );
        
        cancel(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertTrue(firstLoader.canceled, @"First loader canceled already");
        GHAssertTrue(firstLoader.lastHandleFlag == JFFAsyncOperationHandlerTaskCancel, @"First loader canceled already");
        GHAssertFalse(secondLoader.canceled, @"Second loader canceled already" );
        GHAssertTrue(mainCanceled, @"Group loader canceled already" );
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

typedef JFFAsyncOperation (*MergeLoadersPtr)(JFFAsyncOperation, ...);

- (void)testResultOfGroupLoadersWithFunc:(MergeLoadersPtr)func
{
    @autoreleasepool
    {
        for ( int i = 0; i < 3; ++i )
        {
            for ( int j = 0; j < 2; ++j )
            {
                JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
                JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
                JFFAsyncOperationManager *thirdLoader  = [JFFAsyncOperationManager new];
                
                JFFAsyncOperation loader = func(firstLoader .loader,
                                                secondLoader.loader,
                                                thirdLoader .loader,
                                                nil);
                
                __block id resultContext;
                JFFDidFinishAsyncOperationCallback doneCallback = ^void(id result, NSError *error) {
                    
                    resultContext = result;
                };
                loader(nil, nil, doneCallback);
                
                NSArray *results = @[@"0", @"1", @"2"];
                NSArray *loadersResults = @[firstLoader .loaderFinishBlock,
                                            secondLoader.loaderFinishBlock,
                                            thirdLoader .loaderFinishBlock];
                
                NSMutableArray *indexes = [NSMutableArray arrayWithArray:results];
                
                NSUInteger firstIndex = [indexes[i] integerValue];
                [indexes removeObject:indexes[i]];
                
                NSUInteger secondIndex = [indexes[j] integerValue];
                [indexes removeObject:indexes[j]];

                NSUInteger thirdIndex = [indexes[0] integerValue];
                
                JFFDidFinishAsyncOperationCallback loader1 = loadersResults[firstIndex ];
                JFFDidFinishAsyncOperationCallback loader2 = loadersResults[secondIndex];
                JFFDidFinishAsyncOperationCallback loader3 = loadersResults[thirdIndex ];
                
                loader1(results[firstIndex ], nil);
                loader2(results[secondIndex], nil);
                loader3(results[thirdIndex ], nil);
                
                GHAssertTrue([resultContext isEqual:results], @"OK");
            }
        }
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testResultOfGroupLoaders
{
    [self testResultOfGroupLoadersWithFunc:&groupOfAsyncOperations];
}

- (void)testResultOfFailOnFirstErrorGroupLoaders
{
    [self testResultOfGroupLoadersWithFunc:&failOnFirstErrorGroupOfAsyncOperations];
}

- (void)testMemoryManagementOfGroupLoaders
{
    __block BOOL result2WasDeallocated_ = NO;
    __block BOOL result3WasDeallocated = NO;
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *loader5 = [JFFAsyncOperationManager new];
        @autoreleasepool
        {
            JFFAsyncOperationManager *loader2 = [JFFAsyncOperationManager new];
            JFFAsyncOperationManager *loader4 = [JFFAsyncOperationManager new];
            
            @autoreleasepool
            {
                JFFAsyncOperationManager *loader1 = [JFFAsyncOperationManager new];
                JFFAsyncOperationManager *loader3 = [JFFAsyncOperationManager new];
                
                JFFAsyncOperation gr1Loader_ = groupOfAsyncOperations(loader1.loader,
                                                                      loader2.loader,
                                                                      nil);
                JFFAsyncOperation gr2Loader_ = groupOfAsyncOperations(loader3.loader,
                                                                      loader4.loader,
                                                                      nil);

                JFFAsyncOperation loader_ = groupOfAsyncOperations( gr1Loader_
                                                                   , gr2Loader_
                                                                   , loader5.loader
                                                                   , nil );

                __block BOOL group_loader_finished_ = NO;

                JFFDidFinishAsyncOperationCallback done_callback_ = ^void( id result_, NSError* error_ )
                {
                    GHAssertFalse( result2WasDeallocated_, @"OK" );
                    GHAssertFalse( result3WasDeallocated, @"OK" );
                    group_loader_finished_ = YES;
                };
                loader_( nil, nil, done_callback_ );

                GHAssertFalse( group_loader_finished_, @"First loader not canceled yet" );
                
                loader1.loaderFinishBlock(nil, [JFFError newErrorWithDescription:@"some error"]);
                
                {
                    NSObject *result3 = [NSObject new];
                    [result3 addOnDeallocBlock: ^void(void) {
                        
                        result3WasDeallocated = YES;
                    }];
                    loader3.loaderFinishBlock(result3, nil);
                }

            }
            //@autoreleasepool

            {
                NSObject *result2 = [NSObject new];
                [result2 addOnDeallocBlock: ^(void) {
                    
                    result2WasDeallocated_ = YES;
                }];
                loader2.loaderFinishBlock(result2, nil);
            }
            
            loader4.loaderFinishBlock([NSNull new], nil);
        }
        
        loader5.loaderFinishBlock([NSNull null], nil);
    }
    
    GHAssertTrue(result2WasDeallocated_, @"OK");
    GHAssertTrue(result3WasDeallocated, @"OK");
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testArrayGroupOfTheSameLoadersResult
{
    JFFAsyncOperation loader = asyncOperationWithResult([NSNull null]);
    
    NSArray *loaders = @[loader, loader, loader];
    
    loader = groupOfAsyncOperationsArray(loaders);
    
    __block NSArray *resultArray;
    loader(nil, nil, ^(id result, NSError *error) {
        
        resultArray = result;
    });
    
    GHAssertTrue([resultArray count] == 3, @"OK");
}

- (void)testImmediatelyCancelCallbackOfFirstLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        firstLoader.cancelAtLoading = JFFCancelAsyncOperationManagerWithYesFlag;
        
        JFFAsyncOperation loader = groupOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
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
        
        JFFAsyncOperation loader = groupOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
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
