#import <Foundation/Foundation.h>

@class JFFTimer;

@interface NSObject (Timer)

//Invokes a method of the receiver on the current thread using the default mode after a delay.
//"receiver" does not retained by this method
//invocation will be canceled at removing "receiver" object from memory
- (void)performSelector:(SEL)selector
           timeInterval:(NSTimeInterval)timeInterval
                 leeway:(NSTimeInterval)leeway
               userInfo:(id)userInfo
                repeats:(BOOL)repeats;

//Invokes a method of the receiver on the current thread using the default mode after a delay.
//"receiver" does not retained by this method
//invocation will be canceled at removing "receiver" or "timer" object from memory
- (void)performSelector:(SEL)selector
           timeInterval:(NSTimeInterval)timeInterval
                 leeway:(NSTimeInterval)leeway
               userInfo:(id)userInfo
                repeats:(BOOL)repeats
                  timer:(JFFTimer *)timer;

@end
