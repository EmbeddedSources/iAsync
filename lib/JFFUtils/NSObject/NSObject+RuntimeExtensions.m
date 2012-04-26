#import "NSObject+RuntimeExtensions.h"

#include <objc/runtime.h>

typedef Method (^JFFMethodGetter)();
typedef Method (^JFFMethodGetterForClass)( Class cls_ );
typedef Method (^JFFMethodGetterForClassAndSelector)( Class cls_, SEL selector_ );
typedef Class (^JFFClassForClass)( Class cls_ );
typedef BOOL (^JFFPredicate)();

@implementation NSObject (RuntimeExtensions)

+(BOOL)addMethodIfNeedWithSelector:( SEL )selector_
                           toClass:( Class )class_
                 newMethodSelector:( SEL )new_selector_
                         hasMethod:( JFFPredicate )has_method_
                      methodGetter:( JFFMethodGetter )method_getter_
{
    if ( has_method_() )
        return NO;

    Method prototype_method_ = method_getter_();
    const char* type_encoding_ = method_getTypeEncoding( prototype_method_ );
    BOOL result_ = class_addMethod( class_
                                   , new_selector_
                                   , method_getImplementation( prototype_method_ )
                                   , type_encoding_ );
    NSAssert( result_, @"method should be added" );
    return result_;
}

+(BOOL)addInstanceMethodIfNeedWithSelector:( SEL )selector_
                                   toClass:( Class )class_
{
    return [ self addInstanceMethodIfNeedWithSelector: selector_
                                              toClass: class_
                                    newMethodSelector: selector_ ];
}

+(BOOL)addInstanceMethodIfNeedWithSelector:( SEL )selector_
                                   toClass:( Class )class_
                         newMethodSelector:( SEL )new_selector_
{
    JFFPredicate respond_to_selector_ = ^BOOL()
    {
        return [ class_ hasInstanceMethodWithSelector: new_selector_ ];
    };
    JFFMethodGetter method_getter_ = ^Method()
    {
        return class_getInstanceMethod( self, selector_ );
    };
    return [ self addMethodIfNeedWithSelector: selector_
                                      toClass: class_
                            newMethodSelector: new_selector_
                                    hasMethod: respond_to_selector_
                                 methodGetter: method_getter_ ];
}

+(BOOL)addClassMethodIfNeedWithSelector:( SEL )selector_
                                toClass:( Class )class_
{
    return [ self addClassMethodIfNeedWithSelector: selector_
                                           toClass: class_
                                 newMethodSelector: selector_ ];
}

+(BOOL)addClassMethodIfNeedWithSelector:( SEL )selector_
                                toClass:( Class )class_
                      newMethodSelector:( SEL )new_selector_
{
    JFFPredicate respond_to_selector_ = ^BOOL()
    {
        return [ class_ hasClassMethodWithSelector: new_selector_ ];
    };
    JFFMethodGetter method_getter_ = ^Method()
    {
        return class_getClassMethod( self, selector_ );
    };
    return [ self addMethodIfNeedWithSelector: selector_
                                      toClass: object_getClass( class_ )
                            newMethodSelector: new_selector_
                                    hasMethod: respond_to_selector_
                                 methodGetter: method_getter_ ];
}

//JTODO check if class contains hooked method
//typedef Class (^JFFClassForClass)( Class cls_ );
+(void)hookMethodForClass:( Class )class_
            classForClass:( JFFClassForClass )class_for_class_
             withSelector:( SEL )target_selector_
  prototypeMethodSelector:( SEL )prototype_selector_
       hookMethodSelector:( SEL )hook_selector_
             methodGetter:( JFFMethodGetterForClassAndSelector )method_getter_
{
    Method target_method_ = method_getter_( class_, target_selector_ );
    Method prototype_method_ = method_getter_( [ self class ], prototype_selector_ );
    const char* type_encoding_ = method_getTypeEncoding( prototype_method_ );
    BOOL method_added_ = class_addMethod( class_for_class_( class_ )
                                         , hook_selector_
                                         , method_getImplementation( prototype_method_ )
                                         , type_encoding_ );
    NSAssert( method_added_, @"should be added" );
    Method hook_method_ = method_getter_( class_, hook_selector_ );

    method_exchangeImplementations( target_method_, hook_method_ );
}

+(void)hookInstanceMethodForClass:( Class )class_
                     withSelector:( SEL )target_selector_
          prototypeMethodSelector:( SEL )prototype_selector_
               hookMethodSelector:( SEL )hook_selector_
{
    NSAssert( [ class_ hasInstanceMethodWithSelector: target_selector_ ], @"Method with target slector should exists" );
    JFFMethodGetterForClassAndSelector method_getter_ = ^Method( Class class_, SEL selector_ )
    {
        return class_getInstanceMethod( class_, selector_ );
    };
    [ self hookMethodForClass: class_
                classForClass: ^Class( Class class_ ) { return class_; }
                 withSelector: target_selector_
      prototypeMethodSelector: prototype_selector_
           hookMethodSelector: hook_selector_
                 methodGetter: method_getter_ ];
}

+(void)hookClassMethodForClass:( Class )class_
                  withSelector:( SEL )target_selector_
       prototypeMethodSelector:( SEL )prototype_selector_
            hookMethodSelector:( SEL )hook_selector_
{
    NSAssert( [ class_ hasClassMethodWithSelector: target_selector_ ], @"Method with target slector should exists" );
    JFFMethodGetterForClassAndSelector method_getter_ = ^Method( Class cls_, SEL selector_ )
    {
        return class_getClassMethod( class_, selector_ );
    };
    [ self hookMethodForClass: class_
                classForClass: ^Class( Class class_ ) { return object_getClass( class_ ); }
                 withSelector: target_selector_
      prototypeMethodSelector: prototype_selector_
           hookMethodSelector: hook_selector_
                 methodGetter: method_getter_ ];
}

+(BOOL)hasMethodForMethodGetter:( JFFMethodGetterForClass )method_getter_
{
    Method method_ = method_getter_( [ self class ] );

    if ( !method_ )
        return NO;

    if ( ![ self superclass ] )
        return YES;

    Method super_method_ = method_getter_( [ self superclass ] );
    return method_ != super_method_;
}

+(BOOL)hasInstanceMethodWithSelector:( SEL )method_selector_
{
    return [ self hasMethodForMethodGetter: ^Method( Class class_ )
    {
        return class_getInstanceMethod( class_, method_selector_ );
    } ];
}

+(BOOL)hasClassMethodWithSelector:( SEL )method_selector_
{
    return [ self hasMethodForMethodGetter: ^Method( Class class_ )
    {
        return class_getClassMethod( class_, method_selector_ );
    } ];
}

@end
