#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>


@interface SequenceWithSuccessfullResultTest : GHTestCase
@end

@implementation SequenceWithSuccessfullResultTest

-(void)setUp
{
    [super setUp];

    [JFFCancelAsyncOperationBlockHolder    enableInstancesCounting];
    [JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting];
    
    [JFFAsyncOperationManager enableInstancesCounting];
}

-(void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [ super tearDown ];
}

-(void)testBlocksAreExecutedInTurn
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *thirdLoader  = [JFFAsyncOperationManager new];
        
        __weak JFFAsyncOperationManager* assign_first_loader_ = firstLoader;
        JFFAsyncOperation loader2_ = asyncOperationWithDoneBlock( secondLoader.loader, ^() {
            
            GHAssertTrue( assign_first_loader_.finished, @"First loader finished already" );
        } );
        
        JFFAsyncOperation loader_ = sequenceOfAsyncOperationsWithSuccessfullResults( @[ firstLoader.loader, loader2_, thirdLoader.loader ] );
        
        __block id sequenceResult = nil;
        
        __block BOOL sequenceLoaderFinished = NO;
        loader_( nil, nil, ^( id result_, NSError* error_ ) {
            
            if ( result_ && !error_ ) {
                
                sequenceResult = result_;
                sequenceLoaderFinished = YES;
            }
        } );
        
        NSNumber* firstResult  = @(2.71);
        NSNumber* secondResult = @(3.14);
        NSString* thirdResult = @"E and Pi";
        
        GHAssertFalse( firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse( thirdLoader.finished, @"Third loader not finished yet" );
        GHAssertFalse( sequenceLoaderFinished, @"Sequence loader not finished yet" );
        
        firstLoader.loaderFinishBlock.didFinishBlock( firstResult, nil );
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertFalse( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse( thirdLoader.finished, @"Third loader not finished yet" );
        GHAssertFalse( sequenceLoaderFinished, @"Sequence loader finished already" );
        
        
        secondLoader.loaderFinishBlock.didFinishBlock( secondResult, nil );
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertTrue( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse( thirdLoader.finished, @"Third loader not finished yet" );
        GHAssertFalse( sequenceLoaderFinished, @"Sequence loader finished already" );
        
        thirdLoader.loaderFinishBlock.didFinishBlock( thirdResult, nil );
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertTrue( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertTrue( thirdLoader.finished, @"Third loader not finished yet" );
        GHAssertTrue( sequenceLoaderFinished, @"Sequence loader finished already" );
        
        
        GHAssertTrue( [ sequenceResult isKindOfClass: [ NSArray class ] ], @"Result type mismatch" );
        GHAssertTrue( 3 == [ sequenceResult count ], @"result count mismatch" );
        
        NSArray* expectedResult = @[ firstResult, secondResult, thirdResult ];
        GHAssertEqualObjects( expectedResult, sequenceResult, @"result object mismatch" );
    }
    
    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"Successfull object of this class should be deSuccessfullocated");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"Successfull object of this class should be deSuccessfullocated");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"Successfull object of this class should be deSuccessfullocated");
}

-(void)testMultiSequenceWithEmptyArray
{
    @autoreleasepool
    {
        GHAssertThrows
        (
         sequenceOfAsyncOperationsWithSuccessfullResults( @[] ),
         @"asert expected"
         );
    }
    
    
    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"Successfull object of this class should be deSuccessfullocated");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"Successfull object of this class should be deSuccessfullocated");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"Successfull object of this class should be deSuccessfullocated");
}

-(void)testMultiSequenceWithOneLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader_ = sequenceOfAsyncOperationsWithSuccessfullResults( @[firstLoader.loader] );
        
        __block id sequenceResult = nil;
        
        __block BOOL sequenceLoaderFinished = NO;
        loader_( nil, nil, ^( id result_, NSError* error_ ) {
            
            if ( result_ && !error_ ) {
                
                sequenceResult = result_;
                sequenceLoaderFinished = YES;
            }
        } );
        
        NSNumber* firstResult  = @(2.71);
        GHAssertFalse( firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse( sequenceLoaderFinished, @"Sequence loader not finished yet" );
        
        firstLoader.loaderFinishBlock.didFinishBlock( firstResult, nil );
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertTrue( sequenceLoaderFinished, @"Sequence loader finished already" );
        
        GHAssertTrue( [ sequenceResult isKindOfClass: [ NSArray class ] ], @"Result type mismatch" );
        GHAssertTrue( 1 == [ sequenceResult count ], @"result count mismatch" );
        
        NSArray* expectedResult = @[ firstResult ];
        GHAssertEqualObjects( expectedResult, sequenceResult, @"result object mismatch" );
    }


    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"Successfull object of this class should be deSuccessfullocated");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"Successfull object of this class should be deSuccessfullocated");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"Successfull object of this class should be deSuccessfullocated");
}

-(void)testFailedOperationResultsAreSkippedInMultiSequence
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        secondLoader.failAtLoading = YES;
        
        JFFAsyncOperationManager *thirdLoader  = [JFFAsyncOperationManager new];
        thirdLoader.finishAtLoading = YES;
        
        __weak JFFAsyncOperationManager* assign_first_loader_ = firstLoader;
        JFFAsyncOperation loader2_ = asyncOperationWithDoneBlock( secondLoader.loader, ^() {
            
            GHAssertTrue( assign_first_loader_.finished, @"First loader finished already" );
        } );
        
        JFFAsyncOperation loader_ = sequenceOfAsyncOperationsWithSuccessfullResults( @[ firstLoader.loader, loader2_, thirdLoader.loader ] );
        
        __block id sequenceResult = nil;
        __block NSError* sequenceError = nil;
        
        __block BOOL sequenceLoaderFinished = NO;
        loader_( nil, nil, ^( id result_, NSError* error_ ) {
                sequenceError = error_;
                sequenceResult = result_;
                sequenceLoaderFinished = YES;
        } );
        
        
        GHAssertFalse( firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse( thirdLoader.finished, @"Third loader not finished yet" );
        GHAssertFalse( sequenceLoaderFinished, @"Sequence loader not finished yet" );

        NSNumber* firstResult  = @(2.71);
        NSNull* thirdResult = [ NSNull null ];
        firstLoader.loaderFinishBlock.didFinishBlock( firstResult, nil );

        
//        secondLoader.loaderFinishBlock.didFinishBlock( nil, secondError );
        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertTrue( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertTrue( thirdLoader.finished, @"Third loader not finished yet" );
        GHAssertTrue( sequenceLoaderFinished, @"Sequence loader finished already" );
        
        GHAssertNotNil( sequenceResult, @"Result type mismatch" );
        GHAssertNil( sequenceError, @"error object mismatch" );
        
        GHAssertTrue( [ sequenceResult isKindOfClass: [ NSArray class ] ], @"Result type mismatch" );
        GHAssertTrue( 2 == [ sequenceResult count ], @"result count mismatch" );
        
        NSArray* expectedResult = @[ firstResult, thirdResult ];
        GHAssertEqualObjects( expectedResult, sequenceResult, @"result object mismatch" );
    }
    
    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"Successfull object of this class should be deSuccessfullocated");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"Successfull object of this class should be deSuccessfullocated");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"Successfull object of this class should be deSuccessfullocated");
}

@end
