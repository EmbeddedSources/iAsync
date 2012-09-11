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

    return [self proxyDelegatesDispatcherForHookedGetterName:hookedGetterName
                                                delegateName:hookedDelegateName];
}

//TODO not need to hook setter
- (id)delegateSetterHookMethod:(id)delegate
{
    NSString *delegateName = NSStringFromSelector(_cmd);
    NSArray *delegateNameComponents = [delegateName componentsSeparatedByString:@"_"];
    NSString *hookedSetterName = [[delegateNameComponents lastObject]hookedSetterMethodNameForClass:[self class]];
    return objc_msgSend(self, NSSelectorFromString(hookedSetterName), delegate);
}

@end
