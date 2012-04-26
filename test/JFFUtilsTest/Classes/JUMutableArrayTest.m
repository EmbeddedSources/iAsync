@interface JUMutableArrayTest : GHTestCase 
@end

@implementation JUMutableArrayTest

-(void)testEmptyArrayRemainsEmptyOnShrink
{
    NSMutableArray* items_ = [ NSMutableArray array ];

    GHAssertNotNil( items_               , @"Array should be empty" );
    GHAssertTrue  ( 0 == [ items_ count ], @"Array should be empty" );

    [ items_ shrinkToSize: 234 ];
    GHAssertNotNil( items_               , @"Array should be empty" );
    GHAssertTrue  ( 0 == [ items_ count ], @"Array should be empty" );   
}

-(void)testArrayBecomesEmptyForZeroArg
{
    NSMutableArray* items_ = [ NSMutableArray arrayWithObjects: 
                              @"one"
                              , @"two"
                              , @"three"
                              , @"four"
                              , @"five"
                              , @"six"
                              , @"seven"
                              , nil ];

    GHAssertNotNil( items_               , @"Array should be valid"     );
    GHAssertTrue  ( 7 == [ items_ count ], @"Array should have 7 items" );

    [ items_ shrinkToSize: 0 ];
    GHAssertNotNil( items_               , @"Array should be empty" );
    GHAssertTrue  ( 0 == [ items_ count ], @"Array should be empty" ); 
}

-(void)testArrayDoesNotGrowOnShrinks
{
    NSMutableArray* items_ = nil;

    {
        items_ = [ NSMutableArray arrayWithObjects:
                  @"one"
                  , @"two"
                  , @"three"
                  , @"four"
                  , @"five"
                  , @"six"
                  , @"seven"
                  , nil ];

        GHAssertNotNil( items_               , @"Array should be valid"     );
        GHAssertTrue  ( 7 == [ items_ count ], @"Array should have 7 items" );

        [ items_ shrinkToSize: 100 ];
        GHAssertNotNil( items_               , @"Array should be valid"     );
        GHAssertTrue  ( 7 == [ items_ count ], @"Array should have 7 items" );

        GHAssertTrue( [ [ items_ lastObject ] isEqualToString: @"seven" ], @"Last item mismatch" );
    }
}

-(void)testArrayShrinksCorrectly
{
    NSMutableArray* items_ = nil;

    {
        items_ = [ NSMutableArray arrayWithObjects: 
                        @"one" 
                        , @"two" 
                        , @"three" 
                        , @"four" 
                        , @"five" 
                        , @"six" 
                        , @"seven" 
                        , nil ];

        GHAssertNotNil( items_               , @"Array should be valid"     );
        GHAssertTrue  ( 7 == [ items_ count ], @"Array should have 7 items" );

        [ items_ shrinkToSize: 3 ];
        GHAssertNotNil( items_               , @"Array should be valid"     );
        GHAssertTrue  ( 3 == [ items_ count ], @"Array should have 3 items" );

        GHAssertTrue( [ [ items_ lastObject ] isEqualToString: @"three" ], @"Last item mismatch" );
    }

    {
        items_ = [ NSMutableArray arrayWithObjects: 
                  @"one" 
                  , @"two" 
                  , @"three" 
                  , @"four" 
                  , @"five" 
                  , @"six" 
                  , @"seven" 
                  , nil ];

        GHAssertNotNil( items_               , @"Array should be valid"     );
        GHAssertTrue  ( 7 == [ items_ count ], @"Array should have 7 items" );

        [ items_ shrinkToSize: 5 ];
        GHAssertNotNil( items_               , @"Array should be valid"     );
        GHAssertTrue  ( 5 == [ items_ count ], @"Array should have 5 items" );

        GHAssertTrue( [ [ items_ lastObject ] isEqualToString: @"five" ], @"Last item mismatch" );
    }
}

@end
