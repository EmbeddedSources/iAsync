#import "NSObject+DelegateProxy.h"

#import "NSObject+RuntimeExtensions.h"
#import "NSString+PropertyName.h"

#include <objc/message.h>

static void validateArguments(id proxy,
                              NSString *delegateName,
                              id targetObject)
{
    assert([delegateName length]>0);
    assert(proxy);
    assert(targetObject);

    //should has a propery getter
    assert([[targetObject class] hasInstanceMethodWithSelector:NSSelectorFromString(delegateName)]);
    //should has a propery setter
    assert([[targetObject class] hasInstanceMethodWithSelector:NSSelectorFromString([delegateName propertySetNameForPropertyName])]);
}

@interface JFFDelegateProxyClassMethods : NSObject
@end

@implementation JFFDelegateProxyClassMethods

- (id)delegateGetterHookMethod
{
    NSString *delegateName = NSStringFromSelector(_cmd);
    NSArray *delegateNameComponents = [delegateName componentsSeparatedByString:@"_"];
    NSString *hookedGetterName = [[NSString alloc]initWithFormat:@"hookedDelegateGetterName_%@_%@",
                                  [self class],
                                  [delegateNameComponents lastObject]];
    return objc_msgSend(self, NSSelectorFromString(hookedGetterName));
}

@end

@implementation NSObject (DelegateProxy)

- (void)addDelegateProxy:(id)proxy
            delegateName:(NSString *)delegateName
{
    validateArguments(proxy, delegateName, self);

    Class prototypeClass = [JFFDelegateProxyClassMethods class];

    {
        NSString *prototypeMethodName = [[NSString alloc]initWithFormat:@"prototypeDelegateGetterName_%@_%@",
                                         [self class],
                                         delegateName];
        NSString *hookedMethodName = [[NSString alloc]initWithFormat:@"hookedDelegateGetterName_%@_%@",
                                    [self class],
                                    delegateName];

        if ([prototypeClass addInstanceMethodIfNeedWithSelector:@selector(delegateGetterHookMethod)
                                                        toClass:prototypeClass
                                              newMethodSelector:NSSelectorFromString(prototypeMethodName)])
        {
            [prototypeClass hookInstanceMethodForClass:[self class]
                                          withSelector:NSSelectorFromString(delegateName)
                               prototypeMethodSelector:NSSelectorFromString(prototypeMethodName)
                                    hookMethodSelector:NSSelectorFromString(hookedMethodName)];
        }
    }
}

- (void)removeDelegateProxy:(id)proxy
               delegateName:(NSString *)delegateName
{
    validateArguments(proxy, delegateName, self);
}

@end
