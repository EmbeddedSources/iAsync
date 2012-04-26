#import <Foundation/Foundation.h>

@interface NSObject (RuntimeExtensions)

+(BOOL)addInstanceMethodIfNeedWithSelector:( SEL )selector_
                                   toClass:( Class )class_;

+(BOOL)addInstanceMethodIfNeedWithSelector:( SEL )selector_
                                   toClass:( Class )class_
                         newMethodSelector:( SEL )new_selector_;

+(BOOL)addClassMethodIfNeedWithSelector:( SEL )selector_
                                toClass:( Class )class_;

+(BOOL)addClassMethodIfNeedWithSelector:( SEL )selector_
                                toClass:( Class )class_
                      newMethodSelector:( SEL )new_selector_;

+(void)hookInstanceMethodForClass:( Class )class_
                     withSelector:( SEL )target_selector_
          prototypeMethodSelector:( SEL )prototype_selector_
               hookMethodSelector:( SEL )hook_selector_;

+(void)hookClassMethodForClass:( Class )class_
                  withSelector:( SEL )target_selector_
       prototypeMethodSelector:( SEL )prototype_selector_
            hookMethodSelector:( SEL )hook_selector_;

+(BOOL)hasInstanceMethodWithSelector:( SEL )method_selector_;
+(BOOL)hasClassMethodWithSelector:( SEL )method_selector_;

@end
