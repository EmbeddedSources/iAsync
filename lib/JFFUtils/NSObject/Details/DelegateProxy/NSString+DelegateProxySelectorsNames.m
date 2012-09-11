#import "NSString+DelegateProxySelectorsNames.h"

@implementation NSString (DelegateProxySelectorsNames)

- (NSString*)hookedGetterMethodNameForClass:(Class)targetClass
{
    NSString *result = [[NSString alloc]initWithFormat:@"hookedDelegateGetterName_%@_%@",
                        targetClass,
                        self];
    return result;
}

- (NSString*)hookedSetterMethodNameForClass:(Class)targetClass
{
    NSString *result = [[NSString alloc]initWithFormat:@"hookedDelegateSetterName_%@_%@",
                        targetClass,
                        self];
    return result;
}

@end
