#import "GHAsyncTestCase+MainThreadTests.h"

@implementation GHAsyncTestCase (MainThreadTests)

-(void)performAsyncRequestOnMainThreadWithBlock:( TestAsyncRequestBlock )block_
                                       selector:( SEL )selector_
{
    block_ = [ block_ copy ];
    void (^autoreleaseBlock_)() = ^void()
    {
        @autoreleasepool
        {
            void (^didFinishCallback_)(void) = ^void()
            {
                [ self notify: kGHUnitWaitStatusSuccess forSelector: selector_ ];
            };

            block_( [ didFinishCallback_ copy ] );
        }
    };

    [ self prepare ];

    dispatch_async( dispatch_get_main_queue(), autoreleaseBlock_ );

    [ self waitForStatus: kGHUnitWaitStatusSuccess
                 timeout: 30000. ];
}

@end
