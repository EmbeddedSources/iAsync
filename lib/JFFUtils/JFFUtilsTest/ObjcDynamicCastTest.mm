#import "ObjcDynamicCastTest.h"

#import "JMChild.h"

#import <JFFUtils/JFFCastFunctions.hpp>

@implementation ObjcDynamicCastTest

- (void)testDynamicCastReturnsNilForNil
{
    JMParent *parent;
    JMChild  *result;
    
    {
        result = objc_dynamic_cast<JMChild>(parent);
        XCTAssertNil(result, @"nil expected");
    }
}

- (void)testDynamicCastReturnsNilForChildren
{
    JMParent *parent = [JMParent new];
    id result;
    
    {
        result = objc_dynamic_cast<JMChild>(parent);
        XCTAssertNil(result, @"nil expected");
    }
}

-(void)testDynamicCastToSameTypeReturnsSameObject
{
    JMParent* parent = [JMParent new];
    id result;
    
    {
        result = objc_dynamic_cast<JMParent>(parent);
        XCTAssertNotNil(result, @"nil expected");
        XCTAssertTrue(result == parent, @"same object expected");
    }
}

-(void)testDynamicCastReturnsSameObjectForValidHierarchy
{
    JMChild  *child   = [JMChild new];
    JMParent *p_child = (JMParent*)child;
        
    NSObject *o_child = (NSObject*)child;
    
    id result;
    
    {
        result = objc_dynamic_cast<JMChild>(p_child);
        XCTAssertNotNil(result, @"nil expected");
        XCTAssertTrue(result == p_child, @"same object expected");
    }
    
    {
        result = objc_dynamic_cast<JMParent>(o_child);
        XCTAssertNotNil(result, @"nil expected" );
        XCTAssertTrue(result == p_child, @"same object expected");
        
        result = objc_dynamic_cast<JMChild>(o_child);
        XCTAssertNotNil(result, @"nil expected" );
        XCTAssertTrue(result == p_child, @"same object expected");
    }
}

@end