#import "GHAsyncTestCase+MainThreadTests.h"

#import <JFFUtils/NSObject/NSObject+RuntimeExtensions.h>

#import <objc/message.h>

typedef void (*PrepareMsgSendFunction)( id, SEL, SEL );
typedef void (*NotifyForSelectorMsgSendFunction)( id, SEL, NSInteger, SEL );
typedef void (*WaitForStatusTimeoutMsgSendFunction)( id, SEL, NSInteger, NSTimeInterval );

static const PrepareMsgSendFunction PrepareFunction = (PrepareMsgSendFunction)objc_msgSend;
static const NotifyForSelectorMsgSendFunction NotifyFunction = (NotifyForSelectorMsgSendFunction)objc_msgSend;
static const WaitForStatusTimeoutMsgSendFunction WaitForStatusFunction = (WaitForStatusTimeoutMsgSendFunction)objc_msgSend;

@implementation NSObject (MainThreadTests)

-(void)performAsyncRequestOnMainThreadWithBlock:( TestAsyncRequestBlock )block_
                                       selector:( SEL )selector_
{
    [ self performAsyncRequestOnMainThreadWithBlock: block_
                                           selector: selector_
                                            timeout: 30000. ];
}

-(void)waitForeverForAsyncRequestOnMainThreadWithBlock:( TestAsyncRequestBlock )block_
                                              selector:( SEL )selector_
{
    [ self performAsyncRequestOnMainThreadWithBlock: block_
                                           selector: selector_
                                            timeout: INFINITY ];
}

-(void)performAsyncRequestOnMainThreadWithBlock:( TestAsyncRequestBlock )block_
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
                NotifyFunction( self
                             , @selector( notify:forSelector: )
                             , kGHUnitWaitStatusSuccess
                             , selector_ );
            };

            block_( [ didFinishCallback_ copy ] );
        }
    };

    PrepareFunction( self, @selector( prepare: ), selector_ );

    dispatch_async( dispatch_get_main_queue(), autoreleaseBlock_ );

    WaitForStatusFunction( self
                 , @selector( waitForStatus:timeout: )
                 , kGHUnitWaitStatusSuccess
                 , timeout_ );
}

+(void)load
{
    Class class_ = NSClassFromString( @"GHAsyncTestCase" );
    if ( class_ )
    {
        [ self addInstanceMethodIfNeedWithSelector: @selector( performAsyncRequestOnMainThreadWithBlock:selector: )
                                           toClass: class_ ];
    }
}

@end