#import <Foundation/Foundation.h>

void jff_validateSeteDelegateProxyMethodArguments(id proxy, NSString *delegateName, id targetObject);

void hookDelegateSetterAndGetterMethodsForProxyDelegate(NSString *delegateName,
                                                        Class targetClass);
