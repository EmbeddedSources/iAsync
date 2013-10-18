#import "testTools.h"

#include <float.h>

NSTimeInterval performTimeCalculator(JFFSimpleBlock block, NSUInteger times)
{
    NSTimeInterval result = DBL_MAX;
    
    for (NSUInteger index = 0; index < times; ++index) {
        NSDate* startDate = [NSDate new];
        @autoreleasepool {
            block();
        }
        NSDate* endDate = [NSDate new];
        result = fmin(result, [endDate timeIntervalSinceDate:startDate]);
    }
    return result;
}

void performAsyncRequestOnMainThreadWithBlock(void (^block)(JFFSimpleBlock),
                                              NSTimeInterval timeout)
{
    NSCondition *condition = [NSCondition new];
    
    block = [block copy];
    void (^autoreleaseBlock)() = ^void() {
        
        @autoreleasepool {
            
            void (^didFinishCallback)(void) = ^void() {
                
                [condition lock];
                [condition signal];
                [condition unlock];
            };
            
            block([didFinishCallback copy]);
        }
    };
    
    dispatch_async(dispatch_get_main_queue(), autoreleaseBlock);
    
    NSDate *timeoutDate = [[NSDate new] dateByAddingTimeInterval:timeout];
    
    [condition lock];
    [condition waitUntilDate:timeoutDate];
    [condition unlock];
}