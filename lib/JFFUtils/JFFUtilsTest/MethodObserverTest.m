#import "MethodObserverTest.h"

#import "JFFRuntimeAddiotions.h"
#import "NSObject+ObjectMethodHook.h"

#include "JFFMemoryMgmt.h"

#include <objc/runtime.h>

@protocol TestClassToTestHooks <NSObject>

@optional
- (NSString *)returnObjectForIntegerPoint2:(NSRange)point
                                       arg:(NSUInteger)arg;

@end

@interface TestClassToTestHooks : NSObject <TestClassToTestHooks>

@property (nonatomic) NSUInteger state;

@property (nonatomic) CGPoint point;
@property (nonatomic) UIEvent *event;

@end

@implementation TestClassToTestHooks

- (NSString *)returnObjectForIntegerArg:(NSUInteger)arg
                                  point:(NSRange)point
{
    return [@(arg * _state) stringValue];
}

- (NSNumber *)returnObjectForIntegerPoint:(NSRange)point
                                      arg:(NSUInteger)arg
{
    return @(arg * _state);
}

- (NSNumber *)returnObjectForIntegerPoint:(NSRange)point
                                    point:(NSRange)point2
{
    return @(point.length);
}

- (NSString *)returnObjectForArg1:(NSRange)arg1
                             arg2:(CGPoint)arg2
                             arg3:(float)arg3
                             arg4:(double)arg4
{
    return [[NSString alloc] initWithFormat:@"arg1: %@ arg2: %@ arg3: %f arg4: %f",
            NSStringFromRange(arg1),
            NSStringFromCGPoint(arg2),
            arg3,
            arg4
            ];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    _point = point;
    _event = event;
    return YES;
}

@end

//Case table
//case 1 - parent has no method, child has no method
//case 2 - parent has no method, child has    method
//case 3 - parent has    method, child has no method
//case 3 - parent has    method, child has    method

//case a - hook child, case b - hook parent

//case 1_a -  parent has no method, child has no method and hook child
@protocol ParentTestClassCase1_a <NSObject>

@optional
- (NSString *)returnObjectForArg:(NSUInteger)arg;

@end

@interface ParentTestClassCase1_a : NSObject <ParentTestClassCase1_a>
@end

@implementation ParentTestClassCase1_a
@end

@interface ChildTestClassCase1_a : ParentTestClassCase1_a
@end

@implementation ChildTestClassCase1_a
@end

//case 1_b - parent has no method, child has no method and hook parent
@protocol ParentTestClassCase1_b <NSObject>

@optional
- (NSString *)returnObjectForArg:(NSUInteger)arg;

@end

@interface ParentTestClassCase1_b : NSObject <ParentTestClassCase1_a>
@end

@implementation ParentTestClassCase1_b
@end

@interface ChildTestClassCase1_b : ParentTestClassCase1_b
@end

@implementation ChildTestClassCase1_b
@end

//case 2_a - parent has no method, child has method and hook child first
@protocol ParentTestClassCase2_a <NSObject>

@optional
- (NSString *)returnObjectForArg:(NSUInteger)arg;

@end

@interface ParentTestClassCase2_a : NSObject <ParentTestClassCase2_a>
@end

@implementation ParentTestClassCase2_a
@end

@interface ChildTestClassCase2_a : ParentTestClassCase2_a
@end

@implementation ChildTestClassCase2_a

- (NSString *)returnObjectForArg:(NSUInteger)arg
{
    return [@(arg) stringValue];
}

@end

//case 2_b - parent has no method, child has method and hook parent first
@protocol ParentTestClassCase2_b <NSObject>

@optional
- (NSString *)returnObjectForArg:(NSUInteger)arg;

@end

@interface ParentTestClassCase2_b : NSObject <ParentTestClassCase2_b>
@end

@implementation ParentTestClassCase2_b
@end

@interface ChildTestClassCase2_b : ParentTestClassCase2_b
@end

@implementation ChildTestClassCase2_b

