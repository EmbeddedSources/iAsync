
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/JFFBlockOperation.h>

@interface ParalelBlockTest : GHAsyncTestCase
@end

@implementation ParalelBlockTest

-(void)setUp
{
    [ JFFBlockOperation enableInstancesCounting ];
}

-(void)testParalelTask
{
    const NSUInteger initialSchedulerInstancesCount = [JFFBlockOperation instancesCount];

    __block BOOL theSameThread_ = NO;
    __block BOOL theProgressOk_ = NO;

    @autoreleasepool
    {
        dispatch_queue_t currentQueue_ = dispatch_get_current_queue();

        JFFSyncOperationWithProgress progressLoadDataBlock_ = ^id( NSError** error_
                                                                  , JFFAsyncOperationProgressHandler progressCallback_ )
        {
            if ( progressCallback_ )
                progressCallback_( [ NSNull null ] );
            return [ NSNull null ];
        };
        JFFAsyncOperation loader_ = asyncOperationWithSyncOperationWithProgressBlock( progressLoadDataBlock_ );

        JFFDidFinishAsyncOperationHandler doneCallback_ = ^( id result_, NSError* error_ )
        {
            theSameThread_ = ( currentQueue_ == dispatch_get_current_queue() );

            if ( result_ && theSameThread_ )
            {
                [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
            }
            else
            {
                [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
            }
        };

        JFFAsyncOperationProgressHandler progressCallback_ = ^( id data_ )
        {
            theProgressOk_ = YES;

            theSameThread_ = ( currentQueue_ == dispatch_get_current_queue() );

            if ( !theSameThread_ )
            {
                [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
            }
        };

        loader_( progressCallback_, nil, doneCallback_ );
    }

    [ self prepare ];
    [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1. ];

    GHAssertTrue(initialSchedulerInstancesCount == [JFFBlockOperation instancesCount], @"OK");

    GHAssertTrue( theSameThread_, @"OK" );
    GHAssertTrue( theProgressOk_, @"OK" );
}

-(void)testCancelParalelTask
{
    const NSUInteger initialSchedulerInstancesCount_ = [ JFFBlockOperation instancesCount ];

    __block BOOL theSameThread_ = NO;

    @autoreleasepool
    {
        dispatch_queue_t currentQueue_ = dispatch_get_current_queue();

        JFFSyncOperationWithProgress progressLoadDataBlock_ = ^id( NSError** error_
                                                                  , JFFAsyncOperationProgressHandler progressCallback_ )
        {
            progressCallback_( [ NSNull null ] );
            return [ NSNull null ];
        };
        JFFAsyncOperation loader_ = asyncOperationWithSyncOperationWithProgressBlock( progressLoadDataBlock_ );

        JFFCancelAsyncOperationHandler cancelCallback_ = ^( BOOL canceled_ )
        {
            theSameThread_ = ( currentQueue_ == dispatch_get_current_queue() );

            if ( theSameThread_ && canceled_ )
            {
                [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
            }
            else
            {
                [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
            }
        };

        JFFDidFinishAsyncOperationHandler doneCallback_ = ^( id result_, NSError* error_ )
        {
            [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
        };

        JFFAsyncOperationProgressHandler progressCallback_ = ^( id data_ )
        {
            [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
        };

        asyncOperationWithDelay( 0.1 )( nil, nil, ^( id result_, NSError* error_ )
        {
            loader_( progressCallback_
                    , cancelCallback_
                    , doneCallback_ )( YES );
        } );
    }

    [ self prepare ];
    [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1. ];
    
    GHAssertTrue( initialSchedulerInstancesCount_ == [ JFFBlockOperation instancesCount ], @"OK" );
    
    GHAssertTrue( theSameThread_, @"OK" );
}

@end
