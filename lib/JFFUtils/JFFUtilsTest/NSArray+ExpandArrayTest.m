#import "NSArray+ExpandArrayTest.h"

@implementation NSArray_ExpandArrayTest

- (void)testExpandArray
{
    NSArray *array = @[
    @"1",
    @[@"2", @"3"],
    @[@[@"4", @"5"], @[@"6", @"7"]],
    @[@[@[@[@"8"]]]],
    ];
    
    NSArray *expectedResult = @[
    @"1",
    @"2",
    @"3",
    @"4",
    @"5",
    @"6",
    @"7",
    @"8",
    ];
    
    NSArray *result = [array expandArray];
    XCTAssertEqualObjects(expectedResult, result);
}

@end
