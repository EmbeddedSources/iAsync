
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

@property (nonatomic) id methodCallArgument;

@end

@implementation TestDelegateObject

-(void)someDelegateMethod:(id)object
{
    self->_methodCallArgument = object;
}

@end

////////////////////////////////////////////////

@interface TestProxyDelegateObject : NSObject <TestDelegateProtocol>

@property (nonatomic) id methodCallArgument;

@end

@implementation TestProxyDelegateObject

-(void)someDelegateMethod:(id)object
{
    self->_methodCallArgument = object;
}

@end

////////////////////////////////////////////////

@interface TestProxyDelegateShouldNotReceiveMessageObject : NSObject <TestDelegateProtocol>
@end

@implementation TestProxyDelegateShouldNotReceiveMessageObject

-(void)someDelegateMethod:(id)object
{
    [self doesNotRecognizeSelector:_cmd];
}

@end

////////////////////////////////////////////////

@interface DelegateProxyTest : GHTestCase
@end

@implementation DelegateProxyTest

-(void)testSetProxyDelegate
{
    TestDelegateObject *delegate   = [TestDelegateObject new];
    TestObjectWithDelegate *object = [TestObjectWithDelegate new];

    TestProxyDelegateObject *proxyDelegate = [TestProxyDelegateObject new];

    //hook object
    [object addDelegateProxy:proxyDelegate
                delegateName:@"delegate"];

    object.delegate = delegate;

    GHAssertTrue(object.delegate != delegate, @"not the same object");
}

-(void)testProxyDelegateMessageGot
{
    TestDelegateObject *delegate   = [TestDelegateObject new];
    TestObjectWithDelegate *object = [TestObjectWithDelegate new];

    TestProxyDelegateObject *proxyDelegate1 = [TestProxyDelegateObject new];
    TestProxyDelegateObject *proxyDelegate2 = [TestProxyDelegateObject new];

    //hook object
    [object addDelegateProxy:proxyDelegate1
                delegateName:@"delegate"];
    
    [object addDelegateProxy:proxyDelegate2
                delegateName:@"delegate"];

    object.delegate = delegate;

    id sentObject = [NSNull null];
    [object.delegate someDelegateMethod:[NSNull null]];

    GHAssertTrue(delegate.methodCallArgument == sentObject, @"method was called");
    GHAssertTrue(proxyDelegate1.methodCallArgument == sentObject, @"method was called");
    GHAssertTrue(proxyDelegate2.methodCallArgument == sentObject, @"method was called");
}

-(void)testProxyDelegateAfterRemoveFromMemory
{
    TestDelegateObject *delegate   = [TestDelegateObject new];
    TestObjectWithDelegate *object = [TestObjectWithDelegate new];

    @autoreleasepool
    {
        TestProxyDelegateShouldNotReceiveMessageObject *proxyDelegate = [TestProxyDelegateShouldNotReceiveMessageObject new];

        //hook object
        [object addDelegateProxy:proxyDelegate
                    delegateName:@"delegate"];
    }

    object.delegate = delegate;

    id sentObject = [NSNull null];
    [object.delegate someDelegateMethod:[NSNull null]];

    GHAssertTrue(delegate.methodCallArgument == sentObject, @"method was called");
}

-(void)testProxyDelegateAfterRemoveFromObservers
{
    TestDelegateObject *delegate   = [TestDelegateObject new];
    TestObjectWithDelegate *object = [TestObjectWithDelegate new];

    TestProxyDelegateShouldNotReceiveMessageObject *proxyDelegate = [TestProxyDelegateShouldNotReceiveMessageObject new];

    [object addDelegateProxy:proxyDelegate
                delegateName:@"delegate"];

    object.delegate = delegate;

    [object removeDelegateProxy:proxyDelegate
                   delegateName:@"delegate"];

    id sentObject = [NSNull null];
    [object.delegate someDelegateMethod:[NSNull null]];

    GHAssertTrue(delegate.methodCallArgument == sentObject, @"method was called");
}

@end
