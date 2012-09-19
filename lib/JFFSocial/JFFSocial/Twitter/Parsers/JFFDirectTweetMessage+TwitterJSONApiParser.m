#import "JFFDirectTweetMessage+TwitterJSONApiParser.h"

@implementation JFFDirectTweetMessage (TwitterJSONApiParser)

+ (id)newDirectTweetMessageWithTwitterJSONObject:(NSDictionary *)jsonObject
                                           error:(NSError **)outError
{
    id jsonPattern = @{
    @"text" : [NSString class],
    };
    
    if (![JFFJsonObjectValidator validateJsonObject:jsonObject
                                    withJsonPattern:jsonPattern
                                              error:outError])
    {
        return nil;
    }

    JFFDirectTweetMessage *result = [self new];

    if (result)
    {
        result.text = jsonObject[@"text"];
    }

    return result;
}

@end
