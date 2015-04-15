#import "NSObject+ObjectMethodHook.h"

#include "JFFRuntimeAddiotions.h"

#include <utility>

#include <objc/runtime.h>

static char ownershipsKey;

@interface NSObject (ObjectMethodHook_Private)

- (NSMutableArray *)lazyObserversBlocksForSelectorName:(NSString *)selectorName;

@end

static void callBlockWithInvocation(NSInvocation *invocation, id block)
{
    [invocation invokeWithTarget:block];
}

static id lastBlockObserver(id _self, SEL selector)
{
    NSString *selectorStr = NSStringFromSelector(selector);
    NSMutableArray *methodObservers = [_self lazyObserversBlocksForSelectorName:selectorStr];
    return [methodObservers lastObject];
}

inline static BOOL isVoidReturnType(NSMethodSignature *sig)
{
    return *sig.methodReturnType == @encode(void)[0];
}

static SEL originalMethodHolderSelector(SEL selectorToHook)
{
    SEL result = NULL;
    
    NSString *oroginalMethodHolderStr = NSStringFromSelector(selectorToHook);
    oroginalMethodHolderStr = [[NSString alloc] initWithFormat:@"originalMethodHolder_%@", oroginalMethodHolderStr];
    result = NSSelectorFromString(oroginalMethodHolderStr);
    
    return result;
}

static void self_invokeMethosBlockWithArgsAndReturnValue(id targetObjectOrBlock,
                                                         const char *signature,
                                                         SEL selectorOrNullForBlock,
                                                         va_list args,
                                                         id *selfArgumentPtr,
                                                         void *returnValuePtr,
                                                         SEL originalSelector)
{
    BOOL isBlockCall = selectorOrNullForBlock == NULL;
    
    if (isBlockCall && !targetObjectOrBlock) {
        
        SEL originalMethodHolder = originalMethodHolderSelector(originalSelector);
        
        //TODO check exectly for self class, no for parent class
        Method hookHolderMethod = class_getInstanceMethod([*selfArgumentPtr class], originalMethodHolder);
        
        if (hookHolderMethod != NULL) {
            
            invokeMethosBlockWithArgsAndReturnValue(*selfArgumentPtr,
                                                    method_getTypeEncoding(hookHolderMethod),
                                                    originalMethodHolder,
                                                    args,
                                                    selfArgumentPtr,
                                                    returnValuePtr);
            return;
        }
        
        [*selfArgumentPtr doesNotRecognizeSelector:originalMethodHolder];
        return;
    }
    
    invokeMethosBlockWithArgsAndReturnValue(targetObjectOrBlock,
                                            signature,
                                            selectorOrNullForBlock,
                                            args,
                                            selfArgumentPtr,
                                            returnValuePtr);
}

template <typename T>
id generalHookBlock(const char *methodReturnType,
                    SEL originalSelector,
                    id(^targetGetter)(id _self, const char**, SEL*)
                    )
{
    if (strcmp(@encode(T), methodReturnType) != 0)
        return nil;
    
    targetGetter = [targetGetter copy];
    
    return ^T(id _self, ...) {
        
        const char *signature = NULL;
        SEL selector = NULL;
        id target = targetGetter(_self, &signature, &selector);
        
        va_list args;
        va_start(args, _self);
        
        T retValue;
        
        self_invokeMethosBlockWithArgsAndReturnValue(target,
                                                     signature,
                                                     selector,
                                                     args,
                                                     &_self,
                                                     &retValue,
                                                     originalSelector);
        
        va_end(args);
        
        return retValue;
    };
}

template <>
id generalHookBlock<void>(const char *methodReturnType,
                          SEL originalSelector,
                          id(^targetGetter)(id _self, const char**, SEL*)
                          )
{
    if (strcmp(@encode(void), methodReturnType) != 0)
        return nil;
    
    targetGetter = [targetGetter copy];
    
    return ^void(id _self, ...) {
        
        const char *signature = NULL;
        SEL selector = NULL;
        id target = targetGetter(_self, &signature, &selector);
        
        va_list args;
        va_start(args, _self);
        
        self_invokeMethosBlockWithArgsAndReturnValue(target,
                                                     signature,
                                                     selector,
                                                     args,
                                                     &_self,
                                                     NULL,
                                                     originalSelector);
        
        va_end(args);
    };
}

static id generalHookBlockForSignature(const char *prototypeSinature,
                                       SEL originalSelector,
                                       id(^targetGetter)(id _self, const char**, SEL*)
                                       )
{
    id resultBlock;
    
    NSCParameterAssert(strlen(prototypeSinature) != 0);
    char returnType[strlen(prototypeSinature) + 1];
    const char *typeSignatureScanFormat = "%[@^vcI]";//check it for new added types
    sscanf(prototypeSinature, typeSignatureScanFormat, returnType);
    
    const char *methodReturnType = returnType;
    if (strcmp(@encode(id), returnType) == 0)
        methodReturnType = @encode(void *);
    
    resultBlock = resultBlock?:generalHookBlock<void *    >(methodReturnType, originalSelector, targetGetter);
    resultBlock = resultBlock?:generalHookBlock<NSUInteger>(methodReturnType, originalSelector, targetGetter);
    resultBlock = resultBlock?:generalHookBlock<BOOL      >(methodReturnType, originalSelector, targetGetter);
    resultBlock = resultBlock?:generalHookBlock<void      >(methodReturnType, originalSelector, targetGetter);
    
    if (!resultBlock) {
        
        NSCAssert(0, @"typeSignatureScanFormat - check it for new added types");
    }
    
    //originalBlock = resultBlock;
    
    return resultBlock;
}

