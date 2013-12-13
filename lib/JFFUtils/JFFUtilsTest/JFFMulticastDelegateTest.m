#import "JFFMulticastDelegateTest.h"

@protocol TestMulticastDelegateInterface < NSObject >

@required
- (NSUInteger)justReturnFiveNumber;

@end

@interface TestClassForMulticast : NSObject < TestMulticastDelegateInterface >

@property (nonatomic, unsafe_unretained) NSUInteger initialState;

@end

@implementation TestClassForMulticast

@synthesize initialState;

- (NSUInteger)justReturnFiveNumber
{
    return self.initialState++;
}

@end

@implementation JFFMulticastDelegateTest

- (void)testMutableAssignArrayAssignIssue
{
    __block BOOL delegateDeallocated = NO;
    
    JFFMulticastDelegate< TestMulticastDelegateInterface > *multicast =
    (JFFMulticastDelegate< TestMulticastDelegateInterface >*)[JFFMulticastDelegate new];
    
    @autoreleasepool {
        TestClassForMulticast *delegate = [TestClassForMulticast new];
        NSUInteger initState_ = rand();
        delegate.initialState = initState_;
        
        [delegate addOnDeallocBlock:^void(void) {
            delegateDeallocated = YES;
        } ];
        
        [multicast addDelegate:delegate];
        
        STAssertTrue( initState_ == [ multicast justReturnFiveNumber ], @"Contains 1 object" );
    }
    
    STAssertTrue(delegateDeallocated, @"Target should be dealloced");
    STAssertTrue(0 == [multicast justReturnFiveNumber], @"Empty array");
}

- (void)testMulticastDelegateFirstRelease
{
    __block BOOL multicast_deallocated_ = NO;
    {
        JFFMulticastDelegate< TestMulticastDelegateInterface > *multicast =
        (JFFMulticastDelegate< TestMulticastDelegateInterface >*)[ JFFMulticastDelegate new ];
        
        [multicast addOnDeallocBlock:^void(void) {
            multicast_deallocated_ = YES;
        } ];
        
        NSObject *delegate = [NSObject new];
        [multicast addDelegate:delegate];
    }
    
    STAssertTrue( multicast_deallocated_, @"Target should be dealloced" );
}

- (void)testAddDelegateTwice
{
    JFFMulticastDelegate< TestMulticastDelegateInterface > *multicast =
    (JFFMulticastDelegate< TestMulticastDelegateInterface >*)[JFFMulticastDelegate new];
    
    TestClassForMulticast *delegate = [TestClassForMulticast new];
    delegate.initialState = 5;
    
    [multicast addDelegate:delegate];
    
    STAssertTrue(5 == [multicast justReturnFiveNumber], @"Contains 1 object");
}

@end
