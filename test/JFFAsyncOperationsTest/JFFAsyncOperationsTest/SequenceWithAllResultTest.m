#import <JFFAsyncOperations/Helpers/JFFAsyncOperationHandlerBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface SequenceWithAllResultTest : GHTestCase
@end

@implementation SequenceWithAllResultTest

- (void)setUp
{
    [super setUp];
    
    [JFFAsyncOperationHandlerBlockHolder   enableInstancesCounting];
    [JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting];
    
    [JFFAsyncOperationManager enableInstancesCounting];
}

- (void)testBlocksAreExecutedInTurn
{
    NSUInteger originalInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *thirdLoader  = [JFFAsyncOperationManager new];
        
        __weak JFFAsyncOperationManager *assignFirstLoader = firstLoader;
        JFFAsyncOperation loader2 = asyncOperationWithDoneBlock(secondLoader.loader, ^() {
            
            GHAssertTrue(assignFirstLoader.finished, @"First loader finished already");
        });
        
        JFFAsyncOperation loader = sequenceOfAsyncOperationsWithAllResults(@[firstLoader.loader, loader2, thirdLoader.loader]);
        
        __block id sequenceResult = nil;
        
        __block BOOL sequenceLoaderFinished = NO;
        
        JFFSimpleBlock test = ^() {
            
            sequenceResult = nil;
            sequenceLoaderFinished = NO;
            
            [firstLoader  clear];
            [secondLoader clear];
            [thirdLoader  clear];
            
            loader(nil, nil, ^(id result, NSError *error) {
                
                if (result && !error) {
                    
                    sequenceResult = result;
                    sequenceLoaderFinished = YES;
                }
            });
            
            NSNumber *firstResult  = @(2.71);
            NSNumber *secondResult = @(3.14);
            NSString *thirdResult = @"E and Pi";
            
            GHAssertFalse(firstLoader.finished  , @"First loader not finished yet");
            GHAssertFalse(secondLoader.finished , @"Second loader not finished yet");
            GHAssertFalse(thirdLoader.finished  , @"Third loader not finished yet");
            GHAssertFalse(sequenceLoaderFinished, @"Sequence loader not finished yet");
            
            firstLoader.loaderFinishBlock(firstResult, nil);
            GHAssertTrue(firstLoader.finished   , @"First loader finished already");
            GHAssertFalse(secondLoader.finished , @"Second loader not finished yet");
            GHAssertFalse(thirdLoader.finished  , @"Third loader not finished yet");
            GHAssertFalse(sequenceLoaderFinished, @"Sequence loader finished already");
            
            secondLoader.loaderFinishBlock(secondResult, nil);
            GHAssertTrue(firstLoader.finished   , @"First loader finished already");
            GHAssertTrue(secondLoader.finished  , @"Second loader not finished yet");
            GHAssertFalse(thirdLoader.finished  , @"Third loader not finished yet");
            GHAssertFalse(sequenceLoaderFinished, @"Sequence loader finished already");
            
            thirdLoader.loaderFinishBlock(thirdResult, nil);
            GHAssertTrue(firstLoader.finished  , @"First loader finished already");
            GHAssertTrue(secondLoader.finished , @"Second loader not finished yet");
            GHAssertTrue(thirdLoader.finished  , @"Third loader not finished yet");
            GHAssertTrue(sequenceLoaderFinished, @"Sequence loader finished already");
            
            GHAssertTrue([sequenceResult isKindOfClass:[NSArray class]], @"Result type mismatch");
            GHAssertTrue(3 == [sequenceResult count], @"result count mismatch");
            
            NSArray *expectedResult = @[firstResult, secondResult, thirdResult];
            GHAssertEqualObjects(expectedResult, sequenceResult, @"result object mismatch");
        };
        
        test();
        
        test();//invoke th same loader again
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testMultiSequenceWithEmptyArray
{
    NSUInteger originalInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        GHAssertThrows
        (
         sequenceOfAsyncOperationsWithAllResults(@[]),
         @"asert expected"
         );
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testMultiSequenceWithOneLoader
{
    NSUInteger originalInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader = sequenceOfAsyncOperationsWithAllResults(@[firstLoader.loader]);
        
        __block id sequenceResult = nil;
        
        __block BOOL sequenceLoaderFinished = NO;
        loader( nil, nil, ^(id result, NSError *error ) {
            
            if (result && !error) {
                
                sequenceResult = result;
                sequenceLoaderFinished = YES;
            }
        });
        
        NSNumber *firstResult  = @(2.71);
        GHAssertFalse(firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse(sequenceLoaderFinished, @"Sequence loader not finished yet" );
        
        firstLoader.loaderFinishBlock(firstResult, nil);
        GHAssertTrue(firstLoader.finished, @"First loader finished already" );
        GHAssertTrue(sequenceLoaderFinished, @"Sequence loader finished already" );
        
        GHAssertTrue([ sequenceResult isKindOfClass: [ NSArray class ] ], @"Result type mismatch" );
        GHAssertTrue(1 == [ sequenceResult count ], @"result count mismatch" );
        
        NSArray *expectedResult = @[firstResult];
        GHAssertEqualObjects( expectedResult, sequenceResult, @"result object mismatch" );
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

- (void)testMultiSequenceFailsIfAnyOperationFails
{
    NSUInteger originalInstanceCount1 = [JFFAsyncOperationHandlerBlockHolder   instancesCount];
    NSUInteger originalInstanceCount2 = [JFFDidFinishAsyncOperationBlockHolder instancesCount];
    NSUInteger originalInstanceCount3 = [JFFAsyncOperationManager              instancesCount];
    
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        secondLoader.failAtLoading = YES;
        
        JFFAsyncOperationManager *thirdLoader  = [JFFAsyncOperationManager new];
        thirdLoader.finishAtLoading = YES;
        
        __weak JFFAsyncOperationManager *assignFirstLoader = firstLoader;
        JFFAsyncOperation loader2 = asyncOperationWithDoneBlock(secondLoader.loader, ^() {
            
            GHAssertTrue(assignFirstLoader.finished, @"First loader finished already");
        });
        
        JFFAsyncOperation loader = sequenceOfAsyncOperationsWithAllResults(@[firstLoader.loader, loader2, thirdLoader.loader]);
        
        __block id sequenceResult = nil;
        __block NSError *sequenceError = nil;
        
        __block BOOL sequenceLoaderFinished = NO;
        loader(nil, nil, ^(id result, NSError *error) {
            
            sequenceError  = error;
            sequenceResult = result;
            sequenceLoaderFinished = YES;
        });
        
        GHAssertFalse(firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse(secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse(thirdLoader.finished, @"Third loader not finished yet" );
        GHAssertFalse(sequenceLoaderFinished, @"Sequence loader not finished yet" );
        
        NSNumber *firstResult  = @(2.71);
        firstLoader.loaderFinishBlock(firstResult, nil);
        
        //        secondLoader.loaderFinishBlock.didFinishBlock(nil, secondError);
        GHAssertTrue(firstLoader.finished, @"First loader finished already");
        GHAssertTrue(secondLoader.finished, @"Second loader not finished yet");
        GHAssertFalse(thirdLoader.finished, @"Third loader not finished yet");
        GHAssertTrue(sequenceLoaderFinished, @"Sequence loader finished already");
        
        GHAssertNil(sequenceResult, @"Result type mismatch");
        GHAssertNotNil(sequenceError, @"error object mismatch");
    }
    
    GHAssertTrue(originalInstanceCount1 == [JFFAsyncOperationHandlerBlockHolder   instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount2 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(originalInstanceCount3 == [JFFAsyncOperationManager              instancesCount], @"All object of this class should be deallocated");
}

@end
