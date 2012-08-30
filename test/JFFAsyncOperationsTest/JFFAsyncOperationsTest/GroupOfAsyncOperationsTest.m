#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface GroupOfAsyncOperationsTest : GHTestCase
@end

@implementation GroupOfAsyncOperationsTest

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
        JFFAsyncOperationManager* firstLoader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* secondLoader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = groupOfAsyncOperations( firstLoader_.loader
                                                           , secondLoader_.loader
                                                           , nil );

        __block BOOL group_loader_finished_ = NO;
        loader_( nil, nil, ^( id result_, NSError* error_ )
        {
            if ( result_ && !error_ )
            {
                group_loader_finished_ = YES;
            }
        } );

        GHAssertFalse( firstLoader_.finished, @"First loader not finished yet" );
        GHAssertFalse( secondLoader_.finished, @"Second loader not finished yet" );
        GHAssertFalse( group_loader_finished_, @"Group loader not finished yet" );

        secondLoader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

        GHAssertTrue( secondLoader_.finished, @"Second loader finished already" );
        GHAssertFalse( firstLoader_.finished, @"First loader not finished yet" );
        GHAssertFalse( group_loader_finished_, @"Group loader finished already" );

        firstLoader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

        GHAssertTrue( firstLoader_.finished , @"First loader finished already" );
        GHAssertTrue( secondLoader_.finished, @"Second loader not finished yet" );
        GHAssertTrue( group_loader_finished_, @"Group loader finished already" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testFinishWithFirstError
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );
      
        __block BOOL group_loader_failed_ = NO;
        loader_( nil, nil, ^( id result_, NSError* error_ )
        {
            if ( !result_ && error_ )
            {
                group_loader_failed_ = YES;
            }
        } );

        GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
        GHAssertFalse( second_loader_.finished, @"Second loader not finished yet" );
        GHAssertFalse( group_loader_failed_, @"Group loader not failed yet" );

        second_loader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError newErrorWithDescription: @"some error" ] );

        GHAssertTrue( second_loader_.finished, @"Second loader finished already" );
        GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
        GHAssertFalse( group_loader_failed_, @"Group loader failed already" );

        first_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

        GHAssertTrue( first_loader_.finished, @"First loader finished already" );
        GHAssertTrue( second_loader_.finished, @"Second loader not finished yet" );
        GHAssertTrue( group_loader_failed_, @"Group loader failed already" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testFinishWithSecondError
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

        __block BOOL group_loader_failed_ = NO;
        loader_( nil, nil, ^( id result_, NSError* error_ )
        {
            if ( !result_ && error_ )
            {
                group_loader_failed_ = YES;
            }
        } );

        GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
        GHAssertFalse( second_loader_.finished, @"Second loader not finished yet" );
        GHAssertFalse( group_loader_failed_, @"Group loader not failed yet" );

        second_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

        GHAssertTrue( second_loader_.finished, @"Second loader finished already" );
        GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
        GHAssertFalse( group_loader_failed_, @"Group loader failed already" );

        first_loader_.loaderFinishBlock.didFinishBlock( nil, [ JFFError newErrorWithDescription: @"some error" ] );

        GHAssertTrue( first_loader_.finished, @"First loader finished already" );
        GHAssertTrue( second_loader_.finished, @"Second loader not finished yet" );
        GHAssertTrue( group_loader_failed_, @"Group loader failed already" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelFirstLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

        __block BOOL main_canceled_ = NO;
        __block BOOL once_canceled_ = NO;

        loader_( nil, ^( BOOL unsubscribe_only_if_no_ )
        {
            main_canceled_ = unsubscribe_only_if_no_ && !once_canceled_;
            once_canceled_ = YES;
        }, nil );
      
        GHAssertFalse( first_loader_.canceled, @"First loader not canceled yet" );
        GHAssertFalse( second_loader_.canceled, @"Second loader not canceled yet" );
        GHAssertFalse( main_canceled_, @"Group loader not canceled yet" );

        first_loader_.loaderCancelBlock.onceCancelBlock( YES );

        GHAssertTrue( first_loader_.canceled, @"First loader canceled already" );
        GHAssertTrue( first_loader_.cancelFlag, @"First loader canceled already" );
        GHAssertTrue( second_loader_.canceled, @"Second loader canceled already" );
        GHAssertTrue( second_loader_.cancelFlag, @"Second loader canceled already" );
        GHAssertTrue( main_canceled_, @"Group loader canceled already" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelSecondLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_  = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

        __block BOOL main_canceled_ = NO;
        __block BOOL once_canceled_ = NO;

        loader_( nil, ^( BOOL unsubscribe_only_if_no_ )
        {
            main_canceled_ = !unsubscribe_only_if_no_ && !once_canceled_;
            once_canceled_ = YES;
        }, nil );

        GHAssertFalse( first_loader_.canceled, @"First loader not canceled yet" );
        GHAssertFalse( second_loader_.canceled, @"Second loader not canceled yet" );
        GHAssertFalse( main_canceled_, @"Group loader not canceled yet" );

        second_loader_.loaderCancelBlock.onceCancelBlock( NO );

        GHAssertTrue( first_loader_.canceled, @"First loader canceled already" );
        GHAssertFalse( first_loader_.cancelFlag, @"First loader canceled already" );
        GHAssertTrue( second_loader_.canceled, @"Second loader canceled already" );
        GHAssertFalse( second_loader_.cancelFlag, @"Second loader canceled already" );
        GHAssertTrue( main_canceled_, @"Group loader canceled already" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelMainLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

        __block BOOL main_canceled_ = NO;
        __block BOOL once_canceled_ = NO;

        JFFCancelAsyncOperation cancel_ = loader_( nil, ^( BOOL unsubscribe_only_if_no_ )
        {
            main_canceled_ = unsubscribe_only_if_no_ && !once_canceled_;
            once_canceled_ = YES;
        }, nil );

        GHAssertFalse( first_loader_.canceled, @"First loader not canceled yet" );
        GHAssertFalse( second_loader_.canceled, @"Second loader not canceled yet" );
        GHAssertFalse( main_canceled_, @"Group loader not canceled yet" );

        cancel_( YES );

        GHAssertTrue( first_loader_.canceled, @"First loader canceled already" );
        GHAssertTrue( first_loader_.cancelFlag, @"First loader canceled already" );
        GHAssertTrue( second_loader_.canceled, @"Second loader canceled already" );
        GHAssertTrue( second_loader_.cancelFlag, @"Second loader canceled already" );
        GHAssertTrue( main_canceled_, @"Group loader canceled already" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testCancelAfterResultFirstLoader
{
    @autoreleasepool
    {
        JFFAsyncOperationManager* first_loader_ = [ JFFAsyncOperationManager new ];
        JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];

        JFFAsyncOperation loader_ = groupOfAsyncOperations( first_loader_.loader, second_loader_.loader, nil );

        __block BOOL main_canceled_ = NO;
        __block BOOL once_canceled_ = NO;

        JFFCancelAsyncOperationHandler cancel_callback_ = ^( BOOL unsubscribe_only_if_no_ )
        {
            main_canceled_ = unsubscribe_only_if_no_ && !once_canceled_;
            once_canceled_ = YES;
        };

        __block BOOL group_loader_finished_ = NO;

        JFFDidFinishAsyncOperationHandler done_callback_ = ^void( id result_, NSError* error_ )
        {
            group_loader_finished_ = YES;
        };
        JFFCancelAsyncOperation cancel_ = loader_( nil, cancel_callback_, done_callback_ );

        GHAssertFalse( first_loader_.canceled, @"First loader not canceled yet" );
        GHAssertFalse( second_loader_.canceled, @"Second loader not canceled yet" );
        GHAssertFalse( main_canceled_, @"Group loader not canceled yet" );

        second_loader_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

        GHAssertTrue( second_loader_.finished, @"Second loader finished already" );
        GHAssertFalse( first_loader_.finished, @"First loader not finished yet" );
        GHAssertFalse( group_loader_finished_, @"Group loader finished already" );

        cancel_( YES );

        GHAssertTrue( first_loader_.canceled, @"First loader canceled already" );
        GHAssertTrue( first_loader_.cancelFlag, @"First loader canceled already" );
        GHAssertFalse( second_loader_.canceled, @"Second loader canceled already" );
        GHAssertTrue( main_canceled_, @"Group loader canceled already" );

    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

typedef JFFAsyncOperation (*MergeLoadersPtr)( JFFAsyncOperation, ... );

-(void)testResultOfGroupLoadersWithFunc:( MergeLoadersPtr )func_
{
    @autoreleasepool
    {
        for ( int i = 0; i < 3; ++i )
        {
            for ( int j = 0; j < 2; ++j )
            {
                JFFAsyncOperationManager* first_loader_  = [ JFFAsyncOperationManager new ];
                JFFAsyncOperationManager* second_loader_ = [ JFFAsyncOperationManager new ];
                JFFAsyncOperationManager* third_loader_  = [ JFFAsyncOperationManager new ];

                JFFAsyncOperation loader_ = func_( first_loader_  .loader
                                                  , second_loader_.loader
                                                  , third_loader_ .loader
                                                  , nil );

                __block id resultContext_;
                JFFDidFinishAsyncOperationHandler done_callback_ = ^void( id result_, NSError* error_ )
                {
                    resultContext_ = result_;
                };
                loader_( nil, nil, done_callback_ );

                NSArray* results_ = @[ @"0", @"1", @"2" ];
                NSArray* loadersResults_ = @[ first_loader_ .loaderFinishBlock.didFinishBlock
                                            , second_loader_.loaderFinishBlock.didFinishBlock
                                            , third_loader_ .loaderFinishBlock.didFinishBlock ];

                NSMutableArray* indexes_ = [ NSMutableArray arrayWithArray: results_ ];

                NSUInteger firstIndex_ = [ indexes_[ i ] integerValue ];
                [ indexes_ removeObject: indexes_[ i ] ];

                NSUInteger secondIndex_ = [ indexes_[ j ] integerValue ];
                [ indexes_ removeObject: indexes_[ j ] ];

                NSUInteger thirdIndex_ = [ indexes_[ 0 ] integerValue ];

                JFFDidFinishAsyncOperationHandler loader1_ = loadersResults_[ firstIndex_  ];
                JFFDidFinishAsyncOperationHandler loader2_ = loadersResults_[ secondIndex_ ];
                JFFDidFinishAsyncOperationHandler loader3_ = loadersResults_[ thirdIndex_  ];

                loader1_( results_[ firstIndex_  ], nil );
                loader2_( results_[ secondIndex_ ], nil );
                loader3_( results_[ thirdIndex_  ], nil );

                GHAssertTrue( [ resultContext_ isEqual: results_ ], @"OK" );
            }
        }
    }

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

-(void)testResultOfGroupLoaders
{
    [ self testResultOfGroupLoadersWithFunc: &groupOfAsyncOperations ];
}

-(void)testResultOfFailOnFirstErrorGroupLoaders
{
    [ self testResultOfGroupLoadersWithFunc: &failOnFirstErrorGroupOfAsyncOperations ];
}

-(void)testMemoryManagementOfGroupLoaders
{
    __block BOOL result2WasDeallocated_ = NO;
    __block BOOL result3WasDeallocated_ = NO;

    @autoreleasepool
    {
        JFFAsyncOperationManager* loader5_ = [ JFFAsyncOperationManager new ];
        @autoreleasepool
        {
            JFFAsyncOperationManager* loader2_ = [ JFFAsyncOperationManager new ];
            JFFAsyncOperationManager* loader4_ = [ JFFAsyncOperationManager new ];

            @autoreleasepool
            {
                JFFAsyncOperationManager* loader1_ = [ JFFAsyncOperationManager new ];
                JFFAsyncOperationManager* loader3_ = [ JFFAsyncOperationManager new ];

                JFFAsyncOperation gr1Loader_ = groupOfAsyncOperations( loader1_.loader
                                                                      , loader2_.loader
                                                                      , nil );
                JFFAsyncOperation gr2Loader_ = groupOfAsyncOperations( loader3_.loader
                                                                      , loader4_.loader
                                                                      , nil );

                JFFAsyncOperation loader_ = groupOfAsyncOperations( gr1Loader_
                                                                   , gr2Loader_
                                                                   , loader5_.loader
                                                                   , nil );

                __block BOOL group_loader_finished_ = NO;

                JFFDidFinishAsyncOperationHandler done_callback_ = ^void( id result_, NSError* error_ )
                {
                    GHAssertFalse( result2WasDeallocated_, @"OK" );
                    GHAssertFalse( result3WasDeallocated_, @"OK" );
                    group_loader_finished_ = YES;
                };
                loader_( nil, nil, done_callback_ );

                GHAssertFalse( group_loader_finished_, @"First loader not canceled yet" );

                loader1_.loaderFinishBlock.didFinishBlock( nil, [ JFFError newErrorWithDescription: @"some error" ] );

                {
                    NSObject* result3_ = [ NSObject new ];
                    [ result3_ addOnDeallocBlock: ^
                    {
                        result3WasDeallocated_ = YES;
                    } ];
                    loader3_.loaderFinishBlock.didFinishBlock( result3_, nil );
                }

            }
            //@autoreleasepool

            {
                NSObject* result2_ = [ NSObject new ];
                [ result2_ addOnDeallocBlock: ^
                {
                    result2WasDeallocated_ = YES;
                } ];
                loader2_.loaderFinishBlock.didFinishBlock( result2_, nil );
            }

            loader4_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );
        }

        loader5_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );

    }

    GHAssertTrue( result2WasDeallocated_, @"OK" );
    GHAssertTrue( result3WasDeallocated_, @"OK" );

    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationManager              instancesCount ], @"OK" );
}

@end
