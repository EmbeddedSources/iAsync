#import "EmptyStringTest.h"

#import "NSString+IsEmpty.h"

@implementation EmptyStringTest

- (void)testNilStringIsEmpty
{
    NSString *str;
    STAssertFalse([str hasSymbols], @"Nil String[%@] should have no symbols", str);
}

- (void)testEmptyStringIsEmpty
{
    {
        NSString *str = @"";
        STAssertFalse([str hasSymbols], @"Nil String[%@] should have no symbols", str);
    }
    
    {
        NSMutableString* empty = [NSMutableString stringWithString:@""];
        NSString* str = [empty copy];
        STAssertFalse([str hasSymbols], @"Nil String[%@] should have no symbols", str);
    }
    
    {
        NSMutableString* empty = [NSMutableString stringWithString:@""];
        NSString *str = [empty copy];
        STAssertFalse( [str hasSymbols], @"Nil String[%@] should have no symbols", str);
    }
}

- (void)testStringWithCharactersIsNotEmpty
{
    NSString *str = @"abrakadabre";
    STAssertTrue([str hasSymbols], @"The String[%@] should have some symbols", str);
}

@end
