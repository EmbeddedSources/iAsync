#import "JFFAssignProxyTest.h"

#import "JFFAssignProxy.h"

@interface ProxyTargetTest : NSObject

@end

@implementation ProxyTargetTest

- (NSUInteger)justReturnFiveNumber
{
    return 5;
}

@end

@implementation JFFAssignProxyTest

- (void)testAssignProxyDealloc
{
    JFFAssignProxy *proxy;
    __block BOOL targetDeallocated = NO;
    
    {
        ProxyTargetTest *target = [ProxyTargetTest new];
        [target addOnDeallocBlock: ^void(void) {
            targetDeallocated = YES;
        }];
        
        proxy = [[JFFAssignProxy alloc] initWithTarget:target];
    }
    
    XCTAssertTrue(targetDeallocated, @"Target should be dealloced");
}

- (void)testAssignProxyMethodCalls
{
    ProxyTargetTest *target_ = [ProxyTargetTest new];
    
    id proxy = [[JFFAssignProxy alloc] initWithTarget:target_];
    XCTAssertTrue( 5 == [ proxy justReturnFiveNumber ], @"Target should be dealloced" );
}

@end
