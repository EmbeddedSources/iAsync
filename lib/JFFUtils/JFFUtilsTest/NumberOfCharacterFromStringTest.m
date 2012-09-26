#import "NumberOfCharacterFromStringTest.h"

@implementation NumberOfCharacterFromStringTest

-(void)testNumberOfCharacterFromString
{
    STAssertEquals((NSUInteger)0, [@"" numberOfCharacterFromString: @""], @"OK");
    
    STAssertEquals((NSUInteger)0, [@"" numberOfCharacterFromString: @"1"], @"OK");
    
    STAssertEquals((NSUInteger)2, [@"11" numberOfCharacterFromString: @"1"], @"OK");
    
    STAssertEquals((NSUInteger)2, [@"21212" numberOfCharacterFromString: @"1"], @"OK");
    
    STAssertEquals((NSUInteger)5, [@"00021212000" numberOfCharacterFromString: @"21"], @"OK");
    
    STAssertEquals((NSUInteger)7, [@"00032123120000" numberOfCharacterFromString: @"213"], @"OK");
}

-(void)testNumberOfStringsFromString
{
    STAssertEquals((NSUInteger)3, [@"aaa" numberOfStringsFromString: @"a" ], @"OK");
    
    STAssertEquals((NSUInteger)1, [@"aaa" numberOfStringsFromString: @"aa" ], @"OK");
    
    STAssertEquals((NSUInteger)1, [@"ab a" numberOfStringsFromString: @"ab" ], @"OK");
    
    STAssertEquals((NSUInteger)1, [@"a abc" numberOfStringsFromString: @"abc" ], @"OK");
    
    STAssertEquals((NSUInteger)0, [@"a ab c" numberOfStringsFromString: @"abc" ], @"OK");
    
    STAssertEquals((NSUInteger)3, [@"ababab" numberOfStringsFromString: @"ab" ], @"OK");
}

@end
