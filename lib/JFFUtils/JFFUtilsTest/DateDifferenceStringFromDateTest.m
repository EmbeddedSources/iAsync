#import "DateDifferenceStringFromDateTest.h"

@implementation DateDifferenceStringFromDateTest
{
    NSDateFormatter *_formatter;
}

- (void)setUp
{
    if (!self->_formatter)
    {
        self->_formatter = [NSDateFormatter new];
        [self->_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
}

- (void)testEqulatDateDifferenceDatesThrowsException
{
    NSDate *date     = [self->_formatter dateFromString: @"2012-12-01 12:00:00"];
    NSDate *fromDate = [self->_formatter dateFromString: @"2012-12-01 12:00:00"];
    
    STAssertThrows
    (
     [date dateDifferenceStringFromDate: fromDate]
     , @"assert expected"
     );
}

- (void)testInvalidFromDateThrowsException
{
    NSDate *date     = [self->_formatter dateFromString: @"2012-12-01 12:00:00"];
    NSDate *fromDate = [self->_formatter dateFromString: @"2012-12-01 12:00:01"];
    
    STAssertThrows
    (
     [date dateDifferenceStringFromDate: fromDate]
     , @"assert expected"
     );
}

- (void)testOneSecondDifference
{
    NSDate *date     = [self->_formatter dateFromString: @"2012-12-01 12:00:01"];
    NSDate *fromDate = [self->_formatter dateFromString: @"2012-12-01 12:00:00"];
    
    NSString *result = [date dateDifferenceStringFromDate: fromDate];
    
    STAssertEqualObjects(@"1 SECOND", result, @"date difference mismatch");
}

- (void)testSeveralSecondDifference
{
    NSDate *date     = [self->_formatter dateFromString: @"2012-12-01 12:00:22"];
    NSDate *fromDate = [self->_formatter dateFromString: @"2012-12-01 12:00:00"];
    
    NSString *result = [date dateDifferenceStringFromDate: fromDate];
    
    STAssertEqualObjects(@"22 SECONDS", result, @"date difference mismatch");
}

- (void)testOneMinuteDifference
{
    NSDate *date     = [self->_formatter dateFromString: @"2012-12-01 12:01:01"];
    NSDate *fromDate = [self->_formatter dateFromString: @"2012-12-01 12:00:00"];
    
    NSString *result = [date dateDifferenceStringFromDate: fromDate];
    
    STAssertEqualObjects(@"1 MINUTE", result, @"date difference mismatch");
}

@end
