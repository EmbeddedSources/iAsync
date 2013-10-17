#import "JUMutableArrayTest.h"

@implementation JUMutableArrayTest

-(void)testEmptyArrayRemainsEmptyOnShrink
{
    NSMutableArray* items_ = [ @[] mutableCopy ];
    
    STAssertNotNil( items_               , @"Array should be empty" );
    STAssertTrue  ( 0 == [ items_ count ], @"Array should be empty" );
    
    [ items_ shrinkToSize: 234 ];
    STAssertNotNil( items_               , @"Array should be empty" );
    STAssertTrue  ( 0 == [ items_ count ], @"Array should be empty" );
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
    
    STAssertNotNil( items_               , @"Array should be valid"     );
    STAssertTrue  ( 7 == [ items_ count ], @"Array should have 7 items" );
    
    [ items_ shrinkToSize: 0 ];
    STAssertNotNil( items_               , @"Array should be empty" );
    STAssertTrue  ( 0 == [ items_ count ], @"Array should be empty" );
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
        
        STAssertNotNil( items_               , @"Array should be valid"     );
        STAssertTrue  ( 7 == [ items_ count ], @"Array should have 7 items" );
        
        [ items_ shrinkToSize: 100 ];
        STAssertNotNil( items_               , @"Array should be valid"     );
        STAssertTrue  ( 7 == [ items_ count ], @"Array should have 7 items" );
        
        STAssertTrue( [ [ items_ lastObject ] isEqualToString: @"seven" ], @"Last item mismatch" );
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
        
        STAssertNotNil( items               , @"Array should be valid"     );
        STAssertTrue  ( 7 == [ items count ], @"Array should have 7 items" );
        
        [items shrinkToSize:3];
        STAssertNotNil( items               , @"Array should be valid"     );
        STAssertTrue  ( 3 == [ items count ], @"Array should have 3 items" );
        
        STAssertTrue( [ [ items lastObject ] isEqualToString: @"three" ], @"Last item mismatch" );
    }
    
    {
        items = [ @[ @"one"
                  , @"two"
                  , @"three"
                  , @"four"
                  , @"five"
                  , @"six"
                  , @"seven" ] mutableCopy ];
        
        STAssertNotNil( items               , @"Array should be valid"     );
        STAssertTrue  ( 7 == [ items count ], @"Array should have 7 items" );
        
        [ items shrinkToSize: 5 ];
        STAssertNotNil( items               , @"Array should be valid"     );
        STAssertTrue  ( 5 == [ items count ], @"Array should have 5 items" );
        
        STAssertTrue( [ [ items lastObject ] isEqualToString: @"five" ], @"Last item mismatch" );
    }
}

@end