- (NSString *)returnObjectForArg:(NSUInteger)arg
{
    return [@(arg) stringValue];
}

@end

//case 3_a - parent has method, child has no method and hook child first
@protocol ParentTestClassCase3_a <NSObject>

@optional
- (NSString *)returnObjectForArg:(NSUInteger)arg;

@end

@interface ParentTestClassCase3_a : NSObject <ParentTestClassCase3_a>
@end

@implementation ParentTestClassCase3_a

- (NSString *)returnObjectForArg:(NSUInteger)arg
{
    return [@(arg) stringValue];
}

@end

@interface ChildTestClassCase3_a : ParentTestClassCase3_a
@end

@implementation ChildTestClassCase3_a
@end

//case 3_b - parent has method, child has no method and hook parent first
@protocol ParentTestClassCase3_b <NSObject>

@optional
- (NSString *)returnObjectForArg:(NSUInteger)arg;

@end

@interface ParentTestClassCase3_b : NSObject <ParentTestClassCase3_b>
@end

@implementation ParentTestClassCase3_b

- (NSString *)returnObjectForArg:(NSUInteger)arg
{
    return [@(arg) stringValue];
}

@end

//case 4_a - parent has method, child has method and hook child first
@protocol ParentTestClassCase4_a <NSObject>

@optional
- (NSString *)returnObjectForArg:(NSUInteger)arg;

@end

@interface ParentTestClassCase4_a : NSObject <ParentTestClassCase4_a>
@end

@implementation ParentTestClassCase4_a

- (NSString *)returnObjectForArg:(NSUInteger)arg
{
    return [@(arg) stringValue];
}

@end

@interface ChildTestClassCase4_a : ParentTestClassCase4_a
@end

@implementation ChildTestClassCase4_a

- (NSString *)returnObjectForArg:(NSUInteger)arg
{
    return [@(arg*2) stringValue];
}

@end

//case 4_b - parent has method, child has method and hook parent first
@protocol ParentTestClassCase4_b <NSObject>

@optional
- (NSString *)returnObjectForArg:(NSUInteger)arg;

@end

@interface ParentTestClassCase4_b : NSObject <ParentTestClassCase4_b>
@end

@implementation ParentTestClassCase4_b

- (NSString *)returnObjectForArg:(NSUInteger)arg
{
    return [@(arg) stringValue];
}

@end

@interface ChildTestClassCase4_b : ParentTestClassCase4_b
@end

@implementation ChildTestClassCase4_b

- (NSString *)returnObjectForArg:(NSUInteger)arg
{
    return [@(arg*2) stringValue];
}

@end

@interface SimpleHookExampleClass : NSObject

@property (nonatomic) NSUInteger state;

@end

@implementation SimpleHookExampleClass

- (NSUInteger)mutStateOnArg:(NSUInteger)arg
{
    return _state * arg;
}

- (void)mutStateOnArgPtr:(NSUInteger *)arg str:(NSString *)str
{
    *arg = _state * *arg;
}

@end

@implementation MethodObserverTest

