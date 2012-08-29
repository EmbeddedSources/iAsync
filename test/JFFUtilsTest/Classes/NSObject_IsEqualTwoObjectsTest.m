
@interface NSObject_IsEqualTwoObjectsTest : GHTestCase
@end

@implementation NSObject_IsEqualTwoObjectsTest

-(void)testIsEqualTwoObjects
{
    {
        NSObject* object1_ = nil;
        NSObject* object2_ = nil;

        GHAssertTrue( [ NSObject object: object1_
                              isEqualTo: object2_ ], @"OK" );
    }

    {
        NSObject* object1_ = [ NSObject new ];
        NSObject* object2_ = [ NSObject new ];

        GHAssertFalse( [ NSObject object: object1_
                               isEqualTo: object2_ ], @"OK" );
    }

    {
        NSObject* object1_ = [ NSObject new ];
        NSObject* object2_ = object1_;

        GHAssertTrue( [ NSObject object: object1_
                              isEqualTo: object2_ ], @"OK" );
    }

    {
        NSObject* object1_ = nil;
        NSObject* object2_ = @"";

        GHAssertFalse( [ NSObject object: object1_
                               isEqualTo: object2_ ], @"OK" );
    }

    {
        NSObject* object1_ = @"";
        NSObject* object2_ = nil;

        GHAssertFalse( [ NSObject object: object1_
                               isEqualTo: object2_ ], @"OK" );
    }

    {
        NSObject* object1_ = @"";
        NSObject* object2_ = @"";

        GHAssertTrue( [ NSObject object: object1_
                              isEqualTo: object2_ ], @"OK" );
    }
}

@end
