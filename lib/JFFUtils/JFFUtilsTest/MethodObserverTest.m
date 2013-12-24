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
    NSString* result =
     [[NSString alloc] initWithFormat:@"arg1: %@ arg2: {%.1f, %.1f} arg3: %1f arg4: %1f",
            NSStringFromRange(arg1),
            arg2.x, arg2.y,
            arg3,
            arg4
            ];

    return result;
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
                
                XCTAssertEqualObjects(NSStringFromCGPoint(originalPoint), NSStringFromCGPoint(point), @"points mismatch");
                XCTAssertTrue(originalEvent == event, @"pointer mismatch" );
                
                hookWasCalled = YES;
                
                BlockObserver previousImplementation = previousImplementationGetter();
                
                BOOL previousResult = previousImplementation(_self, point, event);
                
                XCTAssertEqualObjects(NSStringFromCGPoint(originalPoint), NSStringFromCGPoint(weakTestObject.point), @"points mismatch");
                XCTAssertTrue(originalEvent == weakTestObject.event, @"pointer mismatch");
                
                XCTAssertTrue(previousResult, @"previousResult mismatch");
                
                return NO;
            };
        };
        
        TestClassToTestHooks *testObject = [TestClassToTestHooks new];
        weakTestObject = testObject;
        
        [testObject addMethodHook:observer
                         selector:@selector(pointInside:withEvent:)];
        
        BOOL result = [testObject pointInside:originalPoint withEvent:originalEvent];
        
        XCTAssertFalse(result, @"point must be outside" );
        
        XCTAssertTrue(hookWasCalled, @"hook call missed" );
    }
    
    //test normal call
    {
        @autoreleasepool
        {
            TestClassToTestHooks *testObject = [TestClassToTestHooks new];
            weakTestObject = testObject;
            
            BOOL result = [testObject pointInside:originalPoint withEvent:originalEvent];
            
            XCTAssertTrue(result, @"point inside musmatch");
        }
        XCTAssertNil(weakTestObject, @"memory management issue");
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
                
                XCTAssertEqual((NSUInteger)24, *arg, @"unexpected arg");
                XCTAssertEqualObjects(@"32", str, @"unexpected arg");
                
                *arg = 11;
            };
        };
        
        SimpleHookExampleClass *testObject = [SimpleHookExampleClass new];
        
        testObject.state = 2;
        
        [testObject addMethodHook:observer
                         selector:@selector(mutStateOnArgPtr:str:)];
        
        NSUInteger originalArg = 12;
        
        [testObject mutStateOnArgPtr:&originalArg str:@"32"];
        
        XCTAssertEqual((NSUInteger)11, originalArg, @"unexpected arg");
        
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
            
            XCTAssertEqualObjects(@(originalArg * originalState), result, @"unexpected arg");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
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
                
                XCTAssertEqual((NSUInteger)24, previousResult, @"unexpected arg");
                
                XCTAssertEqual((NSUInteger)12, arg, @"unexpected arg");
                return 11;
            };
        };
        
        SimpleHookExampleClass *testObject = [SimpleHookExampleClass new];
        
        testObject.state = originalState;
        
        [testObject addMethodHook:observer
                         selector:@selector(mutStateOnArg:)];
        
        NSUInteger result = [testObject mutStateOnArg:originalArg];
        
        XCTAssertEqual((NSUInteger)11, result, @"unexpected arg");
        
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
            
            XCTAssertEqual((NSUInteger)30, result, @"unexpected arg");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
    }
}

- (void)testSignatures
{
    id block = ^id(id _self, NSUInteger arg, NSRange point) {
        
        return nil;
    };
    
    const char *methodSinature = method_getTypeEncoding(class_getInstanceMethod([TestClassToTestHooks class], @selector(returnObjectForIntegerArg:point:)));
    const char *blockSinature  = block_getTypeEncoding(block);
    
    NSMethodSignature *methodSig = [NSMethodSignature signatureWithObjCTypes:methodSinature];
    NSMethodSignature *blockSig  = [NSMethodSignature signatureWithObjCTypes:blockSinature ];
    
    XCTAssertTrue(strcmp(methodSig.methodReturnType, blockSig.methodReturnType) == 0, @"methodReturnType mismatch");
    XCTAssertTrue(methodSig.numberOfArguments == blockSig.numberOfArguments, @"numberOfArguments mismatch");
    XCTAssertTrue(methodSig.frameLength == blockSig.frameLength, @"frameLength mismatch");
    
    for (NSUInteger index = 2; index < methodSig.numberOfArguments; ++index) {
        
        XCTAssertTrue(strcmp([methodSig getArgumentTypeAtIndex:index], [blockSig getArgumentTypeAtIndex:index]) == 0, @"parameter mismatch");
    }
}

