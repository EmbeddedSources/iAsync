
@interface NumberOfCharacterFromStringTest : GHTestCase
@end

@implementation NumberOfCharacterFromStringTest

-(void)testNumberOfCharacterFromString
{
    GHAssertEquals( (NSUInteger)0, [ @"" numberOfCharacterFromString: @"" ], @"OK" );

    GHAssertEquals( (NSUInteger)0, [ @"" numberOfCharacterFromString: @"1" ], @"OK" );

    GHAssertEquals( (NSUInteger)2, [ @"11" numberOfCharacterFromString: @"1" ], @"OK" );

    GHAssertEquals( (NSUInteger)2, [ @"21212" numberOfCharacterFromString: @"1" ], @"OK" );

    GHAssertEquals( (NSUInteger)5, [ @"00021212000" numberOfCharacterFromString: @"21" ], @"OK" );

    GHAssertEquals( (NSUInteger)7, [ @"00032123120000" numberOfCharacterFromString: @"213" ], @"OK" );
}

-(void)testNumberOfStringsFromString
{
    GHAssertEquals( (NSUInteger)3, [ @"aaa" numberOfStringsFromString: @"a" ], @"OK" );

    GHAssertEquals( (NSUInteger)1, [ @"aaa" numberOfStringsFromString: @"aa" ], @"OK" );

    GHAssertEquals( (NSUInteger)1, [ @"ab a" numberOfStringsFromString: @"ab" ], @"OK" );

    GHAssertEquals( (NSUInteger)1, [ @"a abc" numberOfStringsFromString: @"abc" ], @"OK" );

    GHAssertEquals( (NSUInteger)0, [ @"a ab c" numberOfStringsFromString: @"abc" ], @"OK" );

    GHAssertEquals( (NSUInteger)3, [ @"ababab" numberOfStringsFromString: @"ab" ], @"OK" );
}

@end
