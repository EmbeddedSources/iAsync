
#import <JFFUtils/NSObject/Details/DelegateProxy/JFFProxyDelegatesDispatcher.h>
#import <JFFUtils/NSObject/Details/DelegateProxy/JFFDelegateProxyClassMethods.h>

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

- (NSArray*)classesToTestOnLeaks
{
    return @[
    [TestObjectWithDelegate                         class],
    [TestDelegateObject                             class],
    [TestProxyDelegateObject                        class],
    [TestProxyDelegateShouldNotReceiveMessageObject class],
    [JFFProxyDelegatesDispatcher                    class],
    [JFFDelegateProxyClassMethods                   class],
    ];
}

- (void)setUpClass
{
    for (Class class in [self classesToTestOnLeaks])
    {
        [class enableInstancesCounting];
    }
}

- (void)performBlockWIthMemoryTest:(JFFSimpleBlock)block
{
    NSArray *initialInstancesCouns = [[self classesToTestOnLeaks]map:^id(id object)
    {
        return @([object instancesCount]);
    }];

    @autoreleasepool
    {
        block();
    }

    [[self classesToTestOnLeaks]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        NSNumber *num = [initialInstancesCouns objectAtIndex:idx];
        GHAssertEqualObjects(num, @([obj instancesCount]), @"we got a leak");
    }];
}

- (void)testSetProxyDelegate
{
    [self performBlockWIthMemoryTest:^()
    {
        TestDelegateObject *delegate   = [TestDelegateObject     new];
        TestObjectWithDelegate *object = [TestObjectWithDelegate new];

        TestProxyDelegateObject *proxyDelegate = [TestProxyDelegateObject new];

        //hook object
        [object addDelegateProxy:proxyDelegate
                    delegateName:@"delegate"];

        object.delegate = delegate;

        GHAssertTrue(object.delegate != delegate, @"not the same object");
    }];
}

- (void)testProxyDelegateMessageGot
{
    [self performBlockWIthMemoryTest:^()
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
    }];
}

-(void)testProxyDelegateAfterRemoveFromMemory
{
    [self performBlockWIthMemoryTest:^()
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
    }];
}

-(void)testProxyDelegateAfterRemoveFromObservers
{
    [self performBlockWIthMemoryTest:^()
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
    }];
}

@end
