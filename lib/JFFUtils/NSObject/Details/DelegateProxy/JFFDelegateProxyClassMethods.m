#import "JFFDelegateProxyClassMethods.h"

#import "NSString+DelegateProxySelectorsNames.h"

#include <objc/message.h>

@class JFFMutableAssignArray;
@class JFFProxyDelegatesDispatcher;

@interface NSObject (DelegateProxyPrivate_JFFDelegateProxyClassMethods)

- (JFFProxyDelegatesDispatcher *)proxyDelegatesDispatcherForHookedGetterName:(NSString *)hookedGetterName
                                                                delegateName:(NSString *)delegateName;

@end

//TODO should be NSProxy
@implementation JFFDelegateProxyClassMethods

- (id)delegateGetterHookMethod
{
    NSString *delegateName = NSStringFromSelector(_cmd);
    NSArray *delegateNameComponents = [delegateName componentsSeparatedByString:@"_"];
    
    NSString *hookedDelegateName = [delegateNameComponents lastObject];
    
    NSString *hookedGetterName = [hookedDelegateName hookedGetterMethodNameForClass:[self class]];
    
    JFFProxyDelegatesDispatcher *proxy = [self proxyDelegatesDispatcherForHookedGetterName:hookedGetterName
                                                                              delegateName:hookedDelegateName];
    if (proxy)
        return proxy;
    
    return objc_msgSend(self, NSSelectorFromString(hookedGetterName));
}

@end
