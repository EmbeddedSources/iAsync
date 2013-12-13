#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFAsyncOperationHandlerBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFAsyncOperationProgressBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface WeakAsyncOperationTest : GHTestCase
@end

@implementation WeakAsyncOperationTest

- (void)setUp
{
    [JFFSimpleBlockHolder                  enableInstancesCounting];
    [JFFAsyncOperationHandlerBlockHolder   enableInstancesCounting];
    [JFFAsyncOperationProgressBlockHolder  enableInstancesCounting];
    [JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting];
}

- (void)testCancelActionAfterUnsubscribeOnDealloc
{
    NSUInteger originalInstanceCount1 = [JFFSimpleBlockHolder                  instancesCount];
    NSUInteger originalInstanceCount2 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationProgressBlockHolder  instancesCount];
    NSUInteger originalInstanceCount4 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    
    @autoreleasepool {
        __block JFFAsyncOperationHandlerTask cancelCallbackCalled = JFFAsyncOperationHandlerTaskUndefined;
        JFFAsyncOperationHandler cancel;
        
        @autoreleasepool
        {
            NSObject *obj = [NSObject new];
            
            @autoreleasepool
            {
                JFFAsyncOperation operation = ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                                                        JFFAsyncOperationChangeStateCallback stateCallback,
                                                                        JFFDidFinishAsyncOperationCallback doneCallback)
                {
                    stateCallback = [stateCallback copy];
                    doneCallback  = [doneCallback  copy];
                    
                    return ^void(JFFAsyncOperationHandlerTask task) {
                        
                        processHandlerFlag(task, stateCallback, doneCallback);
                    };
                };
                
                operation = [obj autoUnsubsribeOnDeallocAsyncOperation:operation];
                
                cancel = operation(nil, ^(JFFAsyncOperationState state) {
                    
                    cancelCallbackCalled = YES;
                }, nil);
            }
        }
        
        GHAssertTrue(cancelCallbackCalled, @"Cancel callback should be called");
        cancelCallbackCalled = NO;
        
        cancel(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertFalse(cancelCallbackCalled, @"Cancel callback should not be called after dealloc");
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFSimpleBlockHolder                  instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationProgressBlockHolder  instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount4 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
}

- (void)testOnceCancelBlockCallingOnDealloc
{
    NSUInteger originalInstanceCount1 = [JFFSimpleBlockHolder                  instancesCount];
    NSUInteger originalInstanceCount2 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationProgressBlockHolder  instancesCount];
    NSUInteger originalInstanceCount4 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    
    @autoreleasepool
    {
        __block NSUInteger cancelCallbackCallCount = 0;
        
        @autoreleasepool
        {
            NSObject *obj = [NSObject new];
            
            JFFAsyncOperation operation = ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                                                    JFFAsyncOperationChangeStateCallback stateCallback,
                                                                    JFFDidFinishAsyncOperationCallback doneCallback)
            {
                stateCallback = [stateCallback copy];
                doneCallback  = [doneCallback  copy];
                
                return ^void(JFFAsyncOperationHandlerTask task) {
                    
                    ++cancelCallbackCallCount;
                    processHandlerFlag(task, stateCallback, doneCallback);
                };
            };
            
            operation = [obj autoUnsubsribeOnDeallocAsyncOperation:operation];
            
            operation(nil, nil, nil);
        }
        
        GHAssertTrue(1 == cancelCallbackCallCount, @"Cancel callback should not be called after dealloc" );
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFSimpleBlockHolder                  instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationProgressBlockHolder  instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount4 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
}

- (void)testCancelCallbackCallingOnCancelBlock
{
    NSUInteger originalInstanceCount1 = [JFFSimpleBlockHolder                  instancesCount];
    NSUInteger originalInstanceCount2 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationProgressBlockHolder  instancesCount];
    NSUInteger originalInstanceCount4 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    
    @autoreleasepool {
        NSObject *obj = [NSObject new];
        
        __block BOOL cancelBlockCalled = NO;
        
        JFFAsyncOperation operation = ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                                                JFFAsyncOperationChangeStateCallback stateCallback,
                                                                JFFDidFinishAsyncOperationCallback doneCallback) {
            stateCallback = [stateCallback copy];
            doneCallback  = [doneCallback  copy];
            
            return ^void(JFFAsyncOperationHandlerTask task) {
                
                cancelBlockCalled = (task == JFFAsyncOperationHandlerTaskCancel);
                processHandlerFlag(task, stateCallback, doneCallback);
            };
        };
        
        operation = [obj autoUnsubsribeOnDeallocAsyncOperation:operation];
        
        __block BOOL cancelCallbackCalled = NO;
        
        JFFAsyncOperationHandler cancel = operation(nil, nil, ^(id result, NSError *error) {
            
            cancelCallbackCalled = [error isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]];
        });
        
        cancel(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertTrue(cancelCallbackCalled, @"Cancel callback should not be called after dealloc");
        GHAssertTrue(cancelBlockCalled, @"Cancel callback should not be called after dealloc");
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFSimpleBlockHolder                  instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationProgressBlockHolder  instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount4 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
}

