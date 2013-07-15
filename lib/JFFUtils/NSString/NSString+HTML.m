#import "NSString+HTML.h"

@implementation NSString (HTML)

- (instancetype)convertEntities
{
    __block NSString *result = self;
    
    NSDictionary *listOfReplaces =
    @{
      @"&amp;"   : @"&",
      @"&quot;"  : @"\"",
      @"&rsquo;" : @"'",
      @"&#x27;"  : @"'",
      @"&#x39;"  : @"'",
      @"&#x92;"  : @"'",
      @"&#x96;"  : @"'",
      @"&gt;"    : @">",
      @"&lt;"    : @"<",
      @"&nbsp;"  : @" ",
      };
    
    [listOfReplaces enumerateKeysAndObjectsUsingBlock:^(NSString *elem, NSString *correctString, BOOL *stop) {
        
        result = [result stringByReplacingOccurrencesOfString:elem withString:correctString];
    }];
    
    return result;
}

- (instancetype)stringByTrimmingHTMLTags
{
    NSRange range;
    NSString *result = self;
    
    while ((range = [result rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        result = [result stringByReplacingCharactersInRange:range withString:@""];
    
    result = [result convertEntities];
    
    return result;
}

@end