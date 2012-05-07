#import "JMParent.h"
#import "JMChild.h"

#import <JFFUtils/JFFCastFunctions.hpp>

@interface ObjcDynamicCastTest : GHTestCase
@end

@implementation ObjcDynamicCastTest

-(void)testDynamicCastReturnsNilForNil
{
    JMParent* parent_ = nil;
    JMChild* result_ = nil;

    {
        result_ = objc_dynamic_cast<JMChild>( parent_ );
        GHAssertNil( result_, @"nil expected" );
    }
}

-(void)testDynamicCastReturnsNilForChildren
{
    JMParent* parent_ = [ JMParent new ];  
    id result_ = nil;

    {
        result_ = objc_dynamic_cast<JMChild>( parent_ );
        GHAssertNil( result_, @"nil expected" );      
    }
}

-(void)testDynamicCastToSameTypeReturnsSameObject
{
    JMParent* parent_ = [ JMParent new ];  
    id result_ = nil;

    {
        result_ = objc_dynamic_cast<JMParent>( parent_ );
        GHAssertNotNil( result_, @"nil expected" );      
        GHAssertTrue( result_ == parent_, @"same object expected" );
    }
}

-(void)testDynamicCastReturnsSameObjectForValidHierarchy
{
    JMChild * child_   = [ JMChild  new ];
    JMParent* p_child_ = (JMParent*)child_;

    NSObject* o_child_ = (NSObject*)child_;

    id result_ = nil;

    {
        result_ = objc_dynamic_cast<JMChild>( p_child_ );
        GHAssertNotNil( result_, @"nil expected" );      
        GHAssertTrue( result_ == p_child_, @"same object expected" );
    }

    {
        result_ = objc_dynamic_cast<JMParent>( o_child_ );
        GHAssertNotNil( result_, @"nil expected" );      
        GHAssertTrue( result_ == p_child_, @"same object expected" );

        result_ = objc_dynamic_cast<JMChild>( o_child_ );
        GHAssertNotNil( result_, @"nil expected" );      
        GHAssertTrue( result_ == p_child_, @"same object expected" );      
    }
}

@end
