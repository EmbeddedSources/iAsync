#import "NSObjectRuntimeExtensionsTest.h"

#include <objc/message.h>

static const NSUInteger testClassMethodResult    = 34;//just rendomize number
static const NSUInteger testInstanceMethodResult = 35;//just rendomize number

typedef NSUInteger (*UIntPropertyGetterMsgSendFunction)( id, SEL );
static const UIntPropertyGetterMsgSendFunction FPropertyGetter = (UIntPropertyGetterMsgSendFunction)objc_msgSend;


@interface NSTestClass : NSObject
@end

@implementation NSTestClass

+ (id)allocWithZone:(NSZone *)zone
{
    return [super allocWithZone:zone];
}

- (BOOL)isEqual:(id)object
{
    return [super isEqual:object];
}

+ (NSUInteger)classMethodWithLongNameForUniquenessPurposes
{
    return testClassMethodResult;
}

- (NSUInteger)instanceMethodWithLongNameForUniquenessPurposes
{
    return testInstanceMethodResult;
}

@end

@interface NSTwiceTestClass : NSObject
@end

@implementation NSTwiceTestClass

+ (id)allocWithZone:(NSZone *)zone
{
    return [super allocWithZone:zone];
}

- (BOOL)isEqual:(id)object
{
    return [super isEqual:object];
}

+ (NSUInteger)classMethodWithLongNameForUniquenessPurposes
{
    return testClassMethodResult;
}

- (NSUInteger)instanceMethodWithLongNameForUniquenessPurposes
{
    return testInstanceMethodResult;
}

@end

@interface HookMethodsClass : NSObject
@end

@implementation HookMethodsClass

- (NSUInteger)hookMethod
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (NSUInteger)prototypeMethod
{
    return [self hookMethod] * 2;
}

+ (NSUInteger)hookMethod
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

+ (NSUInteger)prototypeMethod
{
    return [self hookMethod] * 3;
}

@end

@interface TwiceHookMethodsClass : NSObject
@end

@implementation TwiceHookMethodsClass

- (NSUInteger)twiceHookMethod
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (NSUInteger)twicePrototypeMethod
{
    return [self twiceHookMethod] * 2;
}

+ (NSUInteger)twiceHookMethod
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

+ (NSUInteger)twicePrototypeMethod
{
    return [self twiceHookMethod] * 3;
}

@end

@implementation NSObjectRuntimeExtensionsTest

- (void)testHookInstanceMethodAssertPrototypeAndTargetSelectors
{
    XCTAssertThrows({
        [[HookMethodsClass class] hookInstanceMethodForClass:[NSTestClass class]
                                                 withSelector:@selector(instanceMethodWithLongNameForUniquenessPurposes)
                                      prototypeMethodSelector:@selector(instanceMethodWithLongNameForUniquenessPurposes)
                                           hookMethodSelector:@selector(hookMethod)];
    }, @"no prototypeMethodSelector asert expected" );
    
    XCTAssertThrows({
        [[HookMethodsClass class] hookInstanceMethodForClass:[NSTestClass class]
                                                withSelector:@selector(instanceMethodWithLongNameForUniquenessPurposes2)
                                     prototypeMethodSelector:@selector(prototypeMethod)
                                          hookMethodSelector:@selector(hookMethod)];
    }, @"no target selector asert expected" );
}

- (void)testHookInstanceMethod
{
    static BOOL firstTestRun = YES;
    
    if (!firstTestRun)
        return;
    
    NSTestClass *instance_ = [NSTestClass new];
    
    XCTAssertEqual(testInstanceMethodResult,
                   [instance_ instanceMethodWithLongNameForUniquenessPurposes],
                   @"result mismatch");
    
    [[HookMethodsClass class] hookInstanceMethodForClass:[NSTestClass class]
                                            withSelector:@selector(instanceMethodWithLongNameForUniquenessPurposes)
                                 prototypeMethodSelector:@selector(prototypeMethod)
                                      hookMethodSelector:@selector(hookMethod)];
    
    XCTAssertEqual( testInstanceMethodResult * 2
                   , [ instance_ instanceMethodWithLongNameForUniquenessPurposes ]
                   , @"result mismatch" );
}

