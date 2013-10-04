#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>
#import <Foundation/Foundation.h>

typedef void (^TestAsyncRequestBlock)(JFFSimpleBlock);

//GHAsyncTestCase category
@interface NSObject (MainThreadTests)

- (void)performAsyncRequestOnMainThreadWithBlock:(void(^)(JFFSimpleBlock))block
                                        selector:(SEL)selector;

- (void)waitForeverForAsyncRequestOnMainThreadWithBlock:(void (^)(JFFSimpleBlock))block
                                               selector:(SEL)selector;

- (void)performAsyncRequestOnMainThreadWithBlock:(void (^)(JFFSimpleBlock))block
                                        selector:(SEL)selector
                                         timeout:(NSTimeInterval)timeout;

@end
