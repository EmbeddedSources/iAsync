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

inline static BOOL isObjectPointerReturnType(NSMethodSignature *sig)
{
    return *sig.methodReturnType == '@';
}

inline static BOOL isNSUIntegerReturnType(NSMethodSignature *sig)
{
    return *sig.methodReturnType == 'I';
}

inline static BOOL isVoidReturnType(NSMethodSignature *sig)
{
    return *sig.methodReturnType == 'v';
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
    //TODO call original method if no target
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
        
        //TODO test
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

static id generalHookBlockForSignature(const char *prototypeSinature,
                                       SEL originalSelector,
                                       id(^targetGetter)(id _self, const char**, SEL*)
                                       )
{
    id resultBlock;
    
    NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:prototypeSinature];
    
    if (isObjectPointerReturnType(sig)) {
        
        resultBlock = ^id(id _self, ...) {
            
            const char *signature = NULL;
            SEL selector = NULL;
            id target = targetGetter(_self, &signature, &selector);
            
            //assert(target && signature);
            
            va_list args;
            va_start(args, _self);
            
            NSObject *retValue;
            
            self_invokeMethosBlockWithArgsAndReturnValue(target,
                                                         signature,
                                                         selector,
                                                         args,
                                                         &_self,
                                                         &retValue,
                                                         originalSelector);
            
            va_end(args);
            
            if ([retValue isKindOfClass:[NSNumber class]]) {
                //NSNumber unsuported yet
                //TODO (__bridge NSObject *)(CFRetain((__bridge_retained CFTypeRef)retValue));
                assert(0);
            }
            
            return retValue;
        };
    } else if (isNSUIntegerReturnType(sig)) {
        
        resultBlock = ^NSUInteger(id _self, ...) {
            
            const char *signature = NULL;
            SEL selector = NULL;
            id target = targetGetter(_self, &signature, &selector);
            
            //assert(target && signature);
            
            va_list args;
            va_start(args, _self);
            
            NSUInteger retValue;
            
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
    } else if (isVoidReturnType(sig)) {
        
        resultBlock = ^void(id _self, ...) {
            
            const char *signature = NULL;
            SEL selector = NULL;
            id target = targetGetter(_self, &signature, &selector);
            
            //assert(target && signature);
            
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
    } else {
        
        assert(0);
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
        
        assert(added);
        
        Method hookHolderMethod = class_getInstanceMethod(classToHook, originalMethodHolder);
        
        method_exchangeImplementations(hookHolderMethod, hookedMethod);
        
    } else {
        
        //TODO test this case
        BOOL added = class_addMethod(classToHook,
                                     selectorToHook,
                                     imp_implementationWithBlock(generalHook),
                                     prototypeSinature);
        
        assert(added);
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
