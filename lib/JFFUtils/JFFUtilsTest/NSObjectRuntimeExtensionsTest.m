#import "NSObjectRuntimeExtensionsTest.h"

#include <objc/message.h>

static const NSUInteger testClassMethodResult    = 34;//just rendomize number
static const NSUInteger testInstanceMethodResult = 35;//just rendomize number

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
    STAssertThrows({
        [[HookMethodsClass class] hookInstanceMethodForClass:[NSTestClass class]
                                                 withSelector:@selector(instanceMethodWithLongNameForUniquenessPurposes)
                                      prototypeMethodSelector:@selector(instanceMethodWithLongNameForUniquenessPurposes)
                                           hookMethodSelector:@selector(hookMethod)];
    }, @"no prototypeMethodSelector asert expected" );
    
    STAssertThrows({
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
    
    STAssertEquals(testInstanceMethodResult,
                   [instance_ instanceMethodWithLongNameForUniquenessPurposes],
                   @"result mismatch");
    
    [[HookMethodsClass class] hookInstanceMethodForClass:[NSTestClass class]
                                            withSelector:@selector(instanceMethodWithLongNameForUniquenessPurposes)
                                 prototypeMethodSelector:@selector(prototypeMethod)
                                      hookMethodSelector:@selector(hookMethod)];
    
    STAssertEquals( testInstanceMethodResult * 2
                   , [ instance_ instanceMethodWithLongNameForUniquenessPurposes ]
                   , @"result mismatch" );
}

-(void)testHookClassMethodAssertPrototypeAndTargetSelectors
{
    STAssertThrows({
        [[HookMethodsClass class] hookClassMethodForClass:[NSTestClass class]
                                             withSelector:@selector(classMethodWithLongNameForUniquenessPurposes)
                                  prototypeMethodSelector:@selector(classMethodWithLongNameForUniquenessPurposes)
                                       hookMethodSelector:@selector(hookMethod)];
    }, @"no prototypeMethodSelector asert expected" );
    
    STAssertThrows({
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
    
    STAssertEquals(testClassMethodResult,
                   [class classMethodWithLongNameForUniquenessPurposes],
                   @"result mismatch" );
    
    [[HookMethodsClass class] hookClassMethodForClass:[NSTestClass class]
                                         withSelector:@selector(classMethodWithLongNameForUniquenessPurposes)
                              prototypeMethodSelector:@selector(prototypeMethod)
                                   hookMethodSelector:@selector(hookMethod)];
    
    STAssertEquals( testClassMethodResult * 3
                   , [ class classMethodWithLongNameForUniquenessPurposes ]
                   , @"result mismatch" );
}

- (void)testHasClassMethodWithSelector
{
    STAssertTrue([NSObject hasClassMethodWithSelector:@selector(allocWithZone:)], @"NSOBject has allocWithZone: method");
    STAssertFalse([NSObject hasClassMethodWithSelector:@selector(allocWithZone2:)], @"NSOBject has no allocWithZone2: method");
    
    STAssertTrue([NSTestClass hasClassMethodWithSelector:@selector(allocWithZone:)],
                 @"NSTestClass has allocWithZone: method" );
    STAssertFalse( [ NSTestClass hasClassMethodWithSelector: @selector( alloc ) ]
                  , @"NSTestClass has no alloc method" );
}

- (void)testHasInstanceMethodWithSelector
{
    STAssertTrue([NSObject hasInstanceMethodWithSelector:@selector(isEqual:)], @"NSOBject has isEqual: method");
    STAssertFalse([NSObject hasInstanceMethodWithSelector:@selector(isEqual2:)], @"NSOBject has no isEqual2: method");
    
    STAssertTrue([NSTestClass hasInstanceMethodWithSelector:@selector(isEqual:)],
                 @"NSTestClass has isEqual: method");
    STAssertFalse([NSTestClass hasInstanceMethodWithSelector:@selector(description)],
                  @"NSTestClass has no description method" );
}

- (void)testAddClassMethodIfNeedWithSelector
{
    static BOOL firstTestRun = YES;
    
    if (firstTestRun) {
        
        BOOL result = [NSTestClass addClassMethodIfNeedWithSelector:@selector(classMethodWithLongNameForUniquenessPurposes)
                                                            toClass:[NSTestClass class]
                                                  newMethodSelector:@selector(classMethodWithLongNameForUniquenessPurposes2)];
        
        STAssertTrue(result, @"method added");
        
        STAssertTrue([NSTestClass hasClassMethodWithSelector:@selector(classMethodWithLongNameForUniquenessPurposes2)],
                     @"NSTestClass has classMethodWithLongNameForUniquenessPurposes2 method");
        
        NSUInteger methodResult = (NSUInteger)objc_msgSend([NSTestClass class], @selector(classMethodWithLongNameForUniquenessPurposes2));
        STAssertTrue(testClassMethodResult == methodResult, @"check implementation of new method");
        
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
        
        STAssertTrue(result, @"method added");
        
        STAssertTrue([NSTestClass hasInstanceMethodWithSelector:newMethodSelector],
                     @"NSTestClass has instanceMethodWithLongNameForUniquenessPurposes2 method");
        
        NSTestClass *instance = [NSTestClass new];
        NSUInteger methodResult = (NSUInteger)objc_msgSend(instance, newMethodSelector);
        STAssertTrue(testInstanceMethodResult == methodResult, @"check implementation of new method" );
        
        firstTestRun = NO;
    }
}

-(void)testTwiceHookInstanceMethod
{
    static BOOL firstTestRun = YES;
    
    if (!firstTestRun)
        return;
    
    NSTwiceTestClass *instance = [ NSTwiceTestClass new ];
    
    STAssertEquals(testInstanceMethodResult,
                   [instance instanceMethodWithLongNameForUniquenessPurposes],
                   @"result mismatch" );
    
    [[TwiceHookMethodsClass class] hookInstanceMethodForClass:[NSTwiceTestClass class]
                                                 withSelector:@selector(instanceMethodWithLongNameForUniquenessPurposes)
                                      prototypeMethodSelector:@selector(twicePrototypeMethod)
                                           hookMethodSelector:@selector(twiceHookMethod)];
    
    STAssertEquals(testInstanceMethodResult * 2,
                   [instance instanceMethodWithLongNameForUniquenessPurposes],
                   @"result mismatch");
    
    STAssertThrows( {
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
    
    STAssertEquals(testClassMethodResult,
                   [class classMethodWithLongNameForUniquenessPurposes],
                   @"result mismatch");
    
    [[TwiceHookMethodsClass class] hookClassMethodForClass:[NSTwiceTestClass class]
                                              withSelector:@selector(classMethodWithLongNameForUniquenessPurposes)
                                   prototypeMethodSelector:@selector(twicePrototypeMethod)
                                        hookMethodSelector:@selector(twiceHookMethod)];
    
    STAssertEquals(testClassMethodResult * 3,
                   [class classMethodWithLongNameForUniquenessPurposes],
                   @"result mismatch" );
    
    STAssertThrows({
        [[TwiceHookMethodsClass class]hookClassMethodForClass:[NSTwiceTestClass class]
                                                 withSelector:@selector(classMethodWithLongNameForUniquenessPurposes)
                                      prototypeMethodSelector:@selector(twicePrototypeMethod)
                                           hookMethodSelector:@selector(twiceHookMethod) ];
    }, @"twice hook forbidden" );
}

@end
