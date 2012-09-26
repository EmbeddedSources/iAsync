#import "NSObject_IsEqualTwoObjectsTest.h"

@implementation NSObject_IsEqualTwoObjectsTest

-(void)testIsEqualTwoObjects
{
    {
        NSObject *object1;
        NSObject *object2;
        
        STAssertTrue([NSObject object: object1
                            isEqualTo: object2], @"OK");
    }
    
    {
        NSObject *object1 = [NSObject new];
        NSObject *object2 = [NSObject new];
        
        STAssertFalse([NSObject object: object1
                             isEqualTo: object2], @"OK");
    }
    
    {
        NSObject *object1 = [NSObject new];
        NSObject *object2 = object1;
        
        STAssertTrue([NSObject object: object1
                            isEqualTo: object2], @"OK");
    }
    
    {
        NSObject *object1;
        NSObject *object2 = @"";
        
        STAssertFalse([NSObject object: object1
                             isEqualTo: object2], @"OK");
    }
    
    {
        NSObject *object1 = @"";
        NSObject *object2;
        
        STAssertFalse([NSObject object: object1
                             isEqualTo: object2], @"OK");
    }
    
    {
        NSObject *object1 = @"";
        NSObject *object2 = @"";
        
        STAssertTrue([NSObject object: object1
                            isEqualTo: object2], @"OK" );
    }
}

@end
