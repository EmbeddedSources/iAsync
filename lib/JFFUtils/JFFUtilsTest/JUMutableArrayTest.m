#import "JUMutableArrayTest.h"

@implementation JUMutableArrayTest

-(void)testEmptyArrayRemainsEmptyOnShrink
{
    NSMutableArray* items_ = [ @[] mutableCopy ];
    
    XCTAssertNotNil( items_               , @"Array should be empty" );
    XCTAssertTrue  ( 0 == [ items_ count ], @"Array should be empty" );
    
    [ items_ shrinkToSize: 234 ];
    XCTAssertNotNil( items_               , @"Array should be empty" );
    XCTAssertTrue  ( 0 == [ items_ count ], @"Array should be empty" );
}

-(void)testArrayBecomesEmptyForZeroArg
{
    NSMutableArray* items_ = [ @[ @"one"
                              , @"two"
                              , @"three"
                              , @"four"
                              , @"five"
                              , @"six"
                              , @"seven" ] mutableCopy ];
    
    XCTAssertNotNil( items_               , @"Array should be valid"     );
    XCTAssertTrue  ( 7 == [ items_ count ], @"Array should have 7 items" );
    
    [ items_ shrinkToSize: 0 ];
    XCTAssertNotNil( items_               , @"Array should be empty" );
    XCTAssertTrue  ( 0 == [ items_ count ], @"Array should be empty" );
}

-(void)testArrayDoesNotGrowOnShrinks
{
    NSMutableArray* items_ = nil;
    
    {
        items_ = [ @[ @"one"
                  , @"two"
                  , @"three"
                  , @"four"
                  , @"five"
                  , @"six"
                  , @"seven" ] mutableCopy ];
        
        XCTAssertNotNil( items_               , @"Array should be valid"     );
        XCTAssertTrue  ( 7 == [ items_ count ], @"Array should have 7 items" );
        
        [ items_ shrinkToSize: 100 ];
        XCTAssertNotNil( items_               , @"Array should be valid"     );
        XCTAssertTrue  ( 7 == [ items_ count ], @"Array should have 7 items" );
        
        XCTAssertTrue( [ [ items_ lastObject ] isEqualToString: @"seven" ], @"Last item mismatch" );
    }
}

-(void)testArrayShrinksCorrectly
{
    NSMutableArray* items = nil;
    
    {
        items = [ @[ @"one"
                  , @"two"
                  , @"three"
                  , @"four"
                  , @"five"
                  , @"six"
                  , @"seven" ] mutableCopy ];

        XCTAssertNotNil( items               , @"Array should be valid"     );
        XCTAssertTrue  ( 7 == [ items count ], @"Array should have 7 items" );
        
        [ items shrinkToSize: 3 ];
        XCTAssertNotNil( items               , @"Array should be valid"     );
        XCTAssertTrue  ( 3 == [ items count ], @"Array should have 3 items" );
        
        XCTAssertTrue( [ [ items lastObject ] isEqualToString: @"three" ], @"Last item mismatch" );
    }
    
    {
        items = [ @[ @"one"
                  , @"two"
                  , @"three"
                  , @"four"
                  , @"five"
                  , @"six"
                  , @"seven" ] mutableCopy ];

        XCTAssertNotNil( items               , @"Array should be valid"     );
        XCTAssertTrue  ( 7 == [ items count ], @"Array should have 7 items" );
        
        [ items shrinkToSize: 5 ];
        XCTAssertNotNil( items               , @"Array should be valid"     );
        XCTAssertTrue  ( 5 == [ items count ], @"Array should have 5 items" );
        
        XCTAssertTrue( [ [ items lastObject ] isEqualToString: @"five" ], @"Last item mismatch" );
    }
}

@end
