
@protocol TestDelegateProtocol <NSObject>

@optional
-(void)someDelegateMethod:( id )object;

@end

////////////////////////////////////////////////

@interface TestObjectWithDelegate : NSObject

@property (nonatomic, weak) id<TestDelegateProtocol> delegate;

@end

@implementation TestObjectWithDelegate
@end

////////////////////////////////////////////////

@interface TestDelegateObject : NSObject <TestDelegateProtocol>
@end

@implementation TestDelegateObject
@end

////////////////////////////////////////////////

@interface TestProxyDelegateObject : NSObject <TestDelegateProtocol>
@end

@implementation TestProxyDelegateObject
@end

////////////////////////////////////////////////

@interface DelegateProxyTest : GHTestCase
@end

@implementation DelegateProxyTest

-(void)testDelegateSetAndGetTheSameObject
{
    TestDelegateObject *delegate = [TestDelegateObject new];
    TestObjectWithDelegate *object = [TestObjectWithDelegate new];

    //hook object
    [object addDelegateProxy:[TestProxyDelegateObject new]
                delegateName:@"delegate"];

    object.delegate = delegate;

    GHAssertTrue(object.delegate == delegate, @"not the same object");
}

@end