//test method- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
- (void)testPointInsideWithEventMethod
{
    UIEvent *originalEvent = [UIEvent new];
    CGPoint originalPoint = CGPointMake(2.f, 3.f);
    __block __weak TestClassToTestHooks *weakTestObject;
    
    //test observing existing method
    @autoreleasepool
    {
        __block BOOL hookWasCalled = NO;
        
        typedef BOOL(^BlockObserver)(id _self, CGPoint point, UIEvent *event);
        
        id observer = ^BlockObserver(BlockObserver(^previousImplementationGetter)(void)) {
            
            return ^BOOL(id _self, CGPoint point, UIEvent *event) {
                
                STAssertEqualObjects(NSStringFromCGPoint(originalPoint), NSStringFromCGPoint(point), nil);
                STAssertTrue(originalEvent == event, nil);
                
                hookWasCalled = YES;
                
                BlockObserver previousImplementation = previousImplementationGetter();
                
                BOOL previousResult = previousImplementation(_self, point, event);
                
                STAssertEqualObjects(NSStringFromCGPoint(originalPoint), NSStringFromCGPoint(weakTestObject.point), nil);
                STAssertTrue(originalEvent == weakTestObject.event, nil);
                
                STAssertTrue(previousResult, nil);
                
                return NO;
            };
        };
        
        TestClassToTestHooks *testObject = [TestClassToTestHooks new];
        weakTestObject = testObject;
        
        [testObject addMethodHook:observer
                         selector:@selector(pointInside:withEvent:)];
        
        BOOL result = [testObject pointInside:originalPoint withEvent:originalEvent];
        
        STAssertFalse(result, nil);
        
        STAssertTrue(hookWasCalled, nil);
    }
    
    //test normal call
    {
        @autoreleasepool
        {
            TestClassToTestHooks *testObject = [TestClassToTestHooks new];
            weakTestObject = testObject;
            
            BOOL result = [testObject pointInside:originalPoint withEvent:originalEvent];
            
            STAssertTrue(result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
}

- (void)testVoidReturnTypeCall
{
    //test observing existing method
    {
        __block BOOL hookWasCalled = NO;
        
        typedef void(^BlockObserver)(id _self, NSUInteger *arg, NSString *str);
        
        id observer = ^BlockObserver(BlockObserver(^previousImplementationGetter)(void)) {
            
            return ^void(id _self, NSUInteger *arg, NSString *str) {
                
                hookWasCalled = YES;
                
                BlockObserver previousImplementation = previousImplementationGetter();
                
                previousImplementation(_self, arg, str);
                
                STAssertEquals((NSUInteger)24, *arg, nil);
                STAssertEqualObjects(@"32", str, nil);
                
                *arg = 11;
            };
        };
        
        SimpleHookExampleClass *testObject = [SimpleHookExampleClass new];
        
        testObject.state = 2;
        
        [testObject addMethodHook:observer
                         selector:@selector(mutStateOnArgPtr:str:)];
        
        NSUInteger originalArg = 12;
        
        [testObject mutStateOnArgPtr:&originalArg str:@"32"];
        
        STAssertEquals((NSUInteger)11, originalArg, nil);
        
        STAssertTrue(hookWasCalled, nil);
    }
    
    //test normal call
    {
        NSUInteger originalArg   = 10;
        NSUInteger originalState = 3;
        
        __weak TestClassToTestHooks *weakTestObject;
        @autoreleasepool
        {
            TestClassToTestHooks *testObject = [TestClassToTestHooks new];
            weakTestObject = testObject;
            
            testObject.state = originalState;
            
            id result = [testObject returnObjectForIntegerPoint:NSMakeRange(2, 3) arg:originalArg];
            
            STAssertEqualObjects(@(originalArg * originalState), result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
}

- (void)testSimpleExample
{
    //test observing existing method
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg   = 12;
        NSUInteger originalState = 2;
        
        typedef NSUInteger(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousImplementationGetter)(void)) {
            
            return ^NSUInteger(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousImplementation = previousImplementationGetter();
                
                NSUInteger previousResult = previousImplementation(_self, arg);
                
                STAssertEquals((NSUInteger)24, previousResult, nil);
                
                STAssertEquals((NSUInteger)12, arg, nil);
                return 11;
            };
        };
        
        SimpleHookExampleClass *testObject = [SimpleHookExampleClass new];
        
        testObject.state = originalState;
        
        [testObject addMethodHook:observer
                         selector:@selector(mutStateOnArg:)];
        
        NSUInteger result = [testObject mutStateOnArg:originalArg];
        
        STAssertEquals((NSUInteger)11, result, nil);
        
        STAssertTrue(hookWasCalled, nil);
    }
    
    //test normal call
    {
        NSUInteger originalArg   = 10;
        NSUInteger originalState = 3;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            SimpleHookExampleClass *testObject = [SimpleHookExampleClass new];
            weakTestObject = testObject;
            
            testObject.state = originalState;
            
            NSUInteger result = [testObject mutStateOnArg:originalArg];
            
            STAssertEquals((NSUInteger)30, result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
}

- (void)testSignatures
{
    id block = ^NSObject *(id _self, NSUInteger arg, NSRange point) {
        
        return nil;
    };
    
    const char *methodSinature = method_getTypeEncoding(class_getInstanceMethod([TestClassToTestHooks class], @selector(returnObjectForIntegerArg:point:)));
    const char *blockSinature  = block_getTypeEncoding(block);
    
    NSMethodSignature *methodSig = [NSMethodSignature signatureWithObjCTypes:methodSinature];
    NSMethodSignature *blockSig  = [NSMethodSignature signatureWithObjCTypes:blockSinature ];
    
    STAssertTrue(strcmp(methodSig.methodReturnType, blockSig.methodReturnType) == 0, nil);
    STAssertTrue(methodSig.numberOfArguments == blockSig.numberOfArguments, nil);
    STAssertTrue(methodSig.frameLength == blockSig.frameLength, nil);
    
    for (NSUInteger index = 2; index < methodSig.numberOfArguments; ++index) {
        
        STAssertTrue(strcmp([methodSig getArgumentTypeAtIndex:index], [blockSig getArgumentTypeAtIndex:index]) == 0, @"parameter mismatch");
    }
}

- (void)testDynamicBlockInvocation_DynamicArgumentsOrder
{
    NSRange originalRange1 = NSMakeRange(11, 12);
    NSRange originalRange2 = NSMakeRange(13, 14);
    
    NSObject *(^block)(id _self, NSRange point, NSRange point2) = ^NSObject *(id _self, NSRange point, NSRange point2) {
        
        STAssertEquals(originalRange1.length, point.length, nil);
        STAssertEquals(originalRange1.location, point.location, nil);
        
        STAssertEquals(originalRange2.length, point2.length, nil);
        STAssertEquals(originalRange2.location, point2.location, nil);
        
        //return (__bridge NSObject *)(CFRetain((__bridge_retained CFTypeRef)@3));
        return @"12";
    };
    
    NSObject *(^generalBlock)(id _self, ...) = ^NSObject *(id _self, ...) {
        
        va_list args;
        va_start(args, _self);
        
        NSObject *retValue;
        
        const char *blockSinature = block_getTypeEncoding(block);
        
        invokeMethosBlockWithArgsAndReturnValue(block,
                                                blockSinature,
                                                NULL,
                                                args,
                                                &_self,
                                                &retValue);
        
        va_end(args);
        
        return retValue;
    };
    
    TestClassToTestHooks *obj = [TestClassToTestHooks new];
    
    const char *blockSinature = block_getTypeEncoding(block);
    
    class_replaceMethod([TestClassToTestHooks class],
                        @selector(returnObjectForIntegerPoint:point:),
                        imp_implementationWithBlock(generalBlock),
                        blockSinature);
    
    id result = [obj returnObjectForIntegerPoint:originalRange1 point:originalRange2];
    
    STAssertEqualObjects(@"12", result, nil);
}

//- (NSObject *)returnObjectForIntegerPoint:(NSRange)point
//                                      arg:(NSUInteger)arg
//{
//    return @(arg);
//}

//TODO fix number types

- (void)testHookExistedMethodWithLotOfArgs
{
    //test observing existing method
    __block BOOL hookWasCalled = NO;
    
    NSUInteger originalState = 2;
    
    typedef NSObject *(^BlockObserver)(id _self, NSRange arg1, CGPoint arg2, float arg3, double arg4);
    
    id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
        
        return ^NSObject *(id _self, NSRange arg1, CGPoint arg2, float arg3, double arg4) {
            
            hookWasCalled = YES;
            
            BlockObserver previousBlock = previousBlockGetter();
            
            {
                id previousResult = previousBlock(_self, arg1, arg2, arg3, arg4);
                
                STAssertEqualObjects(@"arg1: {7, 8} arg2: {4.5, 6.7} arg3: 3.200000 arg4: 2.300000", previousResult, nil);
            }
            
            return @"1";
        };
    };
    
    __weak TestClassToTestHooks *weakTestObject;
    @autoreleasepool
    {
        TestClassToTestHooks *testObject = [TestClassToTestHooks new];
        weakTestObject = testObject;
        
        testObject.state = originalState;
        
        [testObject addMethodHook:observer
                         selector:@selector(returnObjectForArg1:arg2:arg3:arg4:)];
        
        id result = [testObject returnObjectForArg1:NSMakeRange(7, 8)
                                               arg2:CGPointMake(4.5, 6.7)
                                               arg3:3.2
                                               arg4:2.3];
        
        STAssertEqualObjects(@"1", result, nil);
    }
    
    STAssertNil(weakTestObject, nil);
    STAssertTrue(hookWasCalled, nil);
}

- (void)testHookExistedMethodWithObjectPointerReturnType
{
    //test observing existing method
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg   = 12;
        NSUInteger originalState = 2;
        
        typedef NSObject *(^BlockObserver)(id _self, NSRange point, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSRange point, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                {
                    id previousResult = previousBlock(_self, point, arg);
                    
                    STAssertEqualObjects(@(originalArg * originalState), previousResult, nil);
                }
                
                STAssertEquals(originalArg, arg, nil);
                return @(originalArg);
            };
        };
        
        __weak TestClassToTestHooks *weakTestObject;
        @autoreleasepool
        {
            TestClassToTestHooks *testObject = [TestClassToTestHooks new];
            weakTestObject = testObject;
            
            testObject.state = originalState;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForIntegerPoint:arg:)];
            
            id result = [testObject returnObjectForIntegerPoint:NSMakeRange(2, 3) arg:originalArg];
            
            STAssertEqualObjects(@(originalArg), result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    }
    //test normal call
    {
        NSUInteger originalArg   = 10;
        NSUInteger originalState = 3;
        
        __weak TestClassToTestHooks *weakTestObject;
        @autoreleasepool
        {
            TestClassToTestHooks *testObject = [TestClassToTestHooks new];
            weakTestObject = testObject;
            
            testObject.state = originalState;
            
            id result = [testObject returnObjectForIntegerPoint:NSMakeRange(2, 3) arg:originalArg];
            
            STAssertEqualObjects(@(originalArg * originalState), result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
}

- (void)testHookNotExistedMethodWithObjectPointerReturnType
{
    //test observing not existing method
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 13;
        
        typedef NSObject *(^BlockObserver)(id _self, NSRange point, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSRange point, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                STAssertNil(previousBlock, @"no original method");
                
                STAssertEquals(originalArg, arg, nil);
                return [@(originalArg) stringValue];
            };
        };
        
        __weak TestClassToTestHooks *weakTestObject;
        @autoreleasepool
        {
            TestClassToTestHooks *testObject = [TestClassToTestHooks new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForIntegerPoint2:arg:)];
            
            id result = [testObject returnObjectForIntegerPoint2:NSMakeRange(2, 3) arg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    }
    
    //test normal call
    {
        NSUInteger originalArg   = 10;
        NSUInteger originalState = 3;
        
        __weak TestClassToTestHooks *weakTestObject;
        @autoreleasepool
        {
            TestClassToTestHooks *testObject = [TestClassToTestHooks new];
            weakTestObject = testObject;
            
            testObject.state = originalState;
            
            //todo fix?
            STAssertTrue([testObject respondsToSelector:@selector(returnObjectForIntegerPoint2:arg:)], nil);
            
            STAssertThrows({
                
                [testObject returnObjectForIntegerPoint2:NSMakeRange(2, 3) arg:originalArg];
            }, nil);
            
            //STAssertEqualObjects([@(originalArg * originalState) stringValue], result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
}

//case 1_a - c - parent has no method, child has no method and hook child
- (void)testCase1_a
{
    //test observing not existing method
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 13;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                STAssertNil(previousBlock, @"no original method");
                
                STAssertEquals(originalArg, arg, nil);
                return [@(originalArg) stringValue];
            };
        };
        
        __weak ChildTestClassCase1_a *weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase1_a *testObject = [ChildTestClassCase1_a new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    }
    
    //test normal call for child
    {
        NSUInteger originalArg = 11;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase1_a *testObject = [ChildTestClassCase1_a new];
            weakTestObject = testObject;
            
            //todo fix?
            STAssertTrue([testObject respondsToSelector:@selector(returnObjectForArg:)], nil);
            
            STAssertThrows({
                
                [testObject returnObjectForArg:originalArg];
            }, nil);
            
            //STAssertEqualObjects([@(originalArg * originalState) stringValue], result, nil);
        }
    }
    
    //test normal call for child
    {
        NSUInteger originalArg = 11;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase1_a *testObject = [ParentTestClassCase1_a new];
            weakTestObject = testObject;
            
            STAssertFalse([testObject respondsToSelector:@selector(returnObjectForArg:)], nil);
            
            STAssertThrows({
                
                [testObject returnObjectForArg:originalArg];
            }, nil);
            
            //STAssertEqualObjects([@(originalArg * originalState) stringValue], result, nil);
        }
    }
}

//case 1_b - c - parent has no method, child has no method and hook parent
- (void)testCase1_b
{
    //test observing not existing method
    JFFSimpleBlock hookTest = ^()
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 13;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                STAssertNil(previousBlock, @"no original method");
                
                STAssertEquals(originalArg, arg, nil);
                return [@(originalArg) stringValue];
            };
        };
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase1_b *testObject = [ParentTestClassCase1_b new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    };
    
    hookTest();
    hookTest();
    
    //test normal call for child
    {
        NSUInteger originalArg = 11;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase1_b *testObject = [ChildTestClassCase1_b new];
            weakTestObject = testObject;
            
            //todo fix?
            STAssertTrue([testObject respondsToSelector:@selector(returnObjectForArg:)], nil);
            
            STAssertThrows({
                
                [testObject returnObjectForArg:originalArg];
            }, nil);
        }
    }
    
    //test normal call for child
    {
        NSUInteger originalArg = 11;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase1_b *testObject = [ParentTestClassCase1_b new];
            weakTestObject = testObject;
            
            //todo fix?
            STAssertTrue([testObject respondsToSelector:@selector(returnObjectForArg:)], nil);
            
            STAssertThrows({
                
                [testObject returnObjectForArg:originalArg];
            }, nil);
        }
    }
}

