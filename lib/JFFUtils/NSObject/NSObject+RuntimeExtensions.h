#import <Foundation/Foundation.h>

@interface NSObject (RuntimeExtensions)

+ (BOOL)addInstanceMethodIfNeedWithSelector:(SEL)selector
                                    toClass:(Class)targetClass;

+ (BOOL)addInstanceMethodIfNeedWithSelector:(SEL)selector
                                    toClass:(Class)targetClass
                          newMethodSelector:(SEL)newSelector;

+ (BOOL)addClassMethodIfNeedWithSelector:(SEL)selector
                                 toClass:(Class)targetClass;

+ (BOOL)addClassMethodIfNeedWithSelector:(SEL)selector
                                 toClass:(Class)targetClass
                       newMethodSelector:(SEL)newSelector;

+ (void)hookInstanceMethodForClass:(Class)targetClass
                      withSelector:(SEL)targetSelector
           prototypeMethodSelector:(SEL)prototypeSelector
                hookMethodSelector:(SEL)hookSelector;

+ (void)hookClassMethodForClass:(Class)targetClass
                   withSelector:(SEL)targetSelector
        prototypeMethodSelector:(SEL)prototypeSelector
             hookMethodSelector:(SEL)hookSelector;

+ (BOOL)hasInstanceMethodWithSelector:(SEL)methodSelector;
+ (BOOL)hasClassMethodWithSelector:(SEL)methodSelector;

@end
