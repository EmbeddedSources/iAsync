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
                 newMethodSelector:( SEL )newSelector_
                         hasMethod:( JFFPredicate )hasMethod_
                      methodGetter:( JFFMethodGetter )methodGetter_
{
    if ( hasMethod_() )
        return NO;

    Method prototypeMethod_ = methodGetter_();
    const char* typeEncoding_ = method_getTypeEncoding( prototypeMethod_ );
    BOOL result_ = class_addMethod( class_
                                   , newSelector_
                                   , method_getImplementation( prototypeMethod_ )
                                   , typeEncoding_ );
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
                         newMethodSelector:( SEL )newSelector_
{
    JFFPredicate respondToSelector_ = ^BOOL()
    {
        return [ class_ hasInstanceMethodWithSelector: newSelector_ ];
    };
    JFFMethodGetter methodGetter_ = ^Method()
    {
        return class_getInstanceMethod( self, selector_ );
    };
    return [ self addMethodIfNeedWithSelector: selector_
                                      toClass: class_
                            newMethodSelector: newSelector_
                                    hasMethod: respondToSelector_
                                 methodGetter: methodGetter_ ];
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
                      newMethodSelector:( SEL )newSelector_
{
    JFFPredicate respondToSelector_ = ^BOOL()
    {
        return [ class_ hasClassMethodWithSelector: newSelector_ ];
    };
    JFFMethodGetter methodGetter_ = ^Method()
    {
        return class_getClassMethod( self, selector_ );
    };
    return [ self addMethodIfNeedWithSelector: selector_
                                      toClass: object_getClass( class_ )
                            newMethodSelector: newSelector_
                                    hasMethod: respondToSelector_
                                 methodGetter: methodGetter_ ];
}

+(void)hookMethodForClass:( Class )class_
            classForClass:( JFFClassForClass )classForClass_
             withSelector:( SEL )targetSelector_
  prototypeMethodSelector:( SEL )prototypeSelector_
       hookMethodSelector:( SEL )hookSelector_
             methodGetter:( JFFMethodGetterForClassAndSelector )methodGetter_
{
    Class targetClass_ = classForClass_( class_ );

    Method targetMethod_    = methodGetter_( class_, targetSelector_    );
    Method prototypeMethod_ = methodGetter_( self  , prototypeSelector_ );

    NSParameterAssert( targetMethod_    );
    NSParameterAssert( prototypeMethod_ );

    const char* typeEncoding_ = method_getTypeEncoding( prototypeMethod_ );
    BOOL methodAdded_ = class_addMethod( targetClass_
                                         , hookSelector_
                                         , method_getImplementation( prototypeMethod_ )
                                         , typeEncoding_ );
    NSAssert( methodAdded_, @"should be added" );
    Method hookMethod_ = methodGetter_( class_, hookSelector_ );

    method_exchangeImplementations( targetMethod_, hookMethod_ );
}

+(void)hookInstanceMethodForClass:( Class )class_
                     withSelector:( SEL )targetSelector_
          prototypeMethodSelector:( SEL )prototypeSelector_
               hookMethodSelector:( SEL )hookSelector_
{
    JFFMethodGetterForClassAndSelector methodGetter_ = ^Method( Class class_, SEL selector_ )
    {
        return class_getInstanceMethod( class_, selector_ );
    };
    [ self hookMethodForClass: class_
                classForClass: ^Class( Class class_ ) { return class_; }
                 withSelector: targetSelector_
      prototypeMethodSelector: prototypeSelector_
           hookMethodSelector: hookSelector_
                 methodGetter: methodGetter_ ];
}

+(void)hookClassMethodForClass:( Class )class_
                  withSelector:( SEL )targetSelector_
       prototypeMethodSelector:( SEL )prototypeSelector_
            hookMethodSelector:( SEL )hookSelector_
{
    JFFMethodGetterForClassAndSelector methodGetter_ = ^Method( Class otherClass_, SEL selector_ )
    {
        return class_getClassMethod( otherClass_, selector_ );
    };
    [ self hookMethodForClass: class_
                classForClass: ^Class( Class class_ ) { return object_getClass( class_ ); }
                 withSelector: targetSelector_
      prototypeMethodSelector: prototypeSelector_
           hookMethodSelector: hookSelector_
                 methodGetter: methodGetter_ ];
}

+(BOOL)hasMethodForMethodGetter:( JFFMethodGetterForClass )methodGetter_
{
    Method method_ = methodGetter_( [ self class ] );

    if ( !method_ )
        return NO;

    if ( ![ self superclass ] )
        return YES;

    Method superMethod_ = methodGetter_( [ self superclass ] );
    return method_ != superMethod_;
}

+(BOOL)hasInstanceMethodWithSelector:( SEL )methodSelector_
{
    return [ self hasMethodForMethodGetter: ^Method( Class class_ )
    {
        return class_getInstanceMethod( class_, methodSelector_ );
    } ];
}

+(BOOL)hasClassMethodWithSelector:( SEL )methodSelector_
{
    return [ self hasMethodForMethodGetter: ^Method( Class class_ )
    {
        return class_getClassMethod( class_, methodSelector_ );
    } ];
}

@end
