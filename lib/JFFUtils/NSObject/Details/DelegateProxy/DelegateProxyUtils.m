#import "DelegateProxyUtils.h"

#import "NSString+PropertyName.h"
#import "NSObject+RuntimeExtensions.h"
#import "NSString+DelegateProxySelectorsNames.h"

#import "JFFDelegateProxyClassMethods.h"

void jff_validateSeteDelegateProxyMethodArguments(id proxy, NSString *delegateName, id targetObject)
{
    //JDOTO assert that property is weak or unsafe_unretained
    assert([delegateName length]>0);
    assert(proxy);
    assert(targetObject);
    
    //should has a property getter
    assert([[targetObject class] hasInstanceMethodWithSelector:NSSelectorFromString(delegateName)]);
}

void hookDelegateSetterAndGetterMethodsForProxyDelegate(NSString *delegateName,
                                                        Class targetClass)
{
    Class prototypeClass = [JFFDelegateProxyClassMethods class];
    
    NSString *prototypeMethodName = [[NSString alloc] initWithFormat:@"prototypeDelegateGetterName_%@_%@",
                                     targetClass,
                                     delegateName];
    NSString *hookedGetterName = [delegateName hookedGetterMethodNameForClass:targetClass];
    
    if ([prototypeClass addInstanceMethodIfNeedWithSelector:@selector(delegateGetterHookMethod)
                                                    toClass:prototypeClass
                                          newMethodSelector:NSSelectorFromString(prototypeMethodName)]) {
        [prototypeClass hookInstanceMethodForClass:targetClass
                                      withSelector:NSSelectorFromString(delegateName)
                           prototypeMethodSelector:NSSelectorFromString(prototypeMethodName)
                                hookMethodSelector:NSSelectorFromString(hookedGetterName)];
    }
}
