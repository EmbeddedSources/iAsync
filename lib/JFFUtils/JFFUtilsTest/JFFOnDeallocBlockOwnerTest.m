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
        } ];
        
        JFFOnDeallocBlockOwner *owner = [[JFFOnDeallocBlockOwner alloc] initWithBlock:^void(void) {
            if ([blockContext description])
                blockCalled = YES;
        } ];
        
        STAssertFalse(blockContextDeallocated && owner, @"Block context should not be dealloced");
        STAssertFalse(blockCalled, @"block should not be called here");
    }
    
    STAssertTrue(blockContextDeallocated, @"Block context should be dealloced");
    STAssertTrue(blockCalled, @"block should be called here");
}

- (void)testDoNotCallOnDeallocBlockAfterRemoveIt
{
    __block BOOL blockCalled = NO;
    
    @autoreleasepool {
        NSObject *owner = [NSObject new];
        
        void(^onDeallocBloc)(void) = [^void(void) {
            blockCalled = YES;
        } copy];
        
        [owner addOnDeallocBlock:onDeallocBloc];
        
        STAssertFalse(blockCalled, nil);
        
        [owner removeOnDeallocBlock:onDeallocBloc];
    }
    
    STAssertFalse(blockCalled, nil);
}

@end
