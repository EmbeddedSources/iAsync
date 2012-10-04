#import <Foundation/Foundation.h>

@class JFFScheduler;

@interface NSObject (Scheduler)

//Invokes a method of the receiver on the current thread using the default mode after a delay.
//"receiver" does not retained by this method
//invocation will be canceled at removing "receiver" object from memory
- (void)performSelector:(SEL)selector
           timeInterval:(NSTimeInterval)timeInterval
               userInfo:(id)userInfo
                repeats:(BOOL)repeats;

//Invokes a method of the receiver on the current thread using the default mode after a delay.
//"receiver" does not retained by this method
//invocation will be canceled at removing "receiver" or "scheduler" object from memory
- (void)performSelector:(SEL)selector
           timeInterval:(NSTimeInterval)timeInterval
               userInfo:(id)userInfo
                repeats:(BOOL)repeats
              scheduler:(JFFScheduler *)scheduler;

@end
