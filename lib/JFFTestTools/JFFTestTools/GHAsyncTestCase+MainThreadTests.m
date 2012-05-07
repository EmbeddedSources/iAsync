#import "GHAsyncTestCase+MainThreadTests.h"

#import <JFFUtils/NSObject/NSObject+RuntimeExtensions.h>

#import <objc/message.h>

@implementation NSObject (MainThreadTests)

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
                 , 30000. );
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
