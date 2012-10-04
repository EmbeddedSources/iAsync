#import "NumberOfCharacterFromStringTest.h"

@implementation NumberOfCharacterFromStringTest

-(void)testNumberOfCharacterFromString
{
    STAssertEquals((NSUInteger)0, [@"" numberOfCharacterFromString: @""], nil);
    
    STAssertEquals((NSUInteger)0, [@"" numberOfCharacterFromString: @"1"], nil);
    
    STAssertEquals((NSUInteger)2, [@"11" numberOfCharacterFromString: @"1"], nil);
    
    STAssertEquals((NSUInteger)2, [@"21212" numberOfCharacterFromString: @"1"], nil);
    
    STAssertEquals((NSUInteger)5, [@"00021212000" numberOfCharacterFromString: @"21"], nil);
    
    STAssertEquals((NSUInteger)7, [@"00032123120000" numberOfCharacterFromString: @"213"], nil);
}

-(void)testNumberOfStringsFromString
{
    STAssertEquals((NSUInteger)3, [@"aaa" numberOfStringsFromString: @"a" ], nil);
    
    STAssertEquals((NSUInteger)1, [@"aaa" numberOfStringsFromString: @"aa" ], nil);
    
    STAssertEquals((NSUInteger)1, [@"ab a" numberOfStringsFromString: @"ab" ], nil);
    
    STAssertEquals((NSUInteger)1, [@"a abc" numberOfStringsFromString: @"abc" ], nil);
    
    STAssertEquals((NSUInteger)0, [@"a ab c" numberOfStringsFromString: @"abc" ], nil);
    
    STAssertEquals((NSUInteger)3, [@"ababab" numberOfStringsFromString: @"ab" ], nil);
}

@end
