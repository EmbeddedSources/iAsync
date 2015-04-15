#import "JFFOnDeallocBlockOwnerTest.h"

#import "JFFOnDeallocBlockOwner.h"

@implementation JFFOnDeallocBlockOwnerTest

- (void)testOnDeallocBlockOwnerBehavior
{
    __block BOOL blockCalled = NO;
    __block BOOL blockContextDeallocated = NO;
    
    @autoreleasepool {
        NSObject *blockContext = [NSObject new];
        [blockContext addOnDeallocBlock:^void(void) {
            blockContextDeallocated = YES;
        }];
        
        JFFOnDeallocBlockOwner *owner = [[JFFOnDeallocBlockOwner alloc] initWithBlock:^void(void) {
            if ([blockContext description])
                blockCalled = YES;
        }];
        
        XCTAssertFalse(blockContextDeallocated && owner, @"Block context should not be dealloced");
        XCTAssertFalse(blockCalled, @"block should not be called here");
    }
    
    XCTAssertTrue(blockContextDeallocated, @"Block context should be dealloced");
    XCTAssertTrue(blockCalled, @"block should be called here");
}

- (void)testDoNotCallOnDeallocBlockAfterRemoveIt
{
    __block BOOL blockCalled = NO;
    
    @autoreleasepool {
        NSObject *owner = [NSObject new];
        
        void(^onDeallocBlock)(void) = [^void(void) {
            blockCalled = YES;
        } copy];
        
        [owner addOnDeallocBlock:onDeallocBlock];
        
        XCTAssertFalse(blockCalled);
        
        [owner removeOnDeallocBlock:onDeallocBlock];
    }
    
    XCTAssertFalse(blockCalled);
}

@end
