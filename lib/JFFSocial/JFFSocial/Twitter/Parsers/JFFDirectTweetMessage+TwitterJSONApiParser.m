#import "JFFDirectTweetMessage+TwitterJSONApiParser.h"

@implementation JFFDirectTweetMessage (TwitterJSONApiParser)

+ (id)newDirectTweetMessageWithTwitterJSONObject:(NSDictionary *)dict
                                           error:(NSError **)error
{
    JFFDirectTweetMessage *result = [self new];

    if (result)
    {
        result.text = dict[@"text"];
    }

    return result;
}

@end
