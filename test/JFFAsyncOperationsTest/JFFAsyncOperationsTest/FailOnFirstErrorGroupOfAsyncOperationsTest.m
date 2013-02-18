#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface FailOnFirstErrorGroupOfAsyncOperationsTest : GHTestCase
@end

@implementation FailOnFirstErrorGroupOfAsyncOperationsTest

-(void)setUp
{
    [ JFFCancelAsyncOperationBlockHolder    enableInstancesCounting ];
    [ JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting ];

    [ JFFAsyncOperationManager enableInstancesCounting ];
}

//TODO cancel on fail one of sub loaders
-(void)testNormalFinish
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation loader_ = failOnFirstErrorGroupOfAsyncOperations(firstLoader.loader,
                                                                           secondLoader.loader,
                                                                           nil );
        
        __block BOOL groupLoaderFinished_ = NO;
        loader_( nil, nil, ^( id result_, NSError* error_ )
        {
            if ( result_ && !error_ )
            {
                groupLoaderFinished_ = YES;
            }
        } );
        
        GHAssertFalse( firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertFalse( groupLoaderFinished_, @"Group loader not finished yet" );

        secondLoader.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

        GHAssertTrue( secondLoader.finished, @"Second loader finished already" );
        GHAssertFalse( firstLoader.finished, @"First loader not finished yet" );
        GHAssertFalse( groupLoaderFinished_, @"Group loader finished already" );

        firstLoader.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

        GHAssertTrue( firstLoader.finished, @"First loader finished already" );
        GHAssertTrue( secondLoader.finished, @"Second loader not finished yet" );
        GHAssertTrue( groupLoaderFinished_, @"Group loader finished already" );

    }

   GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
   GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testFinishWithSecondError
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = failOnFirstErrorGroupOfAsyncOperations( firstLoader_.loader
                                                                           , secondLoader_.loader
                                                                           , nil );

        __block BOOL mainCanceled_ = NO;
        __block BOOL mainFinished_ = NO;

        JFFCancelAsyncOperationHandler cancelCallback_ = ^( BOOL canceled_ )
        {
            mainCanceled_ = YES;
        };
        JFFDidFinishAsyncOperationHandler doneCallback_ = ^( id result_, NSError* error_ )
        {
            mainFinished_ = ( result_ == nil ) && ( error_ != nil );
        };

        loader_( nil, cancelCallback_, doneCallback_ );

        GHAssertFalse( firstLoader_.canceled, @"First loader not canceled yet" );
        GHAssertFalse( secondLoader_.canceled, @"Second loader not canceled yet" );
        GHAssertFalse( mainCanceled_, @"Group loader not canceled yet" );
        GHAssertFalse( mainFinished_, @"Group loader finished" );

        secondLoader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError newErrorWithDescription: @"some error" ] );

        GHAssertTrue ( secondLoader_.finished, @"Second loader finished already" );
        GHAssertTrue ( firstLoader_.canceled, @"First loader not finished yet" );
        GHAssertTrue ( firstLoader_.cancelFlag, @"First loader not finished yet" );
        GHAssertFalse( mainCanceled_, @"Group loader canceled" );
        GHAssertTrue ( mainFinished_, @"Group loader finished" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testFinishWithFirstError
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = failOnFirstErrorGroupOfAsyncOperations( firstLoader_.loader
                                                                           , secondLoader_.loader
                                                                           , nil );

        __block BOOL mainCanceled_ = NO;
        __block BOOL mainFinished_ = NO;

        JFFCancelAsyncOperationHandler cancelCallback_ = ^( BOOL canceled_ )
        {
            mainCanceled_ = YES;
        };
        JFFDidFinishAsyncOperationHandler doneCallback_ = ^( id result_, NSError* error_ )
        {
            mainFinished_ = ( result_ == nil ) && ( error_ != nil );
        };

        loader_( nil, cancelCallback_, doneCallback_ );

        GHAssertFalse( firstLoader_.canceled, @"First loader not canceled yet" );
        GHAssertFalse( secondLoader_.canceled, @"Second loader not canceled yet" );
        GHAssertFalse( mainCanceled_, @"Group loader not canceled yet" );
        GHAssertFalse( mainFinished_, @"Group loader finished" );

        firstLoader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError newErrorWithDescription: @"some error" ] );

        GHAssertTrue( firstLoader_.finished, @"First loader finished already" );
        GHAssertTrue( secondLoader_.canceled, @"Second loader not finished yet" );
        GHAssertTrue( secondLoader_.cancelFlag, @"Second loader not finished yet" );
        GHAssertFalse( mainCanceled_, @"Group loader canceled" );
        GHAssertTrue ( mainFinished_, @"Group loader finished" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelFirstLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = failOnFirstErrorGroupOfAsyncOperations( firstLoader_.loader
                                                                           , secondLoader_.loader
                                                                           , nil );

        __block BOOL mainCanceled_ = NO;
        __block BOOL onceCanceled_ = NO;

        loader_( nil, ^( BOOL unsubscribe_only_if_no_ )
        {
            mainCanceled_ = unsubscribe_only_if_no_ && !onceCanceled_;
            onceCanceled_ = YES;
        }, nil );

        GHAssertFalse( firstLoader_.canceled, @"First loader not canceled yet" );
        GHAssertFalse( secondLoader_.canceled, @"Second loader not canceled yet" );
        GHAssertFalse( mainCanceled_, @"Group loader not canceled yet" );

        firstLoader_.loaderCancelBlock.onceCancelBlock( YES );

        GHAssertTrue( firstLoader_.canceled, @"First loader canceled already" );
        GHAssertTrue( firstLoader_.cancelFlag, @"First loader canceled already" );
        GHAssertTrue( secondLoader_.canceled, @"Second loader canceled already" );
        GHAssertTrue( secondLoader_.cancelFlag, @"Second loader canceled already" );
        GHAssertTrue( mainCanceled_, @"Group loader canceled already" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelSecondLoader
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
        
        JFFCancelAsyncOperationHandler cancelCallback = ^void(BOOL unsubscribeOnlyIfNo) {
            
            mainCanceled = !unsubscribeOnlyIfNo && !onceCanceled;
            onceCanceled = YES;
        };
        
        loader( nil, cancelCallback, nil );
        
        GHAssertFalse( firstLoader.canceled, @"First loader not canceled yet" );
        GHAssertFalse( secondLoader.canceled, @"Second loader not canceled yet" );
        GHAssertFalse( mainCanceled, @"Group loader not canceled yet" );
        
        secondLoader.loaderCancelBlock.onceCancelBlock( NO );
        
        GHAssertTrue( firstLoader.canceled, @"First loader canceled already" );
        GHAssertFalse( firstLoader.cancelFlag, @"First loader canceled already" );
        GHAssertTrue( secondLoader.canceled, @"Second loader canceled already" );
        GHAssertFalse( secondLoader.cancelFlag, @"Second loader canceled already" );
        GHAssertTrue( mainCanceled, @"Group loader canceled already" );
    }
    
    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelMainLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = failOnFirstErrorGroupOfAsyncOperations( firstLoader_.loader, secondLoader_.loader, nil );

        __block BOOL main_canceled_ = NO;
        __block BOOL once_canceled_ = NO;

        JFFCancelAsyncOperation cancel_ = loader_( nil, ^( BOOL unsubscribe_only_if_no_ )
        {
            main_canceled_ = unsubscribe_only_if_no_ && !once_canceled_;
            once_canceled_ = YES;
        }, nil );

        GHAssertFalse( firstLoader_.canceled, @"First loader not canceled yet" );
        GHAssertFalse( secondLoader_.canceled, @"Second loader not canceled yet" );
        GHAssertFalse( main_canceled_, @"Group loader not canceled yet" );

        cancel_( YES );

        GHAssertTrue( firstLoader_.canceled, @"First loader canceled already" );
        GHAssertTrue( firstLoader_.cancelFlag, @"First loader canceled already" );
        GHAssertTrue( secondLoader_.canceled, @"Second loader canceled already" );
        GHAssertTrue( secondLoader_.cancelFlag, @"Second loader canceled already" );
        GHAssertTrue( main_canceled_, @"Group loader canceled already" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

- (void)testImmediatelyCancelCallbackOfFirstLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager *firstLoader  = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *secondLoader = [JFFAsyncOperationManager new];
        
        firstLoader.cancelAtLoading = JFFCancelAsyncOperationManagerWithYesFlag;
        
        JFFAsyncOperation loader = failOnFirstErrorGroupOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL progressCallbackCalled = NO;
        JFFAsyncOperationProgressHandler progressCallback = ^(id progressInfo) {
            
            progressCallbackCalled = YES;
        };
        
        __block NSNumber *cancelCallbackCallFlag = NO;
        __block NSUInteger cancelCallbackNumberOfCalls = 0;
        JFFCancelAsyncOperationHandler cancelCallback = ^(BOOL canceled) {
            
            ++cancelCallbackNumberOfCalls;
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
        GHAssertEquals((NSUInteger)1, cancelCallbackNumberOfCalls, nil);
        
        GHAssertTrue(firstLoader .canceled, nil);
        GHAssertTrue(secondLoader.canceled, nil);
        
        GHAssertEquals((NSUInteger)1, firstLoader .loadingCount, nil);
        GHAssertEquals((NSUInteger)1, secondLoader.loadingCount, nil);
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
        
        JFFAsyncOperation loader = failOnFirstErrorGroupOfAsyncOperations(firstLoader.loader, secondLoader.loader, nil);
        
        __block BOOL progressCallbackCalled = NO;
        JFFAsyncOperationProgressHandler progressCallback = ^(id progressInfo) {
            
            progressCallbackCalled = YES;
        };
        
        __block NSNumber *cancelCallbackCallFlag = NO;
        __block NSUInteger cancelCallbackNumberOfCalls = 0;
        JFFCancelAsyncOperationHandler cancelCallback = ^(BOOL canceled) {
            
            ++cancelCallbackNumberOfCalls;
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
        GHAssertEquals((NSUInteger)1, cancelCallbackNumberOfCalls, nil);
        
        GHAssertTrue(firstLoader .canceled, nil);
        GHAssertTrue(secondLoader.canceled, nil);
        
        GHAssertEquals((NSUInteger)1, firstLoader .loadingCount, nil);
        GHAssertEquals((NSUInteger)1, secondLoader.loadingCount, nil);
    }
    
    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"OK");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"OK");
    GHAssertTrue(0 == [JFFAsyncOperationManager              instancesCount], @"OK");
}

@end
