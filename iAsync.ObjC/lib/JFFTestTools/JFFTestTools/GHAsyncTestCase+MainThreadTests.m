#import "GHAsyncTestCase+MainThreadTests.h"

#import <JFFUtils/NSObject/NSObject+RuntimeExtensions.h>

#import <objc/message.h>

@implementation NSObject (MainThreadTests)

- (void)performAsyncRequestOnMainThreadWithBlock:(TestAsyncRequestBlock)block
                                        selector:(SEL)selector
{
    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:selector
                                           timeout:30000.];
}

- (void)waitForeverForAsyncRequestOnMainThreadWithBlock:(void (^)(JFFSimpleBlock))block
                                               selector:(SEL)selector
{
    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:selector
                                           timeout:INFINITY];
}

- (void)performAsyncRequestOnMainThreadWithBlock:(void (^)(JFFSimpleBlock))block
                                        selector:(SEL)selector
                                         timeout:(NSTimeInterval)timeout
{
    block = [block copy];
    void (^autoreleaseBlock)() = ^void() {
        
        @autoreleasepool {
            
            void (^didFinishCallback)(void) = ^void() {
                
                typedef void (*AlignMsgSendFunction)(id, SEL, NSInteger, SEL);
                AlignMsgSendFunction alignFunction = (AlignMsgSendFunction)objc_msgSend;
                alignFunction(self, @selector(notify:forSelector:), kGHUnitWaitStatusSuccess, selector);
            };
            
            block([didFinishCallback copy]);
        }
    };
    
    {
        typedef void (*AlignMsgSendFunction)(id, SEL);
        AlignMsgSendFunction alignFunction = (AlignMsgSendFunction)objc_msgSend;
        alignFunction(self, @selector(prepare));
    }
    
    dispatch_async(dispatch_get_main_queue(), autoreleaseBlock);
    
    typedef void (*AlignMsgSendFunction)(id, SEL, NSInteger, NSTimeInterval);
    AlignMsgSendFunction alignFunction = (AlignMsgSendFunction)objc_msgSend;
    alignFunction(self, @selector(waitForStatus:timeout:), kGHUnitWaitStatusSuccess, timeout);
}

+ (void)load
{
    Class class = NSClassFromString(@"GHAsyncTestCase");
    if (class) {
        [self addInstanceMethodIfNeedWithSelector:@selector(performAsyncRequestOnMainThreadWithBlock:selector:)
                                          toClass:class];
    }
}

@end
