#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>
#import <Foundation/Foundation.h>

typedef void (^TestAsyncRequestBlock)(JFFSimpleBlock);

//GHAsyncTestCase category
@interface NSObject (MainThreadTests)

- (void)performAsyncRequestOnMainThreadWithBlock:(TestAsyncRequestBlock)block
                                        selector:(SEL)selector;

-(void)waitForeverForAsyncRequestOnMainThreadWithBlock:( TestAsyncRequestBlock )block_
                                              selector:( SEL )selector_;

-(void)performAsyncRequestOnMainThreadWithBlock:( TestAsyncRequestBlock )block_
                                       selector:( SEL )selector_
                                        timeout:( NSTimeInterval )timeout_;

@end
