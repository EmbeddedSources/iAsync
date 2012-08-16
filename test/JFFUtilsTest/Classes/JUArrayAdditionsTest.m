@interface JUArrayAdditionsTest : GHTestCase
@end

@implementation JUArrayAdditionsTest

-(void)testIsEqualVersionWorksCorrectly
{
    NSArray* items_    = nil;
    NSArray* received_ = nil;
    NSArray* expected_ = nil;

    {
        items_ = @[ @"abra"
                  , @"shwabra"
                  , @"kadabra"
                  , @"abra"
                  , @"habra"
                  , @"kadabra"
                  , @"ABra" ];

        received_ = [ items_ unique ];
        expected_ = @[  @"abra"
                     , @"shwabra"
                     , @"kadabra"
                     , @"habra"
                     , @"ABra" ];

        GHAssertTrue( [ received_ isEqualToArray: expected_ ], @"Arrays mismatch" );
    }

    {
        items_ = @[ @"one"
                  , @"two"
                  , @"three"
                  , @"two"
                  , @"one"
                  , @"four"
                  , @"five"
                  , @"one" ];

        received_ = [ items_ unique ];
        expected_ = @[ @"one"
                     , @"two"
                     , @"three"
                     , @"four"
                     , @"five" ];

        GHAssertTrue( [ received_ isEqualToArray: expected_ ], @"Arrays mismatch" );
    }
}

-(void)testIsEqualVersionWorksWithEmptyArray
{
    NSArray* items_    = nil;
    NSArray* received_ = nil;
    NSArray* expected_ = nil;

    {
        items_ = @[];

        received_ = [ items_ unique ];
        expected_ = items_;

        GHAssertTrue( [ received_ isEqualToArray: expected_ ], @"Arrays mismatch" );
    }
}


-(void)testBlockVersionWorksCorrectly
{
    NSArray* items_    = nil;
    NSArray* received_ = nil;
    NSArray* expected_ = nil;

    JFFEqualityCheckerBlock predicate_ = ^( id left_, id right_ )
    {
        NSComparisonResult result1_ = [ left_  caseInsensitiveCompare: right_ ];
        NSComparisonResult result2_ = [ right_ caseInsensitiveCompare: left_  ];

        BOOL resultEqual_ = ( result1_      == result2_ );
        BOOL resultSame_  = ( NSOrderedSame == result2_ );

        return (BOOL)( resultSame_ && resultEqual_ );
    };

    {
        items_ = @[ @"abra"
                  , @"shwabra"
                  , @"kadabra"
                  , @"abRa"
                  , @"habra"
                  , @"KAdabRA"
                  , @"ABra" ];

        received_ = [ items_ uniqueBy: predicate_ ];
        expected_ = @[ @"abra"
                     , @"shwabra"
                     , @"kadabra"
                     , @"habra" ];

        GHAssertTrue( [ received_ isEqualToArray: expected_ ], @"Arrays mismatch" );
    }
   
    {
        items_ = @[ @"one"
                  , @"Two"
                  , @"THREE"
                  , @"two"
                  , @"One"
                  , @"four"
                  , @"five"
                  , @"ONE" ];

        received_ = [ items_ uniqueBy: predicate_ ];
        expected_ = @[ @"one"
                     , @"Two"
                     , @"THREE"
                     , @"four"
                     , @"five" ];

        GHAssertTrue( [ received_ isEqualToArray: expected_ ], @"Arrays mismatch" );
    }
}


@end
