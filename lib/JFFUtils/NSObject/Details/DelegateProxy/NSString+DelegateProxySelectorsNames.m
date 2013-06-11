#import "NSString+DelegateProxySelectorsNames.h"

@implementation NSString (DelegateProxySelectorsNames)

- (instancetype)hookedGetterMethodNameForClass:(Class)targetClass
{
    NSString *result = [[NSString alloc]initWithFormat:@"hookedDelegateGetterName_%@_%@",
                        targetClass,
                        self];
    return result;
}

@end
