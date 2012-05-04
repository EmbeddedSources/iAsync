
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

@end