//case 2_a - parent has no method, child has method and hook child first
- (void)testCase2_a
{
    //test observing existing method
    JFFSimpleBlock firstHookTest = ^()
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 12;
        NSUInteger internalResult = 100;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                {
                    id previousResult = previousBlock(_self, arg);
                    
                    STAssertEqualObjects([@(originalArg) stringValue], previousResult, nil);
                }
                
                STAssertEquals(originalArg, arg, nil);
                return [@(internalResult) stringValue];
            };
        };
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase2_a *testObject = [ChildTestClassCase2_a new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(internalResult) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    };
    firstHookTest();
    
    //test normal call
    {
        NSUInteger originalArg = 10;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase2_a *testObject = [ChildTestClassCase2_a new];
            weakTestObject = testObject;
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
    //test normal call
    {
        NSUInteger originalArg = 10;
        
        __weak ParentTestClassCase2_a *weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase2_a *testObject = [ParentTestClassCase2_a new];
            weakTestObject = testObject;
            
            STAssertThrows({
                
                [testObject returnObjectForArg:originalArg];
            }, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
    
    //hook parent
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 13;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                STAssertNil(previousBlock, nil);
                
                STAssertEquals(originalArg, arg, nil);
                return [@(arg) stringValue];
            };
        };
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase2_a *testObject = [ParentTestClassCase2_a new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    }
    
    firstHookTest();
}

