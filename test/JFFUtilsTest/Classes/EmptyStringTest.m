
@interface EmptyStringTest : GHTestCase
@end

@implementation EmptyStringTest

-(void)testNilStringIsEmpty
{
    NSString* str_ = nil;
    GHAssertFalse( [ str_ hasSymbols ], @"Nil String[%@] should have no symbols", str_ );
}

-(void)testEmptyStringIsEmpty
{
    {
        NSString* str_ = @"";
        GHAssertFalse( [ str_ hasSymbols ], @"Nil String[%@] should have no symbols", str_ );
    }

    {
        NSMutableString* empty_ = [ NSMutableString stringWithString: @"" ];
        NSString* str_ = [ empty_ copy ];
        GHAssertFalse( [ str_ hasSymbols ], @"Nil String[%@] should have no symbols", str_ );
    }

    {
        NSMutableString* empty_ = [ NSMutableString stringWithString: @"" ];
        NSString* str_ = [ empty_ copy ];
        GHAssertFalse( [ str_ hasSymbols ], @"Nil String[%@] should have no symbols", str_ );
    }
}

-(void)testStringWithCharactersIsNotEmpty
{
    NSString* str_ = @"abrakadabre";
    GHAssertTrue( [ str_ hasSymbols ], @"The String[%@] should have some symbols", str_ );
}

@end
