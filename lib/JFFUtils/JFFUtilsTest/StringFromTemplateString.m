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
        
        STAssertEqualObjects(@"3 months for $23/month", resultString, nil);
    }
    
    {
        NSString *templateString = @"${price} months for ${monthCount}/month";
        
        NSString *resultString = [templateString localizedTemplateStringWithVariables:
                                  @{
                                  @"monthCount" : @3,
                                  @"price"      : @"$23",
                                  }];
        
        STAssertEqualObjects(@"$23 months for 3/month", resultString, nil);
    }
    
    {
        NSString *templateString = @"cc ${monthCount} months for ${price}";
        
        NSString *resultString = [templateString localizedTemplateStringWithVariables:
                                  @{
                                  @"monthCount" : @3,
                                  @"price"      : @"$23",
                                  }];
        
        STAssertEqualObjects(@"cc 3 months for $23", resultString, nil);
    }
    
    {
        NSString *templateString = @"${monthCount}${price}";
        
        NSString *resultString = [templateString localizedTemplateStringWithVariables:
                                  @{
                                  @"monthCount" : @3,
                                  @"price"      : @"$23",
                                  }];
        
        STAssertEqualObjects(@"3$23", resultString, nil);
    }
    
    {
        NSString *templateString = @"${monthCount";
        
        NSString *resultString = [templateString localizedTemplateStringWithVariables:
                                  @{
                                  @"monthCount" : @3,
                                  }];
        
        STAssertEqualObjects(@"${monthCount", resultString, nil);
    }
    
    {
        NSString *templateString = @"${monthCount}";
        
        NSString *resultString = [templateString localizedTemplateStringWithVariables:
                                  @{
                                  @"monthCount2" : @3,
                                  }];
        
        STAssertEqualObjects(@"${monthCount}", resultString, nil);
    }
}

@end
