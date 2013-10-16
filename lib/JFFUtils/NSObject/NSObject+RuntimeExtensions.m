#import "NSObject+RuntimeExtensions.h"

#include <objc/runtime.h>

typedef Method (^JFFMethodGetter)();
typedef Method (^JFFMethodGetterForClass)(Class cls);
typedef Method (^JFFMethodGetterForClassAndSelector)(Class cls, SEL selector);
typedef Class (^JFFClassForClass)(Class cls);
typedef BOOL (^JFFPredicate)();

@implementation NSObject (RuntimeExtensions)

+ (BOOL)addMethodIfNeedWithSelector:(SEL)selector
                            toClass:(Class)class
                  newMethodSelector:(SEL)newSelector
                          hasMethod:(JFFPredicate)hasMethod
                       methodGetter:(JFFMethodGetter)methodGetter
{
    if (hasMethod())
        return NO;
    
    Method prototypeMethod = methodGetter();
    const char* typeEncoding = method_getTypeEncoding(prototypeMethod);
    BOOL result = class_addMethod(class,
                                  newSelector,
                                  method_getImplementation(prototypeMethod),
                                  typeEncoding);
    NSAssert(result, @"method should be added");
    return result;
}

+ (BOOL)addInstanceMethodIfNeedWithSelector:(SEL)selector
                                    toClass:(Class)class
{
    return [self addInstanceMethodIfNeedWithSelector:selector
                                             toClass:class
                                   newMethodSelector:selector];
}

+ (BOOL)addInstanceMethodIfNeedWithSelector:(SEL)selector
                                    toClass:(Class)class
                          newMethodSelector:(SEL)newSelector
{
    JFFPredicate respondToSelector = ^BOOL() {
        return [class hasInstanceMethodWithSelector:newSelector];
    };
    JFFMethodGetter methodGetter = ^Method() {
        return class_getInstanceMethod(self, selector);
    };
    return [self addMethodIfNeedWithSelector:selector
                                     toClass:class
                           newMethodSelector:newSelector
                                   hasMethod:respondToSelector
                                methodGetter:methodGetter];
}

+ (BOOL)addClassMethodIfNeedWithSelector:(SEL)selector
                                 toClass:(Class)class
{
    return [self addClassMethodIfNeedWithSelector:selector
                                          toClass:class
                                newMethodSelector:selector];
}

+ (BOOL)addClassMethodIfNeedWithSelector:(SEL)selector
                                 toClass:(Class)class
                       newMethodSelector:(SEL)newSelector
{
    JFFPredicate respondToSelector = ^BOOL() {
        return [class hasClassMethodWithSelector:newSelector];
    };
    JFFMethodGetter methodGetter = ^Method() {
        return class_getClassMethod(self, selector);
    };
    return [self addMethodIfNeedWithSelector:selector
                                     toClass:object_getClass(class)
                           newMethodSelector:newSelector
                                   hasMethod:respondToSelector
                                methodGetter:methodGetter];
}

+ (void)hookMethodForClass:(Class)class
             classForClass:(JFFClassForClass)classForClass
              withSelector:(SEL)targetSelector
   prototypeMethodSelector:(SEL)prototypeSelector
        hookMethodSelector:(SEL)hookSelector
              methodGetter:(JFFMethodGetterForClassAndSelector)methodGetter
{
    Class targetClass = classForClass(class);
    
    Method targetMethod    = methodGetter(class, targetSelector   );
    Method prototypeMethod = methodGetter(self , prototypeSelector);
    
    NSParameterAssert(targetMethod   );
    NSParameterAssert(prototypeMethod);
    
    const char *typeEncoding = method_getTypeEncoding(prototypeMethod);
//    BOOL methodAdded =
    class_addMethod(targetClass,
                    hookSelector,
                    method_getImplementation(prototypeMethod),
                    typeEncoding);
    //NSAssert(methodAdded, @"should be added");
    Method hookMethod = methodGetter(class, hookSelector);
    
    method_exchangeImplementations(targetMethod, hookMethod);
}

+ (void)hookInstanceMethodForClass:(Class)class
                      withSelector:(SEL)targetSelector
           prototypeMethodSelector:(SEL)prototypeSelector
                hookMethodSelector:(SEL)hookSelector
{
    JFFMethodGetterForClassAndSelector methodGetter = ^Method(Class class, SEL selector) {
        return class_getInstanceMethod(class, selector);
    };
    [self hookMethodForClass:class
               classForClass:^Class(Class class) { return class; }
                withSelector:targetSelector
     prototypeMethodSelector:prototypeSelector
          hookMethodSelector:hookSelector
                methodGetter:methodGetter];
}

+ (void)hookClassMethodForClass:(Class)class
                   withSelector:(SEL)targetSelector
        prototypeMethodSelector:(SEL)prototypeSelector
             hookMethodSelector:(SEL)hookSelector
{
    JFFMethodGetterForClassAndSelector methodGetter = ^Method(Class otherClass, SEL selector) {
        return class_getClassMethod(otherClass, selector);
    };
    [self hookMethodForClass:class
               classForClass:^Class(Class class) { return object_getClass(class); }
                withSelector:targetSelector
     prototypeMethodSelector:prototypeSelector
          hookMethodSelector:hookSelector
                methodGetter:methodGetter];
}

+ (BOOL)hasMethodForMethodGetter:(JFFMethodGetterForClass)methodGetter
{
    Method method = methodGetter([self class]);
    
    if (!method)
        return NO;
    
    //TODO ?
//    if (![self superclass])
//        return NO;
    
    Method superMethod = methodGetter([self superclass]);
    return method != superMethod;
}

+ (BOOL)hasInstanceMethodWithSelector:(SEL)methodSelector
{
    return [self hasMethodForMethodGetter:^Method(Class class) {
        return class_getInstanceMethod(class, methodSelector);
    }];
}

+ (BOOL)hasClassMethodWithSelector:(SEL)methodSelector
{
    return [self hasMethodForMethodGetter:^Method(Class class) {
        return class_getClassMethod(class, methodSelector);
    }];
}

#pragma mark -
#pragma mark Unhook
+ (void)unHookInstanceMethodForClass:(Class)targetClass
                        withSelector:(SEL)targetSelector
             prototypeMethodSelector:(SEL)prototypeSelector
                  hookMethodSelector:(SEL)hookSelector
{
    [ self hookInstanceMethodForClass: targetClass
                         withSelector: targetSelector
              prototypeMethodSelector: hookSelector
                   hookMethodSelector: prototypeSelector ];
}


@end
