#import "JFFDelegateProxyClassMethods.h"

#import "NSString+DelegateProxySelectorsNames.h"

#include <objc/message.h>

@implementation JFFDelegateProxyClassMethods

- (id)delegateGetterHookMethod
{
    NSString *delegateName = NSStringFromSelector(_cmd);
    NSArray *delegateNameComponents = [delegateName componentsSeparatedByString:@"_"];
    NSString *hookedGetterName = [[delegateNameComponents lastObject]hookedGetterMethodNameForClass:[self class]];
    return objc_msgSend(self, NSSelectorFromString(hookedGetterName));
}

- (id)delegateSetterHookMethod:(id)delegate
{
    NSString *delegateName = NSStringFromSelector(_cmd);
    NSArray *delegateNameComponents = [delegateName componentsSeparatedByString:@"_"];
    NSString *hookedSetterName = [[delegateNameComponents lastObject]hookedSetterMethodNameForClass:[self class]];
    return objc_msgSend(self, NSSelectorFromString(hookedSetterName), delegate);
}

@end
