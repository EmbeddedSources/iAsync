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
    {
        TestClassA *a = [TestClassA new];
        STAssertTrue(1 == [TestClassA instancesCount] && a, @"We have instances of TestClassA");
    }
    STAssertTrue(0 == [TestClassA instancesCount], @"We have no instances of TestClassA" );
}

- (void)testObjectInstancesCountWithInheritance
{
    {
        id b = [TestClassB new];
        STAssertTrue( 1 == [ TestClassB instancesCount ] && b, @"We have instances of TestClassB class" );
        
        {
            id a = [TestClassA new];
            STAssertTrue(1 == [TestClassA instancesCount], @"We have instances of TestClassA class");
            STAssertTrue(1 == [TestClassB instancesCount] && a, @"We have instances of TestClassB class");
        }
        
        STAssertTrue(0 == [TestClassA instancesCount], @"We have no instances of TestClassA class");
        STAssertTrue(1 == [TestClassB instancesCount], @"We have instances of TestClassB class");
    }
    
    STAssertTrue(0 == [TestClassA instancesCount], @"We have no instances of TestClassA class");
    STAssertTrue(0 == [TestClassB instancesCount], @"We have no instances of TestClassB class");
}

@end