//case 2_b - parent has no method, child has method and hook parent first
- (void)testCase2_b
{
    //test observing existing method
    JFFSimpleBlock firstHookTest = ^()
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 12;
        NSUInteger internalResult = 100;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                STAssertNil(previousBlock, nil);
                
                STAssertEquals(originalArg, arg, nil);
                return [@(internalResult) stringValue];
            };
        };
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase2_a *testObject = [ParentTestClassCase2_a new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(internalResult) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    };
    firstHookTest();
    
    //test normal call
    {
        NSUInteger originalArg = 10;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase2_a *testObject = [ChildTestClassCase2_a new];
            weakTestObject = testObject;
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
    //test normal call
    {
        NSUInteger originalArg = 10;
        
        __weak ParentTestClassCase2_a *weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase2_a *testObject = [ParentTestClassCase2_a new];
            weakTestObject = testObject;
            
            STAssertThrows({
                
                [testObject returnObjectForArg:originalArg];
            }, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
    
    //hook child
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 13;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                {
                    id previousResult = previousBlock(_self, arg);
                    
                    STAssertEqualObjects([@(originalArg) stringValue], previousResult, nil);
                }
                
                STAssertEquals(originalArg, arg, nil);
                return [@(arg) stringValue];
            };
        };
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase2_a *testObject = [ChildTestClassCase2_a new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    }
    
    firstHookTest();
}

