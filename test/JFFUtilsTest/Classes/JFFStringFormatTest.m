@interface JFFStringFormatTest : GHTestCase 
@end

@implementation JFFStringFormatTest

-(void)testNotAllParamsPresent
{
    NSString* format_ = @"%@%@%@";
    NSString* param1_ = @"1";
    NSString* param2_ = @"2";

    NSString* result_ = [ NSString stringWithFormatCheckNill: format_, param1_, param2_, nil ];
    GHAssertTrue( result_ != nil, @"Should NOT be nil value" );
}

-(void)testOneMoreParam
{
    NSString* format_ = @"%@%@";
    NSString* param1_ = @"1";
    NSString* param2_ = @"2";
    NSString* param3_ = @"3";

    NSString* result_ = [ NSString stringWithFormatCheckNill: format_, param1_, param2_, param3_, nil ];
    GHAssertTrue( result_ != nil, @"Should NOT be nil value" );
}

@end
