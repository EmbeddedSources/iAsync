
@interface EmptyStringTest : GHTestCase

@end

@implementation EmptyStringTest

-(void)RtestNilStringIsEmpty
{
    NSString* str_ = nil;
    GHAssertFalse( [ str_ hasSymbols ], @"Nil String[%@] should have no symbols", str_ );
}

-(void)RtestEmptyStringIsEmpty
{
    {
        NSString* str_ = @"";
        GHAssertFalse( [ str_ hasSymbols ], @"Nil String[%@] should have no symbols", str_ );
    }

    {
        NSMutableString* empty_ = [ NSMutableString stringWithString: @"" ];
        NSString* str_ = [ NSString stringWithString: empty_ ];
        GHAssertFalse( [ str_ hasSymbols ], @"Nil String[%@] should have no symbols", str_ );
    }

    {
        NSMutableString* empty_ = [ NSMutableString stringWithString: @"" ];
        NSString* str_ = [ empty_ copy ];
        GHAssertFalse( [ str_ hasSymbols ], @"Nil String[%@] should have no symbols", str_ );
    }
}

-(void)RtestStringWithCharactersIsNotEmpty
{
    NSString* str_ = @"abrakadabre";
    GHAssertTrue( [ str_ hasSymbols ], @"The String[%@] should have some symbols", str_ );
}

@end
