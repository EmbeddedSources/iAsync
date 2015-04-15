
#import <JFFScheduler/JFFTimer.h>
#import <JFFScheduler/NSObject+Timer.h>

#import <JFFTestTools/JFFTestTools.h>

@interface JFFObjectToTestTimer : NSObject

@property (nonatomic) NSDate *targetMethodDateCalling;
@property (nonatomic) GHAsyncTestCase *asyncTestCase;
@property (nonatomic) id targetMethodWithFinishTestWithArgument;
@property (nonatomic) NSUInteger repeatCount;

@end

@implementation JFFObjectToTestTimer

- (void)targetMethodWithFinishTest
{
    _targetMethodDateCalling = [NSDate new];
    [_asyncTestCase notify:kGHUnitWaitStatusSuccess];
}

- (void)targetMethodWithFinishTestWithArgument:(id)argument
{
    _targetMethodWithFinishTestWithArgument = argument;
    _targetMethodDateCalling = [NSDate new];
    [_asyncTestCase notify:kGHUnitWaitStatusSuccess];
}

- (void)targetRepeatMethod
{
    if (_repeatCount == 0)
        return;
    
    _repeatCount = _repeatCount - 1;
    
    if (_repeatCount == 0)
        [_asyncTestCase notify:kGHUnitWaitStatusSuccess];
}

- (void)someShouldNeverBeCalledMethod
{
}

@end

@interface PerformSelectorTest : GHAsyncTestCase
@end

@implementation PerformSelectorTest

- (void)testCallSelectorWithoutArgument
{
    JFFObjectToTestTimer *targetObject = [JFFObjectToTestTimer new];
    targetObject.asyncTestCase = self;
    
    NSDate *startDate = [NSDate new];
    
    [targetObject performSelector:@selector(targetMethodWithFinishTest)
                     timeInterval:0.001
                           leeway:0.0001
                         userInfo:nil
                          repeats:NO];
    
    NSTimeInterval timeout = 0.1;
    
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:timeout];
    
    GHAssertNotNil(targetObject.targetMethodDateCalling, nil);
    
    GHAssertEquals(NSOrderedAscending,
                   [targetObject.targetMethodDateCalling compare:[startDate dateByAddingTimeInterval:timeout]],
                   nil);
}

- (void)testCallSelectorWithArgument
{
    JFFObjectToTestTimer *targetObject = [JFFObjectToTestTimer new];
    targetObject.asyncTestCase = self;
    
    NSDate *startDate = [NSDate new];
    
    id argument = [NSObject new];
    
    [targetObject performSelector:@selector(targetMethodWithFinishTestWithArgument:)
                     timeInterval:0.001
                           leeway:0.0001
                         userInfo:argument
                          repeats:NO];
    
    NSTimeInterval timeout = 0.1;
    
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:timeout];
    
    GHAssertNotNil(targetObject.targetMethodDateCalling, nil);
    
    GHAssertEquals(NSOrderedAscending,
                   [targetObject.targetMethodDateCalling compare:[startDate dateByAddingTimeInterval:timeout]],
                   nil);
    GHAssertTrue(argument == targetObject.targetMethodWithFinishTestWithArgument,
                 nil);
}

- (void)testRepeatCallSelector
{
    JFFObjectToTestTimer *targetObject = [JFFObjectToTestTimer new];
    targetObject.asyncTestCase = self;
    targetObject.repeatCount = 2;
    
    [targetObject performSelector:@selector(targetRepeatMethod)
                     timeInterval:0.001
                           leeway:0.0001
                         userInfo:nil
                          repeats:YES];
    
    NSTimeInterval timeout = 0.1;
    
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:timeout*2];
    
    GHAssertTrue(targetObject.targetMethodDateCalling == 0, nil);
}

- (void)testStopSchedulerWhenDeallocTarget
{
    @autoreleasepool {
        JFFObjectToTestTimer *targetObject = [JFFObjectToTestTimer new];
        
        [targetObject performSelector:@selector(someShouldNeverBeCalledMethod)
                         timeInterval:0.001
                               leeway:0.0001
                             userInfo:nil
                              repeats:NO];
    }
    
    NSTimeInterval timeout = 0.1;
    
    [self prepare];
    
    [[JFFTimer sharedByThreadTimer] addBlock:^(JFFCancelScheduledBlock cancel) {
        [self notify:kGHUnitWaitStatusSuccess];
    } duration:0.01];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:timeout];
}

- (void)testStopSchedulerWhenDeallocScheduler
{
    JFFObjectToTestTimer *targetObject = [JFFObjectToTestTimer new];
    @autoreleasepool {
        JFFTimer *timer = [JFFTimer new];
        [targetObject performSelector:@selector(someShouldNeverBeCalledMethod)
                         timeInterval:0.001
                               leeway:0.0001
                             userInfo:nil
                              repeats:NO
                                timer:timer];
    }
    
    NSTimeInterval timeout = 0.1;
    
    [self prepare];
    
    [[JFFTimer sharedByThreadTimer] addBlock:^(JFFCancelScheduledBlock cancel) {
        [self notify:kGHUnitWaitStatusSuccess];
    } duration:0.01];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:timeout];
}

@end
