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
    jClass_implementProperty([self class], @"dynamicWeakOwnedObject");
}

@end

@implementation JFFRuntimeAddiotionsTest

- (void)testWeakOwnerDynamicProperty
{
    @autoreleasepool
    {
        TestWeakOwnerClass *owner = [TestWeakOwnerClass new];
        
        STAssertNil(owner.dynamicWeakOwnedObject, nil);
        
        @autoreleasepool
        {
            NSObject *owned = [NSObject new];
            NSObject *owned2 = [NSObject new];
            
            owner.dynamicWeakOwnedObject = owned;
            STAssertNotNil(owner.dynamicWeakOwnedObject, nil);
            
            owner.normalWeakOwnedObject = owned2;
            STAssertNotNil(owner.normalWeakOwnedObject, nil);
        }
        
        STAssertNil(owner.dynamicWeakOwnedObject, nil);
        STAssertNil(owner.normalWeakOwnedObject, nil);
    }
    
    @autoreleasepool
    {
        NSObject *owned = [NSObject new];
        
        @autoreleasepool
        {
            TestWeakOwnerClass *owner = [TestWeakOwnerClass new];
            STAssertNil(owner.dynamicWeakOwnedObject, nil);
            
            owner.dynamicWeakOwnedObject = owned;
            STAssertNotNil(owner.dynamicWeakOwnedObject, nil);
        }
    }
}

@end