//case 3_a - parent has method, child has no method and hook child first
- (void)testCase3_a
{
    //test observing existing method
    JFFSimpleBlock firstHookTest = ^()
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 12;
        NSUInteger internalResult = 100;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                {
                    id previousResult = previousBlock(_self, arg);
                    
                    STAssertEqualObjects([@(originalArg) stringValue], previousResult, nil);
                }
                
                STAssertEquals(originalArg, arg, nil);
                return [@(internalResult) stringValue];
            };
        };
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase3_a *testObject = [ChildTestClassCase3_a new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(internalResult) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    };
    firstHookTest();
    
    //test normal call
    {
        NSUInteger originalArg = 11;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase3_a *testObject = [ChildTestClassCase3_a new];
            weakTestObject = testObject;
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
    //test normal call
    {
        NSUInteger originalArg = 10;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase3_a *testObject = [ParentTestClassCase3_a new];
            weakTestObject = testObject;
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
    
    //hook parent
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 13;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                {
                    id previousResult = previousBlock(_self, arg);
                    
                    STAssertEqualObjects([@(originalArg) stringValue], previousResult, nil);
                }
                
                STAssertEquals(originalArg, arg, nil);
                return [@(arg) stringValue];
            };
        };
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase3_a *testObject = [ParentTestClassCase3_a new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    }
    
    firstHookTest();
}

