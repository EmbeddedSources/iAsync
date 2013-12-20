#import "JFFMutableAssignArrayTest.h"

@implementation JFFMutableAssignArrayTest

- (void)testMutableAssignArrayAssignIssue
{
    JFFMutableAssignArray *array = nil;
    
    {
        __weak NSObject *weakTarget;
        
        {
            NSObject *target = [NSObject new];
            
            weakTarget = target;
            
            JFFMutableAssignArray *array = [JFFMutableAssignArray new];
            [array addObject:target];
            
            XCTAssertTrue(1 == [array count], @"Contains 1 object");
        }
        
        XCTAssertNil(weakTarget, @"Target should be dealloced");
    }
    XCTAssertTrue(0 == [array count], @"Empty array");
}

- (void)testMutableAssignArrayFirstRelease
{
    __weak JFFMutableAssignArray *weakArray;
    {
        JFFMutableAssignArray *array = [JFFMutableAssignArray new];
        
        weakArray = array;
        
        NSObject *target = [NSObject new];
        [array addObject:target];
    }
    
    XCTAssertNil(weakArray, @"Target should be dealloced");
}

- (void)testLastObject
{
    JFFMutableAssignArray *array = [JFFMutableAssignArray new];
    
    NSObject *object = [NSObject new];
    [array addObject:object];
    
    XCTAssertTrue(object == [array lastObject], @"Target should be dealloced");
}

- (void)testContainsObject
{
    @autoreleasepool {
        JFFMutableAssignArray *array;
        
        __weak NSObject *object1Ptr;
        
        __block BOOL onDeallocBlockCalled = NO;
        {
            array = [JFFMutableAssignArray new];
            
            NSObject *object1 = [NSObject new];
            object1Ptr = object1;
            [object1 addOnDeallocBlock:^{
                onDeallocBlockCalled = YES;
            }];
            NSObject *object2 = [NSObject new];
            [array addObject: object1];
            
            XCTAssertTrue ([array containsObject:object1], @"Array contains object1"   );
            XCTAssertFalse([array containsObject:object2], @"Array no contains object2");
        }
        
        XCTAssertTrue(onDeallocBlockCalled, @"EonDeallocBlock called");
        XCTAssertTrue(0 == [array count], @"Empty array");
        XCTAssertNil(object1Ptr, @"Empty array");
    }
}

@end
