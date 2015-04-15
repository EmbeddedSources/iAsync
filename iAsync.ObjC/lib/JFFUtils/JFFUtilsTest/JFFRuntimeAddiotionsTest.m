#import "JFFRuntimeAddiotionsTest.h"

#include "JFFRuntimeAddiotions.h"

@interface TestWeakOwnerClass : NSObject

@property (weak, nonatomic) id dynamicWeakOwnedObject;
@property (weak, nonatomic) id normalWeakOwnedObject;

@end

@implementation TestWeakOwnerClass

@dynamic dynamicWeakOwnedObject;

+ (void)load
{
    jClass_implementProperty([self class], NSStringFromSelector(@selector(dynamicWeakOwnedObject)));
}

@end

@implementation JFFRuntimeAddiotionsTest

- (void)testWeakOwnerDynamicProperty
{
    @autoreleasepool
    {
        TestWeakOwnerClass *owner = [TestWeakOwnerClass new];
        
        XCTAssertNil(owner.dynamicWeakOwnedObject, @"memory leak");
        
        @autoreleasepool
        {
            NSObject *owned = [NSObject new];
            NSObject *owned2 = [NSObject new];
            
            owner.dynamicWeakOwnedObject = owned;
            XCTAssertNotNil(owner.dynamicWeakOwnedObject, @"memory leak");
            
            owner.normalWeakOwnedObject = owned2;
            XCTAssertNotNil(owner.normalWeakOwnedObject, @"memory management issue");
        }
        
        XCTAssertNil(owner.dynamicWeakOwnedObject, @"memory leak");
        XCTAssertNil(owner.normalWeakOwnedObject, @"memory leak");
    }
    
    @autoreleasepool
    {
        NSObject *owned = [NSObject new];
        
        @autoreleasepool
        {
            TestWeakOwnerClass *owner = [TestWeakOwnerClass new];
            XCTAssertNil(owner.dynamicWeakOwnedObject, @"memory leak");
            
            owner.dynamicWeakOwnedObject = owned;
            XCTAssertNotNil(owner.dynamicWeakOwnedObject, @"memory leak");
        }
    }
}

@end
