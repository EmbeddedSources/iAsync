#import <Foundation/Foundation.h>

@interface NSObject (RuntimeExtensions)

+(BOOL)addInstanceMethodIfNeedWithSelector:( SEL )selector_
                                   toClass:( Class )class_;

+(BOOL)addInstanceMethodIfNeedWithSelector:( SEL )selector_
                                   toClass:( Class )class_
                         newMethodSelector:( SEL )newSelector_;

+(BOOL)addClassMethodIfNeedWithSelector:( SEL )selector_
                                toClass:( Class )class_;

+(BOOL)addClassMethodIfNeedWithSelector:( SEL )selector_
                                toClass:( Class )class_
                      newMethodSelector:( SEL )newSelector_;

+(void)hookInstanceMethodForClass:( Class )class_
                     withSelector:( SEL )targetSelector_
          prototypeMethodSelector:( SEL )prototypeSelector_
               hookMethodSelector:( SEL )hookSelector_;

+(void)hookClassMethodForClass:( Class )class_
                  withSelector:( SEL )targetSelector_
       prototypeMethodSelector:( SEL )prototypeSelector_
            hookMethodSelector:( SEL )hookSelector_;

+(BOOL)hasInstanceMethodWithSelector:( SEL )methodSelector_;
+(BOOL)hasClassMethodWithSelector:( SEL )methodSelector_;

@end