// When unsubscribe from autoCancelAsyncOperation -> native should not be canceled
- (void)testUnsubscribeFromAutoCancel
{
    NSUInteger originalInstanceCount1 = [JFFSimpleBlockHolder                  instancesCount];
    NSUInteger originalInstanceCount2 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationProgressBlockHolder  instancesCount];
    NSUInteger originalInstanceCount4 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    
    @autoreleasepool
    {
        NSObject *operationOwner = [NSObject new];
        
        __block BOOL nativeCancelBlockCalled = NO;
        
        JFFAsyncOperation operation = ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                                                JFFAsyncOperationChangeStateCallback stateCallback,
                                                                JFFDidFinishAsyncOperationCallback doneCallback) {
            
            stateCallback = [stateCallback copy];
            doneCallback  = [doneCallback  copy];
            
            return ^void(JFFAsyncOperationHandlerTask task) {
                
                nativeCancelBlockCalled = (task == JFFAsyncOperationHandlerTaskUnsubscribe);
                processHandlerFlag(task, stateCallback, doneCallback);
            };
        };
        
        JFFAsyncOperation autoCancelOperation = [operationOwner autoCancelOnDeallocAsyncOperation:operation];
        
        __block BOOL deallocated = NO;
        JFFAsyncOperationHandler cancel;
        __block BOOL cancelCallbackCalled = NO;
        
        @autoreleasepool
        {
            NSObject *ownedByCallbacks = [NSObject new];
            [ownedByCallbacks addOnDeallocBlock:^void(void) {
                
                deallocated = YES;
            }];
            
            JFFAsyncOperationProgressCallback progressCallback = ^void(id progressInfo)
            {
                //simulate using object in callback block
                [ownedByCallbacks class];
            };
            JFFDidFinishAsyncOperationCallback doneCallback = ^void(id result, NSError *error) {
                
                cancelCallbackCalled = [error isKindOfClass:[JFFAsyncOpFinishedByUnsubscriptionError class]];
                //simulate using object in callback block
                [ownedByCallbacks class];
            };
            
            cancel = autoCancelOperation(progressCallback, nil, doneCallback);
        }
        
        GHAssertFalse(deallocated, @"owned_by_callbacks_ object should not be deallocated" );
        
        cancel(JFFAsyncOperationHandlerTaskUnsubscribe);
        
        GHAssertTrue(nativeCancelBlockCalled, @"Native cancel block should not be called" );
        GHAssertTrue(deallocated, @"owned_by_callbacks_ objet should be deallocated" );
        GHAssertTrue(cancelCallbackCalled, @"cancel callback should ba called" );
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFSimpleBlockHolder                  instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationProgressBlockHolder  instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount4 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
}

- (void)testCancelCallbackCallingForNativeLoaderWhenWeekDelegateRemove
{
    NSUInteger originalInstanceCount1 = [JFFSimpleBlockHolder                  instancesCount];
    NSUInteger originalInstanceCount2 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationProgressBlockHolder  instancesCount];
    NSUInteger originalInstanceCount4 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    
    @autoreleasepool
    {
        __block BOOL nativeCancelBlockCalled = NO;
        
        @autoreleasepool
        {
            NSObject *operationOwner = [NSObject new];
            
            __block BOOL unsibscribeCancelBlockCalled = NO;
            __block BOOL delegateDeallocated  = NO;
            
            @autoreleasepool
            {
                NSObject *delegate = [NSObject new];
                [delegate addOnDeallocBlock:^void(void) {
                    
                    delegateDeallocated  = YES;
                }];
                
                JFFAsyncOperation operation_ = nil;
                
                @autoreleasepool
                {
                    operation_ = [^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                                            JFFAsyncOperationChangeStateCallback stateCallback,
                                                            JFFDidFinishAsyncOperationCallback doneCallback) {
                        
                        stateCallback = [stateCallback copy];
                        doneCallback  = [doneCallback  copy];
                        
                        return ^void(JFFAsyncOperationHandlerTask task) {
                            
                            nativeCancelBlockCalled = (task == JFFAsyncOperationHandlerTaskUnsubscribe);
                            processHandlerFlag(task, stateCallback, doneCallback);
                        };
                    } copy];
                    //like native operation still living
                    
                    JFFAsyncOperation autoCancelOperation_ = [operationOwner autoCancelOnDeallocAsyncOperation:operation_];
                    
                    __unsafe_unretained id weakDelegate = delegate;
                    
                    JFFDidFinishAsyncOperationCallback doneCallback = ^void(id result, NSError *error) {
                        
                        unsibscribeCancelBlockCalled = [error isKindOfClass:[JFFAsyncOpFinishedByUnsubscriptionError class]];
                        NSLog(@"notify delegate: %@, with owner: %@", weakDelegate, operationOwner);
                    };
                    [weakDelegate autoUnsubsribeOnDeallocAsyncOperation:autoCancelOperation_](nil, nil, doneCallback);
                }
            }
            
            GHAssertTrue(delegateDeallocated         , @"OK");
            GHAssertTrue(nativeCancelBlockCalled     , @"OK");
            GHAssertTrue(unsibscribeCancelBlockCalled, @"OK");
            nativeCancelBlockCalled = NO;
        }
        
        GHAssertFalse( nativeCancelBlockCalled, @"operation_ should be canceled here" );
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFSimpleBlockHolder                  instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationProgressBlockHolder  instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount4 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
}

@end
