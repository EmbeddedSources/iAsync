#import <JFFAsyncOperations/Helpers/JFFAsyncOperationHandlerBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface AsyncMonadTest : GHTestCase
@end

@implementation AsyncMonadTest

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
        JFFAsyncOperation secondLoaderBlock = secondLoader.loader;
        
        __block id monadResult = nil;
        
        JFFAsyncOperationBinder secondLoaderBinder = ^JFFAsyncOperation(id firstResult) {
            
            monadResult = firstResult;
            return secondLoaderBlock;
        };
        JFFAsyncOperation asyncOp = bindSequenceOfAsyncOperations(firstLoader.loader,
                                                                  secondLoaderBinder,
                                                                  nil );
        
        __block id finalResult_ = nil;
        
        asyncOp(nil, nil, ^(id result_, NSError *error_) {
            
            finalResult_ = result_;
        });
        
        id firstResult = @1;
        firstLoader.loaderFinishBlock(firstResult, nil);
        
        GHAssertTrue( monadResult == firstResult, @"OK" );
        GHAssertFalse( secondLoader.finished, @"OK" );
        GHAssertNil( finalResult_, @"OK" );
        
        id secondResult_ = @2;
        secondLoader.loaderFinishBlock(secondResult_, nil);
        
        GHAssertTrue( secondLoader.finished, @"OK" );
        GHAssertTrue( finalResult_ == secondResult_, @"OK" );
    }
    
    GHAssertTrue(0 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

- (void)testFailFirstLoader
{
    NSUInteger instanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger instanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger instanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    __weak JFFAsyncOperationManager *firstLoader1;
    __weak JFFAsyncOperationManager *secondLoader1;
    
    __weak NSObject *testBlockFreed1;
    __weak NSObject *testBlockFreed2;
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        JFFAsyncOperation secondLoaderBlock = secondLoader.loader;
        
        firstLoader1  = firstLoader;
        secondLoader1 = secondLoader;
        
        NSObject *testBlockFreedTmp1 = [NSObject new];
        testBlockFreed1 = testBlockFreedTmp1;
        
        __block NSError *finalError = nil;
        __block BOOL binderCalled = NO;
        
        JFFAsyncOperationBinder secondLoaderBinder = ^JFFAsyncOperation(id firstResult) {
            
            [testBlockFreed1 class];
            binderCalled = YES;
            return secondLoaderBlock;
        };
        JFFAsyncOperation asyncOp = bindSequenceOfAsyncOperations(firstLoader.loader,
                                                                  secondLoaderBinder,
                                                                  nil );
        
        NSObject *testBlockFreedTmp2 = [NSObject new];
        testBlockFreed2 = testBlockFreedTmp2;
        
        asyncOp(nil, nil, ^(id result, NSError *error) {
            
            [testBlockFreed2 class];
            finalError = error;
        });
        
        NSError* failError = [JFFError newErrorWithDescription:@"error1"];
        firstLoader.loaderFinishBlock(nil, failError);
        
        GHAssertFalse(binderCalled, @"OK" );
        GHAssertTrue(failError == finalError, @"OK" );
    }
    
    GHAssertNil(testBlockFreed1, nil);
    GHAssertNil(testBlockFreed2, nil);
    
    GHAssertTrue(instanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"OK");
    GHAssertTrue(instanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(instanceCount3 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

@end
