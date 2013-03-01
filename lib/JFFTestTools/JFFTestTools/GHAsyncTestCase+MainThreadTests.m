#import "GHAsyncTestCase+MainThreadTests.h"

#import <JFFUtils/NSObject/NSObject+RuntimeExtensions.h>

#import <objc/message.h>

@implementation NSObject (MainThreadTests)

- (void)performAsyncRequestOnMainThreadWithBlock:(TestAsyncRequestBlock)block
                                        selector:(SEL)selector
{
    [ self performAsyncRequestOnMainThreadWithBlock: block_
                                           selector: selector_
                                            timeout: 30000. ];
}

-(void)waitForeverForAsyncRequestOnMainThreadWithBlock:( void (^)(JFFSimpleBlock) )block_
                                              selector:( SEL )selector_
{
    [ self performAsyncRequestOnMainThreadWithBlock: block_
                                           selector: selector_
                                            timeout: INFINITY ];
}

-(void)performAsyncRequestOnMainThreadWithBlock:( void (^)(JFFSimpleBlock) )block_
                                       selector:( SEL )selector_
                                        timeout:( NSTimeInterval )timeout_;
{
    block_ = [ block_ copy ];
    void (^autoreleaseBlock_)() = ^void()
    {
        @autoreleasepool
        {
            void (^didFinishCallback_)(void) = ^void()
            {
                objc_msgSend( self
                             , @selector( notify:forSelector: )
                             , kGHUnitWaitStatusSuccess
                             , selector_ );
            };
            
            block_( [ didFinishCallback_ copy ] );
        }
    };
    
    objc_msgSend( self, @selector( prepare ), nil );
    
    dispatch_async( dispatch_get_main_queue(), autoreleaseBlock_ );
    
    objc_msgSend( self
                 , @selector( waitForStatus:timeout: )
                 , kGHUnitWaitStatusSuccess
                 , timeout_ );
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
