@interface JFFStringFormatTest : GHTestCase 
@end

@implementation JFFStringFormatTest

- (void)testNotAllParamsPresent
{
    NSString* format_ = @"%@%@%@";
    NSString* param1_ = @"1";
    NSString* param2_ = @"2";
    
    NSString* result_ = [ NSString stringWithFormatCheckNill: format_, param1_, param2_, nil ];
    GHAssertTrue( result_ != nil, @"Should NOT be nil value" );
}

- (void)testOneMoreParam
{
    NSString *format = @"%@%@";
    NSString *param1 = @"1";
    NSString *param2 = @"2";
    NSString *param3 = @"3";
    
    NSString* result_ = [NSString stringWithFormatCheckNill:format, param1, param2, param3, nil];
    GHAssertTrue( result_ != nil, @"Should NOT be nil value" );
}

@end
