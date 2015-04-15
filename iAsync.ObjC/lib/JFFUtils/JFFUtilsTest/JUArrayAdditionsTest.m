#import "JUArrayAdditionsTest.h"

@implementation JUArrayAdditionsTest

-(void)testIsEqualVersionWorksCorrectly
{
    NSArray *items    = nil;
    NSArray *received = nil;
    NSArray *expected = nil;
    
    {
        items = @[@"abra"
        , @"shwabra"
        , @"kadabra"
        , @"abra"
        , @"habra"
        , @"kadabra"
        , @"ABra"];
        
        received = [items unique];
        expected = @[@"abra"
        , @"shwabra"
        , @"kadabra"
        , @"habra"
        , @"ABra"];
        
        XCTAssertTrue([received isEqualToArray:expected], @"Arrays mismatch");
    }
    
    {
        items = @[@"one"
        , @"two"
        , @"three"
        , @"two"
        , @"one"
        , @"four"
        , @"five"
        , @"one"];
        
        received = [items unique];
        expected = @[@"one"
        , @"two"
        , @"three"
        , @"four"
        , @"five"];
        
        XCTAssertTrue([received isEqualToArray:expected], @"Arrays mismatch");
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
    NSArray* items    = nil;
    NSArray* received = nil;
    NSArray* expected = nil;
    
    JFFEqualityCheckerBlock predicate = ^(id left, id right)
    {
        NSComparisonResult result1 = [left  caseInsensitiveCompare:right];
        NSComparisonResult result2 = [right caseInsensitiveCompare:left  ];
        
        BOOL resultEqual = (result1       == result2);
        BOOL resultSame  = (NSOrderedSame == result2);
        
        return (BOOL)(resultSame && resultEqual);
    };
    
    {
        items = @[ @"abra"
        , @"shwabra"
        , @"kadabra"
        , @"abRa"
        , @"habra"
        , @"KAdabRA"
        , @"ABra" ];
        
        received = [items uniqueBy:predicate];
        expected = @[ @"abra"
        , @"shwabra"
        , @"kadabra"
        , @"habra"];
        
        XCTAssertTrue([received isEqualToArray:expected], @"Arrays mismatch");
    }
    
    {
        items = @[@"one"
        , @"Two"
        , @"THREE"
        , @"two"
        , @"One"
        , @"four"
        , @"five"
        , @"ONE"];
        
        received = [items uniqueBy:predicate];
        expected = @[ @"one"
        , @"Two"
        , @"THREE"
        , @"four"
        , @"five" ];
        
        XCTAssertTrue([received isEqualToArray:expected], @"Arrays mismatch");
    }
}

@end