-(void)testHookClassMethodAssertPrototypeAndTargetSelectors
{
    XCTAssertThrows({
        [[HookMethodsClass class] hookClassMethodForClass:[NSTestClass class]
                                             withSelector:@selector(classMethodWithLongNameForUniquenessPurposes)
                                  prototypeMethodSelector:@selector(classMethodWithLongNameForUniquenessPurposes)
                                       hookMethodSelector:@selector(hookMethod)];
    }, @"no prototypeMethodSelector asert expected" );
    
    XCTAssertThrows({
        [[HookMethodsClass class] hookClassMethodForClass:[NSTestClass class]
                                             withSelector:@selector(classMethodWithLongNameForUniquenessPurposes2)
                                  prototypeMethodSelector:@selector(prototypeMethod)
                                       hookMethodSelector:@selector(hookMethod)];
    }, @"no target selector asert expected" );
}

- (void)testHookClassMethod
{
    static BOOL firstTestRun = YES;
    
    if (!firstTestRun)
        return;
    
    Class class = [NSTestClass class];
    
    XCTAssertEqual(testClassMethodResult,
                   [class classMethodWithLongNameForUniquenessPurposes],
                   @"result mismatch" );
    
    [[HookMethodsClass class] hookClassMethodForClass:[NSTestClass class]
                                         withSelector:@selector(classMethodWithLongNameForUniquenessPurposes)
                              prototypeMethodSelector:@selector(prototypeMethod)
                                   hookMethodSelector:@selector(hookMethod)];
    
    XCTAssertEqual( testClassMethodResult * 3
                   , [ class classMethodWithLongNameForUniquenessPurposes ]
                   , @"result mismatch" );
}

- (void)testHasClassMethodWithSelector
{
    XCTAssertTrue([NSObject hasClassMethodWithSelector:@selector(allocWithZone:)], @"NSOBject has allocWithZone: method");
    XCTAssertFalse([NSObject hasClassMethodWithSelector:@selector(allocWithZone2:)], @"NSOBject has no allocWithZone2: method");
    
    XCTAssertTrue([NSTestClass hasClassMethodWithSelector:@selector(allocWithZone:)],
                 @"NSTestClass has allocWithZone: method" );
    XCTAssertFalse( [ NSTestClass hasClassMethodWithSelector: @selector( alloc ) ]
                  , @"NSTestClass has no alloc method" );
}

- (void)testHasInstanceMethodWithSelector
{
    XCTAssertTrue([NSObject hasInstanceMethodWithSelector:@selector(isEqual:)], @"NSOBject has isEqual: method");
    XCTAssertFalse([NSObject hasInstanceMethodWithSelector:@selector(isEqual2:)], @"NSOBject has no isEqual2: method");
    
    XCTAssertTrue([NSTestClass hasInstanceMethodWithSelector:@selector(isEqual:)],
                 @"NSTestClass has isEqual: method");
    XCTAssertFalse([NSTestClass hasInstanceMethodWithSelector:@selector(description)],
                  @"NSTestClass has no description method" );
}

- (void)testAddClassMethodIfNeedWithSelector
{
    static BOOL firstTestRun = YES;
    
    if (firstTestRun) {
        
        BOOL result = [NSTestClass addClassMethodIfNeedWithSelector:@selector(classMethodWithLongNameForUniquenessPurposes)
                                                            toClass:[NSTestClass class]
                                                  newMethodSelector:@selector(classMethodWithLongNameForUniquenessPurposes2)];
        

        XCTAssertTrue(result, @"method added");

        

        XCTAssertTrue( [ NSTestClass hasClassMethodWithSelector: @selector( classMethodWithLongNameForUniquenessPurposes2 ) ]
                     , @"NSTestClass has classMethodWithLongNameForUniquenessPurposes2 method" );

        
        NSUInteger method_result_ = FPropertyGetter(
            [ NSTestClass class ], @selector( classMethodWithLongNameForUniquenessPurposes2 ) );
        
        XCTAssertTrue( testClassMethodResult == method_result_, @"check implementation of new method" );
        
        firstTestRun = NO;
    }
}

