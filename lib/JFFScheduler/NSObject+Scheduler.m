#import "NSObject+Scheduler.h"

#import "JFFScheduler.h"

#import <JFFUtils/NSString/NSString+Search.h>
#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>

#include <objc/message.h>

@implementation NSObject (Scheduler)

- (void)performSelector:(SEL)selector
           timeInterval:(NSTimeInterval)timeInterval
                 leeway:(NSTimeInterval)leeway
               userInfo:(id)userInfo
                repeats:(BOOL)repeats
              scheduler:(JFFScheduler *)scheduler
{
    NSParameterAssert(scheduler);
    
    //use signature's number params
    NSString *selectorString = NSStringFromSelector(selector);
    NSUInteger numOfArgs = [selectorString numberOfCharacterFromString:@":"];
    NSAssert1(numOfArgs == 0 || numOfArgs == 1,
              @"selector \"%@\" should has 0 or 1 parameters",
              selectorString);
    
    __unsafe_unretained id unretainedSelf = self;
    
    JFFScheduledBlock block = ^void(JFFCancelScheduledBlock cancel) {
        if (!repeats) {
            [unretainedSelf removeOnDeallocBlock:cancel];
            cancel();
        }
        
        numOfArgs == 1
        ?objc_msgSend(unretainedSelf, selector, userInfo)
        :objc_msgSend(unretainedSelf, selector);
    };
    
    JFFCancelScheduledBlock cancel = [scheduler addBlock:block
                                                duration:timeInterval
                                                  leeway:leeway];
    [self addOnDeallocBlock:cancel];
}

- (void)performSelector:(SEL)selector
           timeInterval:(NSTimeInterval)timeInterval
                 leeway:(NSTimeInterval)leeway
               userInfo:(id)userInfo
                repeats:(BOOL)repeats
{
    [self performSelector:selector
             timeInterval:timeInterval
                   leeway:leeway
                 userInfo:userInfo
                  repeats:repeats
                scheduler:[JFFScheduler sharedByThreadScheduler]];
}

@end
