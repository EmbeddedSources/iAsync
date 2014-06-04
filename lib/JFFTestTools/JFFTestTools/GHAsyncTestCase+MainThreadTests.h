#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>
#import <Foundation/Foundation.h>

typedef void (^TestAsyncRequestBlock)(JFFSimpleBlock);

//GHAsyncTestCase category
@interface NSObject (MainThreadTests)

- (void)performAsyncRequestOnMainThreadWithBlock:(TestAsyncRequestBlock)block
                                        selector:(SEL)selector;

- (void)waitForeverForAsyncRequestOnMainThreadWithBlock:(TestAsyncRequestBlock)block
                                               selector:(SEL)selector;

- (void)performAsyncRequestOnMainThreadWithBlock:(TestAsyncRequestBlock)block
                                        selector:(SEL)selector
                                         timeout:(NSTimeInterval)timeout;

@end