-(void)testAddInstanceMethodIfNeedWithSelector
{
    static BOOL firstTestRun = YES;
    
    if (firstTestRun) {
        
        SEL newMethodSelector = @selector(instanceMethodWithLongNameForUniquenessPurposes2);
        SEL selector = @selector(instanceMethodWithLongNameForUniquenessPurposes);
        BOOL result = [NSTestClass addInstanceMethodIfNeedWithSelector:selector
                                                               toClass:[NSTestClass class]
                                                     newMethodSelector:newMethodSelector];
        
        XCTAssertTrue(result, @"method added");
        

        XCTAssertTrue([NSTestClass hasInstanceMethodWithSelector:newMethodSelector],
                     @"NSTestClass has instanceMethodWithLongNameForUniquenessPurposes2 method");

        NSTestClass* instance_ = [ NSTestClass new ];
        
        NSUInteger method_result_ = FPropertyGetter( instance_, newMethodSelector );
        XCTAssertTrue( testInstanceMethodResult == method_result_, @"check implementation of new method" );
        
        firstTestRun = NO;
    }
}

-(void)testTwiceHookInstanceMethod
{
    static BOOL firstTestRun = YES;
    
    if (!firstTestRun)
    {
        return;
    }
    
    NSTwiceTestClass *instance = [ NSTwiceTestClass new ];
    
    XCTAssertEqual(testInstanceMethodResult,
                   [instance instanceMethodWithLongNameForUniquenessPurposes],
                   @"result mismatch" );
    
    [[TwiceHookMethodsClass class] hookInstanceMethodForClass:[NSTwiceTestClass class]
                                                 withSelector:@selector(instanceMethodWithLongNameForUniquenessPurposes)
                                      prototypeMethodSelector:@selector(twicePrototypeMethod)
                                           hookMethodSelector:@selector(twiceHookMethod)];
    
    XCTAssertEqual(testInstanceMethodResult * 2,
                   [instance instanceMethodWithLongNameForUniquenessPurposes],
                   @"result mismatch");
    
    XCTAssertThrows( {
        [[TwiceHookMethodsClass class] hookInstanceMethodForClass:[NSTwiceTestClass class]
                                                     withSelector:@selector(instanceMethodWithLongNameForUniquenessPurposes)
                                          prototypeMethodSelector:@selector(twicePrototypeMethod)
                                               hookMethodSelector:@selector(twiceHookMethod)];
    }, @"twice hook forbidden" );
}

-(void)testTwiceHookClassMethod
{
    static BOOL firstTestRun = YES;
    
    if (!firstTestRun)
        return;
    
    Class class = [NSTwiceTestClass class];
    
    XCTAssertEqual(testClassMethodResult,
                   [class classMethodWithLongNameForUniquenessPurposes],
                   @"result mismatch");
    
    [[TwiceHookMethodsClass class] hookClassMethodForClass:[NSTwiceTestClass class]
                                              withSelector:@selector(classMethodWithLongNameForUniquenessPurposes)
                                   prototypeMethodSelector:@selector(twicePrototypeMethod)
                                        hookMethodSelector:@selector(twiceHookMethod)];
    
    XCTAssertEqual(testClassMethodResult * 3,
                   [class classMethodWithLongNameForUniquenessPurposes],
                   @"result mismatch" );
    
    XCTAssertThrows({
        [[TwiceHookMethodsClass class]hookClassMethodForClass:[NSTwiceTestClass class]
                                                 withSelector:@selector(classMethodWithLongNameForUniquenessPurposes)
                                      prototypeMethodSelector:@selector(twicePrototypeMethod)
                                           hookMethodSelector:@selector(twiceHookMethod) ];
    }, @"twice hook forbidden" );
}

@end
