#import <JFFUtils/JFFAssignProxy.h>

@interface ProxyTargetTest : NSObject

@end

@implementation ProxyTargetTest

-(NSUInteger)justReturnFiveNumber
{
    return 5;
}

@end

@interface JFFAssignProxyTest : GHTestCase
@end

@implementation JFFAssignProxyTest

-(void)testAssignProxyDealloc
{
    JFFAssignProxy* proxy_ = nil;
    __block BOOL targetDeallocated_ = NO;

    @autoreleasepool
    {
        ProxyTargetTest* target_ = [ ProxyTargetTest new ];
        [ target_ addOnDeallocBlock: ^void( void )
        {
            targetDeallocated_ = YES;
        } ];

        proxy_ = [ [ JFFAssignProxy alloc ] initWithTarget: target_ ];
    }

    GHAssertTrue( targetDeallocated_, @"Target should be dealloced" );
}

-(void)testAssignProxyMethodCalls
{
    ProxyTargetTest* target_ = [ ProxyTargetTest new ];

    id proxy_ = [ [ JFFAssignProxy alloc ] initWithTarget: target_ ];
    GHAssertTrue( 5 == [ proxy_ justReturnFiveNumber ], @"Target should be dealloced" );
}

@end
