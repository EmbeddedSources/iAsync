#import "JMStringHolder.h"

#import "JMParent.h"
#import "JMChild.h"

#import <JFFUtils/JFFCastFunctions.hpp>

@interface ObjCppCastingTest : GHTestCase
@end


@implementation ObjCppCastingTest

-(void)testNilIsCastedToNil
{
    NSString* result_ = nil;

    {
        result_ = objc_kind_of_cast<NSString>( nil );
        GHAssertNil( result_, @"nil expected" );
    }

    {
        result_ = objc_member_of_cast<NSString>( nil );
        GHAssertNil( result_, @"nil expected" );
    }
}

-(void)testStringToArrayCastReturnsNil
{
    NSString* christmasCheer_ = @"Merry Christmas";
    NSArray* result_ = nil;

    {
        result_ = objc_kind_of_cast<NSArray>( christmasCheer_ );
        GHAssertNil( result_, @"nil expected" );
    }

    {
        result_ = objc_member_of_cast<NSArray>( christmasCheer_ );
        GHAssertNil( result_, @"nil expected" );
    }
}

-(void)testStringToStringCastReturnsValidObject
{
    {
        id christmasCheer_ = @"Merry Christmas";
        NSString* result_ = objc_kind_of_cast<NSString>( christmasCheer_ );
        GHAssertNotNil( result_, @"unexpected nil object" );

        GHAssertTrue( [ christmasCheer_ isEqual: result_ ], @"A cast has changed an object" );
    }

    {
        JMStringHolder* result_ = nil;
        JMStringHolder* christmasCheer_ = [ JMStringHolder new ];
        christmasCheer_.content = @"Merry Christmas";

        result_ = objc_member_of_cast<JMStringHolder>( christmasCheer_ );
        GHAssertNotNil( result_, @"unexpected nil object" );
        GHAssertTrue( [ christmasCheer_.content isEqualToString: result_.content ], @"A cast has changed an object" );      
    }
}

-(void)testKindOfCastToSuperTypeReturnsSameObject
{
    JMStringHolder* christmasCheer_ = [ JMStringHolder new ];
    christmasCheer_.content = @"Merry Christmas";

    id result_ = nil;

    {
        result_ = objc_kind_of_cast<NSObject>( christmasCheer_ );
        GHAssertTrue( christmasCheer_ == result_, @"same object expected" );
    }
}

@end
