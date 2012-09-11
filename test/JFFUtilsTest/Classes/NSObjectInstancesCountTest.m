@interface TestClassA : NSObject
@end

@implementation TestClassA
@end

@interface TestClassB : TestClassA
@end

@implementation TestClassB
@end

@interface NSObjectInstancesCountTest : GHTestCase
@end

@implementation NSObjectInstancesCountTest

-(void)setUpClass
{
    [TestClassA enableInstancesCounting];
    [TestClassB enableInstancesCounting];
}

-(void)testObjectInstancesCount
{
    {
        TestClassA *a_ = [TestClassA new];
        GHAssertTrue( 1 == [TestClassA instancesCount] && a_, @"We have instances of TestClassA" );
    }
    GHAssertTrue( 0 == [TestClassA instancesCount], @"We have no instances of TestClassA" );
}

-(void)testObjectInstancesCountWithInheritance
{
    {
        id b_ = [TestClassB new];
        GHAssertTrue( 1 == [TestClassB instancesCount] && b_, @"We have instances of TestClassB class" );

        {
            id a_ = [TestClassA new];
            GHAssertTrue( 1 == [TestClassA instancesCount], @"We have instances of TestClassA class" );
            GHAssertTrue( 1 == [TestClassB instancesCount] && a_, @"We have instances of TestClassB class" );
        }

        GHAssertTrue( 0 == [TestClassA instancesCount], @"We have no instances of TestClassA class" );
        GHAssertTrue( 1 == [TestClassB instancesCount], @"We have instances of TestClassB class" );
    }

    GHAssertTrue( 0 == [TestClassA instancesCount], @"We have no instances of TestClassA class" );
    GHAssertTrue( 0 == [TestClassB instancesCount], @"We have no instances of TestClassB class" );
}

@end
