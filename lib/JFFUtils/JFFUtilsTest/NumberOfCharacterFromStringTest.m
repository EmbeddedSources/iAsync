#import "NumberOfCharacterFromStringTest.h"

@implementation NumberOfCharacterFromStringTest

-(void)testNumberOfCharacterFromString
{
    XCTAssertEqual((NSUInteger)0, [@"" numberOfCharacterFromString: @""]);
    
    XCTAssertEqual((NSUInteger)0, [@"" numberOfCharacterFromString: @"1"]);
    
    XCTAssertEqual((NSUInteger)2, [@"11" numberOfCharacterFromString: @"1"]);
    
    XCTAssertEqual((NSUInteger)2, [@"21212" numberOfCharacterFromString: @"1"]);
    
    XCTAssertEqual((NSUInteger)5, [@"00021212000" numberOfCharacterFromString: @"21"]);
    
    XCTAssertEqual((NSUInteger)7, [@"00032123120000" numberOfCharacterFromString: @"213"]);
}

-(void)testNumberOfStringsFromString
{
    XCTAssertEqual((NSUInteger)3, [@"aaa" numberOfStringsFromString: @"a" ]);
    
    XCTAssertEqual((NSUInteger)1, [@"aaa" numberOfStringsFromString: @"aa" ]);
    
    XCTAssertEqual((NSUInteger)1, [@"ab a" numberOfStringsFromString: @"ab" ]);
    
    XCTAssertEqual((NSUInteger)1, [@"a abc" numberOfStringsFromString: @"abc" ]);
    
    XCTAssertEqual((NSUInteger)0, [@"a ab c" numberOfStringsFromString: @"abc" ]);
    
    XCTAssertEqual((NSUInteger)3, [@"ababab" numberOfStringsFromString: @"ab" ]);
}

@end
