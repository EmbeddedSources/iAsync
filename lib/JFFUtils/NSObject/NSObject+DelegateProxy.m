#import "NSObject+DelegateProxy.h"

#import "JFFAssignProxy.h"
#import "JFFMutableAssignArray.h"

#import "JFFClangLiterals.h"
#import "DelegateProxyUtils.h"
#import "JFFProxyDelegatesDispatcher.h"

#include <objc/runtime.h>
#include <objc/message.h>

static char proxyDelegatesKey;

@implementation NSObject (DelegateProxy)

- (NSMutableDictionary *)lazyProxyDelegatesDictionary
{
    NSMutableDictionary *result = objc_getAssociatedObject(self, &proxyDelegatesKey);
    
    if (!result) {
        result = [NSMutableDictionary new];
        objc_setAssociatedObject(self, &proxyDelegatesKey, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return result;
}

- (JFFMutableAssignArray *)proxyDelegatesForDelegateWithName:(NSString *)delegateName
{
    NSMutableDictionary *arrayByDelegateName = [self lazyProxyDelegatesDictionary];
    
    JFFMutableAssignArray *delegates = arrayByDelegateName[delegateName];
    return delegates;
}

- (JFFMutableAssignArray *)lazyProxyDelegatesForDelegateWithName:(NSString *)delegateName
{
    NSMutableDictionary *arrayByDelegateName = [self lazyProxyDelegatesDictionary];
    
    JFFMutableAssignArray *delegates = arrayByDelegateName[delegateName];
    
    if (!delegates) {
        delegates = [JFFMutableAssignArray new];
        arrayByDelegateName[delegateName] = delegates;
    }
    
    return delegates;
}

- (JFFProxyDelegatesDispatcher *)proxyDelegatesDispatcherForHookedGetterName:(NSString *)hookedGetterName
                                                                delegateName:(NSString *)delegateName
{
    JFFMutableAssignArray *delegates = [self proxyDelegatesForDelegateWithName:delegateName];
    
    if ([delegates count] == 0) {
        return nil;
    }
    
    typedef id (*PropertyGetterMsgSendFunction)( id, SEL );
    static const PropertyGetterMsgSendFunction FPropertyGetter = (PropertyGetterMsgSendFunction)objc_msgSend;
    id realDelegate = FPropertyGetter(self, NSSelectorFromString(hookedGetterName));
    
    JFFProxyDelegatesDispatcher *dispatcher =
    [JFFProxyDelegatesDispatcher newProxyDelegatesDispatcherWithRealDelegate:realDelegate
                                                                   delegates:delegates];
    
    return dispatcher;
}

- (void)addDelegateProxy:(id)proxy
            delegateName:(NSString *)delegateName
{
    jff_validateSeteDelegateProxyMethodArguments(proxy, delegateName, self);
    
    hookDelegateSetterAndGetterMethodsForProxyDelegate(delegateName, [self class]);
    
    //add proxy object
    {
        JFFMutableAssignArray *delegates = [self lazyProxyDelegatesForDelegateWithName:delegateName];
        [delegates addObject:proxy];
    }
}

- (void)removeDelegateProxy:(id)proxy
               delegateName:(NSString *)delegateName
{
    jff_validateSeteDelegateProxyMethodArguments(proxy, delegateName, self);
    
    hookDelegateSetterAndGetterMethodsForProxyDelegate(delegateName, [self class]);
    
    //remove proxy object
    {
        JFFMutableAssignArray *delegates = [self proxyDelegatesForDelegateWithName:delegateName];
        [delegates removeObject:proxy];
    }
}

@end
