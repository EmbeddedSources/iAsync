@interface DateDifferenceStringFromDateTest : GHTestCase
@end

@implementation DateDifferenceStringFromDateTest
{
    NSDateFormatter* _formatter;
}

-(void)setUp
{
    if ( !self->_formatter )
    {
        self->_formatter = [ NSDateFormatter new ];
        [ self->_formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss" ];
    }
}

-(void)testEqulatDateDifferenceDatesThrowsException
{
    NSDate* date_     = [ self->_formatter dateFromString: @"2012-12-01 12:00:00" ];
    NSDate* fromDate_ = [ self->_formatter dateFromString: @"2012-12-01 12:00:00" ];

    GHAssertThrows
    (
     [ date_ dateDifferenceStringFromDate: fromDate_ ]
     , @"assert expected"
     );
}

-(void)testInvalidFromDateThrowsException
{
    NSDate* date_     = [ self->_formatter dateFromString: @"2012-12-01 12:00:00" ];
    NSDate* fromDate_ = [ self->_formatter dateFromString: @"2012-12-01 12:00:01" ];

    GHAssertThrows
    (
     [ date_ dateDifferenceStringFromDate: fromDate_ ]
     , @"assert expected"
     );
}

-(void)testOneSecondDifference
{
    NSDate* date_     = [ self->_formatter dateFromString: @"2012-12-01 12:00:01" ];
    NSDate* fromDate_ = [ self->_formatter dateFromString: @"2012-12-01 12:00:00" ];

    NSString* result_ = [ date_ dateDifferenceStringFromDate: fromDate_ ];

    GHAssertEqualObjects( @"1 SECOND", result_, @"date difference mismatch" );
}

-(void)testSeveralSecondDifference
{
    NSDate* date_     = [ self->_formatter dateFromString: @"2012-12-01 12:00:22" ];
    NSDate* fromDate_ = [ self->_formatter dateFromString: @"2012-12-01 12:00:00" ];

    NSString* result_ = [ date_ dateDifferenceStringFromDate: fromDate_ ];

    GHAssertEqualObjects( @"22 SECONDS", result_, @"date difference mismatch" );
}

-(void)testOneMinuteDifference
{
    NSDate* date_     = [ self->_formatter dateFromString: @"2012-12-01 12:01:01" ];
    NSDate* fromDate_ = [ self->_formatter dateFromString: @"2012-12-01 12:00:00" ];

    NSString* result_ = [ date_ dateDifferenceStringFromDate: fromDate_ ];

    GHAssertEqualObjects( @"1 MINUTE", result_, @"date difference mismatch" );
}

@end
