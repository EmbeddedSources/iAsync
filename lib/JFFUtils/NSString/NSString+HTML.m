#import "NSString+HTML.h"

@implementation NSString (HTML)

- (NSString*)convertEntities
{
    NSString *returnStr_ = self;
    
    NSDictionary *listOfReplaces_ =
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
    
    for (NSString *elem_ in [listOfReplaces_ allKeys])
    {
        NSString *correctString = [ listOfReplaces_ objectForKey:elem_ ];
        returnStr_ = [ returnStr_ stringByReplacingOccurrencesOfString:elem_ withString:correctString ];
    }
    
    return returnStr_;
}

-(NSString *)stringByTrimmingHTMLTags
{
    NSRange r;
    NSString *result_ = self;
    
    while ((r = [result_ rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        result_ = [result_ stringByReplacingCharactersInRange:r withString:@""];
    
    result_ = [result_ convertEntities];
    
    return result_;
}

@end