static NSMutableDictionary *lazyHookedClassesAndMethod()
{
    static NSMutableDictionary *result;
    
    if (!result) {
        
        result = [NSMutableDictionary new];
    }
    return result;
}

//TODO do not use ARC for this class
//returns a block with original implementation
static void hookMehodWithGeneralBlock(const char *prototypeSinature, SEL selectorToHook, Class classToHook)
{
    id generalHook = generalHookBlockForSignature(prototypeSinature, selectorToHook, ^id(id _localSelf, const char** sinature, SEL* selector) {
        
        id block = lastBlockObserver(_localSelf, selectorToHook);
        
        if (block)
            *sinature = block_getTypeEncoding(block);
        
        return block;
    });
    
    Method hookedMethod = class_getInstanceMethod(classToHook, selectorToHook);
    
    if (hookedMethod != NULL) {
        
        SEL originalMethodHolder = originalMethodHolderSelector(selectorToHook);
        
        BOOL added = class_addMethod(classToHook,
                                     originalMethodHolder,
                                     imp_implementationWithBlock(generalHook),
                                     prototypeSinature);
        
        {
            NSString *errorDescription = [[NSString alloc] initWithFormat:@"camn not add method: %@", NSStringFromSelector(originalMethodHolder)];
            NSCAssert(added, errorDescription);
        }
        
        Method hookHolderMethod = class_getInstanceMethod(classToHook, originalMethodHolder);
        
        method_exchangeImplementations(hookHolderMethod, hookedMethod);
        
    } else {
        
        BOOL added = class_addMethod(classToHook,
                                     selectorToHook,
                                     imp_implementationWithBlock(generalHook),
                                     prototypeSinature);
        
        {
            NSString *errorDescription = [[NSString alloc] initWithFormat:@"camn not add method: %@", NSStringFromSelector(selectorToHook)];
            NSCAssert(added, errorDescription);
        }
    }
    
    //save flag that method hooked
    {
        NSMutableDictionary *hookedClassesAndMethod = lazyHookedClassesAndMethod();
        
        NSString *className = [classToHook description];
        NSMutableSet *methods = hookedClassesAndMethod[className];
        
        if (!methods) {
            
            methods = [NSMutableSet new];
            hookedClassesAndMethod[className] = methods;
        }
        
        [methods addObject:NSStringFromSelector(selectorToHook)];
    }
}

@implementation NSObject (ObjectMethodHook)

- (NSMutableArray *)lazyObserversBlocksForSelectorName:(NSString *)selectorName
{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &ownershipsKey);
    
    if (!dict) {
        
        dict = [NSMutableDictionary new];
        objc_setAssociatedObject(self, &ownershipsKey, dict, OBJC_ASSOCIATION_RETAIN);
    }
    
    NSMutableArray *result = dict[selectorName];
    
    if (!result) {
        
        result = [NSMutableArray new];
        dict[selectorName] = result;
    }
    
    return result;
}

static id hookedMethodBlockHolder(SEL selectorToHook, id _self)
{
    SEL originalMethodHolder = originalMethodHolderSelector(selectorToHook);
    
    Method hookHolderMethod = class_getInstanceMethod([_self class], originalMethodHolder);
    
    if (hookHolderMethod == NULL)
        return nil;
    
    const char *prototypeSinature = method_getTypeEncoding(hookHolderMethod);
    
    return generalHookBlockForSignature(prototypeSinature, selectorToHook, ^id(id _localSelf, const char** sinature, SEL* selector) {
        
        *sinature = prototypeSinature;
        *selector = originalMethodHolder;
        
        return _localSelf;
    });
}

static Class findClassForHook(SEL selectorToHook, id _self)
{
    Class result = [_self class];
    
    Method method = class_getInstanceMethod(result, selectorToHook);
    Class resultSuper = [result superclass];
    
    while (resultSuper && method == class_getInstanceMethod(resultSuper, selectorToHook)) {
        
        method = class_getInstanceMethod(resultSuper, selectorToHook);
        result      = resultSuper;
        resultSuper = [result superclass];
    }
    
    if (method == NULL)
        result = [_self class];
    
    return result;
}

static Class findClassForHookIfNotHooked(SEL selectorToHook, id _self)
{
    Class result = findClassForHook(selectorToHook, _self);
    
    NSMutableDictionary *hookedClassesAndMethod = lazyHookedClassesAndMethod();
    
    NSString *className = [result description];
    NSMutableSet *methods = hookedClassesAndMethod[className];
    
    if ([methods containsObject:NSStringFromSelector(selectorToHook)]) {
        return Nil;
    }
    
    return result;
}

//TODO try to hook retain method
- (void)addMethodHook:(JFFMethodObserverBlock)observer
             selector:(SEL)selectorToHook
{
    NSString *selectorStr = NSStringFromSelector(selectorToHook);
    
    NSMutableArray *methodObservers = [self lazyObserversBlocksForSelectorName:selectorStr];
    Class classToHook = findClassForHookIfNotHooked(selectorToHook, self);
    
    __block id previousObserver = [methodObservers lastObject];
    
    __unsafe_unretained id unsafeUnretainedSelf = self;
    
    id hook = observer(^id() {
        
        if (!previousObserver) {
            
            return hookedMethodBlockHolder(selectorToHook, unsafeUnretainedSelf);
        }
        return previousObserver;
    });
    
    if (classToHook != NULL) {
        
        const char *prototypeSinature = block_getTypeEncoding(hook);
        hookMehodWithGeneralBlock(prototypeSinature, selectorToHook, classToHook);
    }
    
    [methodObservers addObject:hook];
}

@end
