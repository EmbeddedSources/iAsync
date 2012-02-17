#import <JFFUtils/JFFMulticastDelegate.h>

@protocol TestMulticastDelegateInterface < NSObject >

@required
-(NSUInteger)justReturnFiveNumber;

@end

@interface TestClassForMulticast : NSObject < TestMulticastDelegateInterface >

@property ( nonatomic, unsafe_unretained ) NSUInteger initialState;

@end

@implementation TestClassForMulticast

@synthesize initialState;

-(NSUInteger)justReturnFiveNumber
{
   return self.initialState++;
}

@end

@interface JFFMulticastDelegateTest : GHTestCase
@end

@implementation JFFMulticastDelegateTest

-(void)testMutableAssignArrayAssignIssue
{
    __block BOOL delegate_deallocated_ = NO;

    JFFMulticastDelegate< TestMulticastDelegateInterface >* multicast_ =
        (JFFMulticastDelegate< TestMulticastDelegateInterface >*)[ JFFMulticastDelegate new ];

    @autoreleasepool
    {
        TestClassForMulticast* delegate_ = [ TestClassForMulticast new ];
        NSUInteger init_state_ = rand();
        delegate_.initialState = init_state_;

        [ delegate_ addOnDeallocBlock: ^void( void )
        {
            delegate_deallocated_ = YES;
        } ];

        [ multicast_ addDelegate: delegate_ ];

        GHAssertTrue( init_state_ == [ multicast_ justReturnFiveNumber ], @"Contains 1 object" );

        [ delegate_ release ];
    }

    GHAssertTrue( delegate_deallocated_, @"Target should be dealloced" );
    GHAssertTrue( 0 == [ multicast_ justReturnFiveNumber ], @"Empty array" );

    [ multicast_ release ];
}

-(void)testMulticastDelegateFirstRelease
{
   JFFMulticastDelegate< TestMulticastDelegateInterface >* multicast_ =
      (JFFMulticastDelegate< TestMulticastDelegateInterface >*)[ JFFMulticastDelegate new ];

   __block BOOL multicast_deallocated_ = NO;
   [ multicast_ addOnDeallocBlock: ^void( void )
   {
      multicast_deallocated_ = YES;
   } ];

   NSObject* delegate_ = [ NSObject new ];
   [ multicast_ addDelegate: delegate_ ];

   [ multicast_ release ];

   GHAssertTrue( multicast_deallocated_, @"Target should be dealloced" );

   [ delegate_ release ];
}

-(void)testAddDelegateTwice
{
   JFFMulticastDelegate< TestMulticastDelegateInterface >* multicast_ =
      (JFFMulticastDelegate< TestMulticastDelegateInterface >*)[ JFFMulticastDelegate new ];

   TestClassForMulticast* delegate_ = [ TestClassForMulticast new ];
   delegate_.initialState = 5;

   [ multicast_ addDelegate: delegate_ ];

   GHAssertTrue( 5 == [ multicast_ justReturnFiveNumber ], @"Contains 1 object" );

   [ delegate_ release ];
   [ multicast_ release ];
}

@end
