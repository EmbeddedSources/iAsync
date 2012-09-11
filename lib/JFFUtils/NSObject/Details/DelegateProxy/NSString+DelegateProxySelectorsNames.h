#import <Foundation/Foundation.h>

@interface NSString (DelegateProxySelectorsNames)

- (NSString*)hookedGetterMethodNameForClass:(Class)targetClass;
- (NSString*)hookedSetterMethodNameForClass:(Class)targetClass;

@end