//case 3_b - parent has method, child has no method and hook parent first
- (void)testCase3_b
{
    //test observing existing method
    JFFSimpleBlock firstHookTest = ^()
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 12;
        NSUInteger internalResult = 100;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                {
                    id previousResult = previousBlock(_self, arg);
                    
                    STAssertEqualObjects([@(originalArg) stringValue], previousResult, nil);
                }
                
                STAssertEquals(originalArg, arg, nil);
                return [@(internalResult) stringValue];
            };
        };
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase3_a *testObject = [ParentTestClassCase3_a new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(internalResult) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    };
    firstHookTest();
    
    //test normal call
    {
        NSUInteger originalArg = 11;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase3_a *testObject = [ChildTestClassCase3_a new];
            weakTestObject = testObject;
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
    //test normal call
    {
        NSUInteger originalArg = 10;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase3_a *testObject = [ParentTestClassCase3_a new];
            weakTestObject = testObject;
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
    
    //hook parent
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 13;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                {
                    id previousResult = previousBlock(_self, arg);
                    
                    STAssertEqualObjects([@(originalArg) stringValue], previousResult, nil);
                }
                
                STAssertEquals(originalArg, arg, nil);
                return [@(arg) stringValue];
            };
        };
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase3_a *testObject = [ChildTestClassCase3_a new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    }
    
    firstHookTest();
}

