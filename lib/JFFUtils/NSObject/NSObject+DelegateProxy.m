#import "NSObject+DelegateProxy.h"

#import "JFFAssignProxy.h"
#import "JFFMutableAssignArray.h"

#import "DelegateProxyUtils.h"

#include <objc/runtime.h>

static char proxyDelegatesKey;
static char realDelegateKey;

@interface NSObject (DelegateProxyPrivate)

@property (nonatomic, weak) id realDelegateWeakObject;

- (JFFMutableAssignArray*)lazyProxyDelegatesWeakMutableArray;
- (JFFMutableAssignArray*)lazyRealDelegateWeakMutableArray;

@end

@implementation NSObject (DelegateProxy)

- (JFFMutableAssignArray*)lazyProxyDelegatesWeakMutableArray
{
    if (!objc_getAssociatedObject(self, &proxyDelegatesKey))
    {
        objc_setAssociatedObject(self, &proxyDelegatesKey, [JFFMutableAssignArray new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, &proxyDelegatesKey);
}

- (id)realDelegateWeakObject
{
    JFFAssignProxy *resultProxy = objc_getAssociatedObject(self, &realDelegateKey);
    return resultProxy.target;
}

- (void)setRealDelegateWeakObject:(id)delegate
{
    JFFAssignProxy *proxy = [[JFFAssignProxy alloc]initWithTarget:delegate];
    objc_setAssociatedObject(self, &realDelegateKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addDelegateProxy:(id)proxy
            delegateName:(NSString *)delegateName
{
    jff_validateSeteDelegateProxyMethodArguments(proxy, delegateName, self);

    hookDelegateSetterAndGetterMethodsForProxyDelegate(delegateName, [self class]);
}

- (void)removeDelegateProxy:(id)proxy
               delegateName:(NSString *)delegateName
{
    jff_validateSeteDelegateProxyMethodArguments(proxy, delegateName, self);

    hookDelegateSetterAndGetterMethodsForProxyDelegate(delegateName, [self class]);

    [self doesNotRecognizeSelector:_cmd];
}

- (void)setDelegateProxy:(id)proxy
            delegateName:(NSString *)delegateName
{
    if (proxy)
    {
        [self addDelegateProxy:proxy
                  delegateName:delegateName];
        return;
    }

    [self removeDelegateProxy:proxy
                 delegateName:delegateName];
}

@end
