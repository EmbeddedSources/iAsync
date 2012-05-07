#import <JFFUtils/JFFMutableAssignArray.h>

@interface JFFMutableAssignArrayTest : GHTestCase
@end

@implementation JFFMutableAssignArrayTest

-(void)testMutableAssignArrayAssignIssue
{
    JFFMutableAssignArray* array_ = nil;

    {
        __weak NSObject* weakTarget_;

        {
            NSObject* target_ = [ NSObject new ];

            weakTarget_ = target_;

            JFFMutableAssignArray* array_ = [ JFFMutableAssignArray new ];
            [ array_ addObject: target_ ];

            GHAssertTrue( 1 == [ array_ count ], @"Contains 1 object" );
        }

        GHAssertNil( weakTarget_, @"Target should be dealloced" );
    }
    GHAssertTrue( 0 == [ array_ count ], @"Empty array" );
}

-(void)testMutableAssignArrayFirstRelease
{
    __weak JFFMutableAssignArray* weakArray_;
    {
        JFFMutableAssignArray* array_ = [ JFFMutableAssignArray new ];

        weakArray_ = array_;

        NSObject* target_ = [ NSObject new ];
        [ array_ addObject: target_ ];
    }

    GHAssertNil( weakArray_, @"Target should be dealloced" );
}

-(void)testContainsObject
{
    JFFMutableAssignArray* array_;
    {
        array_ = [ JFFMutableAssignArray new ];

        NSObject* object1_ = [ NSObject new ];
        NSObject* object2_ = [ NSObject new ];
        [ array_ addObject: object1_ ];

        GHAssertTrue( [ array_ containsObject: object1_ ], @"Array contains object1_" );
        GHAssertFalse( [ array_ containsObject: object2_ ], @"Array no contains object2_" );
    }

    GHAssertTrue( 0 == [ array_ count ], @"Empty array" );
}

@end
