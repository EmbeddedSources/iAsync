
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

-(void)testSetProxyDelegate
{
    TestDelegateObject *delegate = [TestDelegateObject new];
    TestObjectWithDelegate *object = [TestObjectWithDelegate new];

    TestProxyDelegateObject *proxyDelegate = [TestProxyDelegateObject new];

    //hook object
    [object setDelegateProxy:proxyDelegate
                delegateName:@"delegate"];

    object.delegate = delegate;

    GHAssertTrue(object.delegate == delegate, @"not the same object");
}

@end
