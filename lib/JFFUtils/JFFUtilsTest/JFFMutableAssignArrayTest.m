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
            
            STAssertTrue(1 == [array count], @"Contains 1 object");
        }
        
        STAssertNil(weakTarget, @"Target should be dealloced");
    }
    STAssertTrue(0 == [array count], @"Empty array");
}

- (void)testMutableAssignArrayFirstRelease
{
    __weak JFFMutableAssignArray* weakArray;
    {
        JFFMutableAssignArray *array = [JFFMutableAssignArray new];
        
        weakArray = array;
        
        NSObject *target = [NSObject new];
        [array addObject:target];
    }
    
    STAssertNil(weakArray, @"Target should be dealloced");
}

- (void)testLastObject
{
    JFFMutableAssignArray *array = [JFFMutableAssignArray new];
    
    NSObject *object = [NSObject new];
    [array addObject:object];
    
    STAssertTrue(object == [array lastObject], @"Target should be dealloced");
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
            
            STAssertTrue ([array containsObject:object1], @"Array contains object1"   );
            STAssertFalse([array containsObject:object2], @"Array no contains object2");
        }
        
        STAssertTrue(onDeallocBlockCalled, @"EonDeallocBlock called");
        STAssertTrue(0 == [array count], @"Empty array");
        STAssertNil(object1Ptr, @"Empty array");
    }
}

@end
