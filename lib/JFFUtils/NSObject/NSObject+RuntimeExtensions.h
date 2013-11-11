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



/**
 @param targetClass - a class for which the hook is being set up. Both targetSelector andhookSelector must be implemented for it.
 
 @param targetSelector - a static method of the targetClass to be replaced
 
 @param prototypeSelector - a static method of "self" to be executed instead of "targetSelector"
 
 @param hookSelector - a static method of "self" where old implementation will be placed. It may be invoked from "prototypeSelector"
 */
+ (void)hookInstanceMethodForClass:(Class)targetClass
                      withSelector:(SEL)targetSelector
           prototypeMethodSelector:(SEL)prototypeSelector
                hookMethodSelector:(SEL)hookSelector;

//+ (void)unHookInstanceMethodForClass:(Class)targetClass
//                        withSelector:(SEL)targetSelector
//             prototypeMethodSelector:(SEL)prototypeSelector
//                  hookMethodSelector:(SEL)hookSelector;

/**
 @param targetClass - a class for which the hook is being set up. Both targetSelector andhookSelector must be implemented for it.
 
 @param targetSelector - an instance method of the targetClass to be replaced
 
 @param prototypeSelector - an instance method of "self" to be executed instead of "targetSelector"
 
 @param hookSelector - an instance method of "self" where old implementation will be placed. It may be invoked from "prototypeSelector"
 */
+ (void)hookClassMethodForClass:(Class)targetClass
                   withSelector:(SEL)targetSelector
        prototypeMethodSelector:(SEL)prototypeSelector
             hookMethodSelector:(SEL)hookSelector;

//+ (void)unHookClassMethodForClass:(Class)targetClass
//                     withSelector:(SEL)targetSelector
//          prototypeMethodSelector:(SEL)prototypeSelector
//               hookMethodSelector:(SEL)hookSelector;

+ (BOOL)hasInstanceMethodWithSelector:(SEL)methodSelector;
+ (BOOL)hasClassMethodWithSelector:(SEL)methodSelector;

@end
