#import "JFFStringFormatTest.h"

@implementation JFFStringFormatTest

- (void)testNotAllParamsPresent
{
    NSString *format = @"%@%@%@";
    NSString *param1 = @"1";
    NSString *param2 = @"2";
    
    NSString *result = [NSString stringWithFormatCheckNill:format, param1, param2, nil];
    XCTAssertTrue(result != nil, @"Should NOT be nil value");
}

- (void)testOneMoreParam
{
    NSString *format = @"%@%@";
    NSString *param1 = @"1";
    NSString *param2 = @"2";
    NSString *param3 = @"3";
    
    NSString *result = [NSString stringWithFormatCheckNill:format, param1, param2, param3, nil];
    XCTAssertTrue(result != nil, @"Should NOT be nil value");
}

@end