//case 4_a - parent has method, child has method and hook child first
- (void)testCase4_a
{
    //test observing existing method
    JFFSimpleBlock firstHookTest = ^()
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 12;
        NSUInteger internalResult = 100;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                {
                    id previousResult = previousBlock(_self, arg);
                    
                    STAssertEqualObjects([@(originalArg * 2) stringValue], previousResult, nil);
                }
                
                STAssertEquals(originalArg, arg, nil);
                return [@(internalResult) stringValue];
            };
        };
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase4_a *testObject = [ChildTestClassCase4_a new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(internalResult) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    };
    firstHookTest();
    
    //test normal call
    {
        NSUInteger originalArg = 11;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase4_a *testObject = [ChildTestClassCase4_a new];
            weakTestObject = testObject;
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg * 2) stringValue], result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
    //test normal call
    {
        NSUInteger originalArg = 10;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase4_a *testObject = [ParentTestClassCase4_a new];
            weakTestObject = testObject;
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
    
    //hook child
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 13;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                {
                    id previousResult = previousBlock(_self, arg);
                    
                    STAssertEqualObjects([@(originalArg) stringValue], previousResult, nil);
                }
                
                STAssertEquals(originalArg, arg, nil);
                return [@(arg) stringValue];
            };
        };
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase4_a *testObject = [ParentTestClassCase4_a new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    }
    
    firstHookTest();
}

//case 4_b - parent has method, child has method and hook parent first
- (void)testCase4_b
{
    //test observing existing method
    JFFSimpleBlock firstHookTest = ^()
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 12;
        NSUInteger internalResult = 100;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                {
                    id previousResult = previousBlock(_self, arg);
                    
                    STAssertEqualObjects([@(originalArg) stringValue], previousResult, nil);
                }
                
                STAssertEquals(originalArg, arg, nil);
                return [@(internalResult) stringValue];
            };
        };
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase4_a *testObject = [ParentTestClassCase4_a new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(internalResult) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    };
    firstHookTest();
    
    //test normal call
    {
        NSUInteger originalArg = 11;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase4_a *testObject = [ChildTestClassCase4_a new];
            weakTestObject = testObject;
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg * 2) stringValue], result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
    //test normal call
    {
        NSUInteger originalArg = 10;
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase4_a *testObject = [ParentTestClassCase4_a new];
            weakTestObject = testObject;
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        STAssertNil(weakTestObject, nil);
    }
    
    //hook child
    {
        __block BOOL hookWasCalled = NO;
        
        NSUInteger originalArg = 13;
        
        typedef NSObject *(^BlockObserver)(id _self, NSUInteger arg);
        
        id observer = ^BlockObserver(BlockObserver(^previousBlockGetter)(void)) {
            
            return ^NSObject *(id _self, NSUInteger arg) {
                
                hookWasCalled = YES;
                
                BlockObserver previousBlock = previousBlockGetter();
                
                {
                    id previousResult = previousBlock(_self, arg);
                    
                    STAssertEqualObjects([@(originalArg * 2) stringValue], previousResult, nil);
                }
                
                STAssertEquals(originalArg, arg, nil);
                return [@(arg) stringValue];
            };
        };
        
        __weak id weakTestObject;
        @autoreleasepool
        {
            ChildTestClassCase4_a *testObject = [ChildTestClassCase4_a new];
            weakTestObject = testObject;
            
            [testObject addMethodHook:observer
                             selector:@selector(returnObjectForArg:)];
            
            id result = [testObject returnObjectForArg:originalArg];
            
            STAssertEqualObjects([@(originalArg) stringValue], result, nil);
        }
        
        STAssertNil(weakTestObject, nil);
        STAssertTrue(hookWasCalled, nil);
    }
    
    firstHookTest();
}

@end
