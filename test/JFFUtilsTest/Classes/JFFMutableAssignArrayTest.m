#import <JFFUtils/JFFMutableAssignArray.h>

@interface JFFMutableAssignArrayTest : GHTestCase
@end

@implementation JFFMutableAssignArrayTest

-(void)testMutableAssignArrayAssignIssue
{
   NSObject* target_ = [ NSObject new ];

   __block BOOL target_deallocated_ = NO;
   [ target_ addOnDeallocBlock: ^void( void )
   {
      target_deallocated_ = YES;
   } ];

   JFFMutableAssignArray* array_ = [ JFFMutableAssignArray new ];
   [ array_ addObject: target_ ];

   GHAssertTrue( 1 == [ array_ count ], @"Contains 1 object" );

   [ target_ release ];

   GHAssertTrue( target_deallocated_, @"Target should be dealloced" );
   GHAssertTrue( 0 == [ array_ count ], @"Empty array" );

   [ array_ release ];
}

-(void)testMutableAssignArrayFirstRelease
{
   JFFMutableAssignArray* array_ = [ JFFMutableAssignArray new ];

   __block BOOL array_deallocated_ = NO;
   [ array_ addOnDeallocBlock: ^void( void )
   {
      array_deallocated_ = YES;
   } ];

   NSObject* target_ = [ NSObject new ];
   [ array_ addObject: target_ ];

   [ array_ release ];

   GHAssertTrue( array_deallocated_, @"Target should be dealloced" );

   [ target_ release ];
}

-(void)testContainsObject
{
   JFFMutableAssignArray* array_ = [ JFFMutableAssignArray new ];

   NSObject* object1_ = [ NSObject new ];
   NSObject* object2_ = [ [ NSObject new ] autorelease ];
   [ array_ addObject: object1_ ];

   GHAssertTrue( [ array_ containsObject: object1_ ], @"Array contains object1_" );
   GHAssertFalse( [ array_ containsObject: object2_ ], @"Array no contains object2_" );

   [ object1_ release ];

   GHAssertTrue( 0 == [ array_ count ], @"Empty array" );

   [ array_ release ];
}

@end
