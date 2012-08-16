#import <JFFUtils/NSObject/NSObject+RuntimeExtensions.h>

#include <objc/message.h>

static const NSUInteger testClassMethodResult_ = 34;//just rendomize number
static const NSUInteger testInstanceMethodResult_ = 35;//just rendomize number

@interface NSTestClass : NSObject
@end

@implementation NSTestClass

+(id)allocWithZone:( NSZone* )zone_
{
    return [ super allocWithZone: zone_ ];
}

-(BOOL)isEqual:( id )object_
{
    return [ super isEqual: object_ ];
}

+(NSUInteger)classMethodWithLongNameForUniquenessPurposes
{
    return testClassMethodResult_;
}

-(NSUInteger)instanceMethodWithLongNameForUniquenessPurposes
{
    return testInstanceMethodResult_;
}

@end

@interface NSObjectRuntimeExtensionsTest : GHTestCase
@end

@implementation NSObjectRuntimeExtensionsTest

-(void)testHasClassMethodWithSelector
{
    GHAssertTrue( [ NSObject hasClassMethodWithSelector: @selector( allocWithZone: ) ], @"NSOBject has allocWithZone: method" );
    GHAssertFalse( [ NSObject hasClassMethodWithSelector: @selector( allocWithZone2: ) ], @"NSOBject has no allocWithZone2: method" );

    GHAssertTrue( [ NSTestClass hasClassMethodWithSelector: @selector( allocWithZone: ) ]
                 , @"NSTestClass has allocWithZone: method" );
    GHAssertFalse( [ NSTestClass hasClassMethodWithSelector: @selector( alloc ) ]
                  , @"NSTestClass has no alloc method" );
}

-(void)testHasInstanceMethodWithSelector
{
    GHAssertTrue( [ NSObject hasInstanceMethodWithSelector: @selector( isEqual: ) ], @"NSOBject has isEqual: method" );
    GHAssertFalse( [ NSObject hasInstanceMethodWithSelector: @selector( isEqual2: ) ], @"NSOBject has no isEqual2: method" );

    GHAssertTrue( [ NSTestClass hasInstanceMethodWithSelector: @selector( isEqual: ) ]
                 , @"NSTestClass has isEqual: method" );
    GHAssertFalse( [ NSTestClass hasInstanceMethodWithSelector: @selector( description ) ]
                  , @"NSTestClass has no description method" );
}

-(void)testAddClassMethodIfNeedWithSelector
{
    static BOOL first_test_run_ = YES;

    if ( first_test_run_ )
    {
        BOOL result_ = [ NSTestClass addClassMethodIfNeedWithSelector: @selector( classMethodWithLongNameForUniquenessPurposes )
                                                              toClass: [ NSTestClass class ]
                                                    newMethodSelector: @selector( classMethodWithLongNameForUniquenessPurposes2 ) ];

        GHAssertTrue( result_, @"method added" );

        GHAssertTrue( [ NSTestClass hasClassMethodWithSelector: @selector( classMethodWithLongNameForUniquenessPurposes2 ) ]
                     , @"NSTestClass has classMethodWithLongNameForUniquenessPurposes2 method" );

        NSUInteger method_result_ = (NSUInteger)objc_msgSend( [ NSTestClass class ], @selector( classMethodWithLongNameForUniquenessPurposes2 ) );
        GHAssertTrue( testClassMethodResult_ == method_result_, @"check implementation of new method" );

        first_test_run_ = NO;
    }
}

-(void)testAddInstanceMethodIfNeedWithSelector
{
    static BOOL first_test_run_ = YES;

    if ( first_test_run_ )
    {
        SEL new_method_selector_ = @selector( instanceMethodWithLongNameForUniquenessPurposes2 );
        BOOL result_ = [ NSTestClass addInstanceMethodIfNeedWithSelector: @selector( instanceMethodWithLongNameForUniquenessPurposes )
                                                                 toClass: [ NSTestClass class ]
                                                       newMethodSelector: new_method_selector_ ];

        GHAssertTrue( result_, @"method added" );

        GHAssertTrue( [ NSTestClass hasInstanceMethodWithSelector: new_method_selector_ ]
                     , @"NSTestClass has instanceMethodWithLongNameForUniquenessPurposes2 method" );

        NSTestClass* instance_ = [ NSTestClass new ];
        NSUInteger method_result_ = (NSUInteger)objc_msgSend( instance_, new_method_selector_ );
        GHAssertTrue( testInstanceMethodResult_ == method_result_, @"check implementation of new method" );

        first_test_run_ = NO;
   }
}

@end
