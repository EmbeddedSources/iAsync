#import "NSObjectInstancesCountTest.h"

@interface TestClassA : NSObject
@end

@implementation TestClassA
@end

@interface TestClassB : TestClassA
@end

@implementation TestClassB
@end

@implementation NSObjectInstancesCountTest

- (void)setUp
{
    [TestClassA enableInstancesCounting];
    [TestClassB enableInstancesCounting];
}

- (void)testObjectInstancesCount
{
    NSUInteger initialInsancesCount = [TestClassA instancesCount];
    @autoreleasepool
    {
        TestClassA *a = [TestClassA new];
        STAssertTrue(1 == [TestClassA instancesCount] && a, @"We have instances of TestClassA");
    }
    STAssertTrue(initialInsancesCount == [TestClassA instancesCount], @"We have no instances of TestClassA" );
}

- (void)testObjectInstancesCountWithInheritance
{
    NSUInteger initialInsancesCountA = [TestClassA instancesCount];
    NSUInteger initialInsancesCountB = [TestClassB instancesCount];
    @autoreleasepool
    {
        id b = [TestClassB new];
        STAssertTrue(1 == [TestClassB instancesCount] && b, @"We have instances of TestClassB class");
        
        @autoreleasepool
        {
            id a = [TestClassA new];
            STAssertTrue(1 == [TestClassA instancesCount], @"We have instances of TestClassA class");
            STAssertTrue(1 == [TestClassB instancesCount] && a, @"We have instances of TestClassB class");
        }
        
        STAssertTrue(0 == [TestClassA instancesCount], @"We have no instances of TestClassA class");
        STAssertTrue(1 == [TestClassB instancesCount], @"We have instances of TestClassB class");
    }
    
    STAssertTrue(initialInsancesCountA == [TestClassA instancesCount], @"We have no instances of TestClassA class");
    STAssertTrue(initialInsancesCountB == [TestClassB instancesCount], @"We have no instances of TestClassB class");
}

@end
