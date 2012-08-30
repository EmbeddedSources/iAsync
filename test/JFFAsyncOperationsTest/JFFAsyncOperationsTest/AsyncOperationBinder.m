#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface AsyncMonadTest : GHTestCase

@end

@implementation AsyncMonadTest

-(void)setUp
{
    [ JFFCancelAsyncOperationBlockHolder    enableInstancesCounting ];
    [ JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting ];

    [ JFFAsyncOperationManager enableInstancesCounting ];
}

-(void)testNormalFinish
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperation secondLoaderBlock_ = secondLoader_.loader;

        __block id monadResult_ = nil;

        JFFAsyncOperationBinder secondLoaderBinder_ = ^JFFAsyncOperation( id firstResult_ )
        {
            monadResult_ = firstResult_;
            return secondLoaderBlock_;
        };
        JFFAsyncOperation asyncOp_ = bindSequenceOfAsyncOperations( firstLoader_.loader
                                                                   , secondLoaderBinder_
                                                                   , nil );

        __block id finalResult_ = nil;

        asyncOp_( nil, nil, ^( id result_, NSError* error_ )
        {
            finalResult_ = result_;
        } );

        id firstResult_ = @1;
        firstLoader_.loaderFinishBlock.didFinishBlock( firstResult_, nil );

        GHAssertTrue( monadResult_ == firstResult_, @"OK" );
        GHAssertFalse( secondLoader_.finished, @"OK" );
        GHAssertNil( finalResult_, @"OK" );

        id secondResult_ = @2;
        secondLoader_.loaderFinishBlock.didFinishBlock( secondResult_, nil );

        GHAssertTrue( secondLoader_.finished, @"OK" );
        GHAssertTrue( finalResult_ == secondResult_, @"OK" );
    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testFailFirstLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* firstLoader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperation secondLoaderBlock_ = secondLoader_.loader;

        __block NSError* finalError_ = nil;
        __block BOOL binderCalled_ = NO;

        JFFAsyncOperationBinder secondLoaderBinder_ = ^JFFAsyncOperation( id firstResult_ )
        {
            binderCalled_ = YES;
            return secondLoaderBlock_;
        };
        JFFAsyncOperation asyncOp_ = bindSequenceOfAsyncOperations( firstLoader_.loader
                                                                   , secondLoaderBinder_
                                                                   , nil );

        asyncOp_( nil, nil, ^( id result_, NSError* error_ )
        {
            finalError_ = error_;
        } );

        NSError* failError_ = [ JFFError newErrorWithDescription: @"error1" ];
        firstLoader_.loaderFinishBlock.didFinishBlock( nil, failError_ );

        GHAssertFalse( binderCalled_, @"OK" );
        GHAssertTrue( failError_ == finalError_, @"OK" );
    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

@end
