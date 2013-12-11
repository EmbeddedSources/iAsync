#import "JUArrayAdditionsTest.h"

@implementation JUArrayAdditionsTest

-(void)testIsEqualVersionWorksCorrectly
{
    NSArray *items    = nil;
    NSArray *received = nil;
    NSArray *expected = nil;
    
    {
        items = @[ @"abra"
        , @"shwabra"
        , @"kadabra"
        , @"abra"
        , @"habra"
        , @"kadabra"
        , @"ABra" ];
        
        received = [items unique];
        expected = @[@"abra"
        , @"shwabra"
        , @"kadabra"
        , @"habra"
        , @"ABra"];
        
        XCTAssertTrue( [ received isEqualToArray: expected ], @"Arrays mismatch" );
    }
    
    {
        items = @[ @"one"
        , @"two"
        , @"three"
        , @"two"
        , @"one"
        , @"four"
        , @"five"
        , @"one" ];
        
        received = [ items unique ];
        expected = @[ @"one"
        , @"two"
        , @"three"
        , @"four"
        , @"five" ];
        
        XCTAssertTrue( [ received isEqualToArray: expected ], @"Arrays mismatch" );
    }
}

-(void)testIsEqualVersionWorksWithEmptyArray
{
    NSArray * items    = nil;
    NSArray * received = nil;
    NSArray * expected = nil;
    
    {
        items = @[];
        
        received = [items unique];
        expected = items;
        
        XCTAssertTrue( [ received isEqualToArray: expected], @"Arrays mismatch" );
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
        
        XCTAssertTrue( [ received_ isEqualToArray: expected_ ], @"Arrays mismatch" );
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
        
        XCTAssertTrue( [ received_ isEqualToArray: expected_ ], @"Arrays mismatch" );
    }
}

@end
