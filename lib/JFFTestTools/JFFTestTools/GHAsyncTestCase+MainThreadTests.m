#import "GHAsyncTestCase+MainThreadTests.h"

#import <JFFUtils/NSObject/NSObject+RuntimeExtensions.h>

#import <objc/message.h>

@implementation NSObject (MainThreadTests)

- (void)performAsyncRequestOnMainThreadWithBlock:(TestAsyncRequestBlock)block
                                        selector:(SEL)selector
{
    block = [block copy];
    void (^autoreleaseBlock)() = ^void()
    {
        @autoreleasepool
        {
            void (^didFinishCallback)(void) = ^void()
            {
                objc_msgSend(self,
                             @selector(notify:forSelector:),
                             kGHUnitWaitStatusSuccess,
                             selector);
            };

            block([didFinishCallback copy]);
        }
    };

    objc_msgSend(self, @selector(prepare), nil);

    dispatch_async(dispatch_get_main_queue(), autoreleaseBlock);

    objc_msgSend(self,
                 @selector(waitForStatus:timeout:),
                 kGHUnitWaitStatusSuccess,
                 30000.);
}

+ (void)load
{
    Class class = NSClassFromString(@"GHAsyncTestCase");
    if (class)
    {
        [self addInstanceMethodIfNeedWithSelector:@selector(performAsyncRequestOnMainThreadWithBlock:selector:)
                                          toClass:class];
    }
}

@end
