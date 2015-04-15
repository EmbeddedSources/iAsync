#import "NSObject_IsEqualTwoObjectsTest.h"

@implementation NSObject_IsEqualTwoObjectsTest

-(void)testIsEqualTwoObjects
{
    {
        NSObject *object1;
        NSObject *object2;
        
        XCTAssertTrue([NSObject object: object1
                            isEqualTo: object2]);
    }
    
    {
        NSObject *object1 = [NSObject new];
        NSObject *object2 = [NSObject new];
        
        XCTAssertFalse([NSObject object: object1
                             isEqualTo: object2]);
    }
    
    {
        NSObject *object1 = [NSObject new];
        NSObject *object2 = object1;
        
        XCTAssertTrue([NSObject object: object1
                            isEqualTo: object2]);
    }
    
    {
        NSObject *object1;
        NSObject *object2 = @"";
        
        XCTAssertFalse([NSObject object: object1
                             isEqualTo: object2]);
    }
    
    {
        NSObject *object1 = @"";
        NSObject *object2;
        
        XCTAssertFalse([NSObject object: object1
                             isEqualTo: object2]);
    }
    
    {
        NSObject *object1 = @"";
        NSObject *object2 = @"";
        
        XCTAssertTrue([NSObject object: object1
                            isEqualTo: object2]);
    }
}

@end
