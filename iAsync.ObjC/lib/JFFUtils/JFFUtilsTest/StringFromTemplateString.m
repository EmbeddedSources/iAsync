#import "StringFromTemplateString.h"

@implementation StringFromTemplateString

- (void)testStringFromTemplateString
{
    {
        NSString *templateString = @"${monthCount} months for ${price}/month";
        
        NSString *resultString = [templateString localizedTemplateStringWithVariables:
                                 @{
                                 @"monthCount" : @3,
                                 @"price"      : @"$23",
                                 }];
        
        XCTAssertEqualObjects(@"3 months for $23/month", resultString, @"unexpected template result" );
    }
    
    {
        NSString *templateString = @"${price} months for ${monthCount}/month";
        
        NSString *resultString = [templateString localizedTemplateStringWithVariables:
                                  @{
                                  @"monthCount" : @3,
                                  @"price"      : @"$23",
                                  }];
        
        XCTAssertEqualObjects(@"$23 months for 3/month", resultString, @"unexpected template result");
    }
    
    {
        NSString *templateString = @"cc ${monthCount} months for ${price}";
        
        NSString *resultString = [templateString localizedTemplateStringWithVariables:
                                  @{
                                  @"monthCount" : @3,
                                  @"price"      : @"$23",
                                  }];
        
        XCTAssertEqualObjects(@"cc 3 months for $23", resultString, @"unexpected template result");
    }
    
    {
        NSString *templateString = @"${monthCount}${price}";
        
        NSString *resultString = [templateString localizedTemplateStringWithVariables:
                                  @{
                                  @"monthCount" : @3,
                                  @"price"      : @"$23",
                                  }];
        
        XCTAssertEqualObjects(@"3$23", resultString, @"unexpected template result");
    }
    
    {
        NSString *templateString = @"${monthCount";
        
        NSString *resultString = [templateString localizedTemplateStringWithVariables:
                                  @{
                                  @"monthCount" : @3,
                                  }];
        
        XCTAssertEqualObjects(@"${monthCount", resultString, @"unexpected template result");
    }
    
    {
        NSString *templateString = @"${monthCount}";
        
        NSString *resultString = [templateString localizedTemplateStringWithVariables:
                                  @{
                                  @"monthCount2" : @3,
                                  }];
        
        XCTAssertEqualObjects(@"${monthCount}", resultString, @"unexpected template result");
    }
}

@end