- (void)testDynamicBlockInvocation_DynamicArgumentsOrder
{
    NSRange originalRange1 = NSMakeRange(11, 12);
    NSRange originalRange2 = NSMakeRange(13, 14);
    
    NSObject *(^block)(id _self, NSRange point, NSRange point2) = ^NSObject *(id _self, NSRange point, NSRange point2) {
        
        XCTAssertEqual(originalRange1.length, point.length, @"length mismatch");
        XCTAssertEqual(originalRange1.location, point.location, @"location mismatch");
        
        XCTAssertEqual(originalRange2.length, point2.length, @"length mismatch");
        XCTAssertEqual(originalRange2.location, point2.location, @"location mismatch");
        
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
    
    XCTAssertEqualObjects(@"12", result, @"unexpected arg");
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
                
                XCTAssertEqualObjects(@"arg1: {7, 8} arg2: {4.5, 6.7} arg3: 3.200000 arg4: 2.300000", previousResult, @"unexpected format");
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
        
        XCTAssertEqualObjects(@"1", result, @"bad result");
    }
    
    XCTAssertNil(weakTestObject, @"memory leak");
    XCTAssertTrue(hookWasCalled, @"hook call missed");
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
                    
                    XCTAssertEqualObjects(@(originalArg * originalState), previousResult, @"unexpected arg");
                }
                
                XCTAssertEqual(originalArg, arg, @"unexpected arg");
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
            
            XCTAssertEqualObjects(@(originalArg), result, @"unexpected arg");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
            
            XCTAssertEqualObjects(@(originalArg * originalState), result, @"unexpected arg");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
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
                
                XCTAssertNil(previousBlock, @"no original method");
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg" );
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
            XCTAssertTrue([testObject respondsToSelector:@selector(returnObjectForIntegerPoint2:arg:)], @"method missing");
            
            XCTAssertThrows({
                
                [testObject returnObjectForIntegerPoint2:NSMakeRange(2, 3) arg:originalArg];
            }, @"method missing");
            
            //XCTAssertEqualObjects([@(originalArg * originalState) stringValue], result, nil);
        }
        XCTAssertNil(weakTestObject, @"memory leak");
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
                
                XCTAssertNil(previousBlock, @"no original method");
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
            XCTAssertTrue([testObject respondsToSelector:@selector(returnObjectForArg:)], @"method missing");
            
            XCTAssertThrows({
                
                [testObject returnObjectForArg:originalArg];
            }, @"unexpected arg");
            
            //XCTAssertEqualObjects([@(originalArg * originalState) stringValue], result, nil);
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
            
            XCTAssertFalse([testObject respondsToSelector:@selector(returnObjectForArg:)], @"method missing");
            
            XCTAssertThrows({
                
                [testObject returnObjectForArg:originalArg];
            }, @"unexpected arg");
            
            //XCTAssertEqualObjects([@(originalArg * originalState) stringValue], result, nil);
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
                
                XCTAssertNil(previousBlock, @"no original method");
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
            XCTAssertTrue([testObject respondsToSelector:@selector(returnObjectForArg:)], @"missing method");
            
            XCTAssertThrows({
                
                [testObject returnObjectForArg:originalArg];
            }, @"assert expected");
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
            XCTAssertTrue([testObject respondsToSelector:@selector(returnObjectForArg:)], @"missing method");
            
            XCTAssertThrows({
                
                [testObject returnObjectForArg:originalArg];
            }, @"assert expected");
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
                    
                    XCTAssertEqualObjects([@(originalArg) stringValue], previousResult, @"arg mismatch");
                }
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(internalResult) stringValue], result, @"arg mismatch");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
    }
    //test normal call
    {
        NSUInteger originalArg = 10;
        
        __weak ParentTestClassCase2_a *weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase2_a *testObject = [ParentTestClassCase2_a new];
            weakTestObject = testObject;
            
            XCTAssertThrows({
                
                [testObject returnObjectForArg:originalArg];
            }, @"assert expected");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
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
                XCTAssertNil(previousBlock, @"previous block missing");
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
                XCTAssertNil(previousBlock, @"previous block missing");
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(internalResult) stringValue], result, @"arg mismatch");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
    }
    //test normal call
    {
        NSUInteger originalArg = 10;
        
        __weak ParentTestClassCase2_a *weakTestObject;
        @autoreleasepool
        {
            ParentTestClassCase2_a *testObject = [ParentTestClassCase2_a new];
            weakTestObject = testObject;
            
            XCTAssertThrows({
                
                [testObject returnObjectForArg:originalArg];
            }, @"assert expected");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
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
                    
                    XCTAssertEqualObjects([@(originalArg) stringValue], previousResult, @"arg mismatch");
                }
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
                    
                    XCTAssertEqualObjects([@(originalArg) stringValue], previousResult, @"arg mismatch");
                }
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(internalResult) stringValue], result, @"arg mismatch");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
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
                    
                    XCTAssertEqualObjects([@(originalArg) stringValue], previousResult, @"arg mismatch");
                }
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
                    
                    XCTAssertEqualObjects([@(originalArg) stringValue], previousResult, @"arg mismatch");
                }
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(internalResult) stringValue], result, @"arg mismatch");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
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
                    
                    XCTAssertEqualObjects([@(originalArg) stringValue], previousResult, @"arg mismatch");
                }
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
                    
                    XCTAssertEqualObjects([@(originalArg * 2) stringValue], previousResult, @"arg mismatch");
                }
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(internalResult) stringValue], result, @"arg mismatch");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
            
            XCTAssertEqualObjects([@(originalArg * 2) stringValue], result, @"arg mismatch");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
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
                    
                    XCTAssertEqualObjects([@(originalArg) stringValue], previousResult, @"arg mismatch");
                }
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
                    
                    XCTAssertEqualObjects([@(originalArg) stringValue], previousResult, @"arg mismatch");
                }
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(internalResult) stringValue], result, @"arg mismatch");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
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
            
            XCTAssertEqualObjects([@(originalArg * 2) stringValue], result, @"arg mismatch");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        XCTAssertNil(weakTestObject, @"memory leak");
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
                    
                    XCTAssertEqualObjects([@(originalArg * 2) stringValue], previousResult, @"arg mismatch");
                }
                
                XCTAssertEqual(originalArg, arg, @"arg mismatch");
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
            
            XCTAssertEqualObjects([@(originalArg) stringValue], result, @"unexpected arg");
        }
        
        XCTAssertNil(weakTestObject, @"memory leak");
        XCTAssertTrue(hookWasCalled, @"hook call missed");
    }
    
    firstHookTest();
}

@end
