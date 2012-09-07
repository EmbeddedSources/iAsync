#import "JFFTweet+TwitterJSONApiParser.h"

#import "JFFTwitterAccount+TwitterJSONApiParser.h"

@implementation JFFTweet (TwitterJSONApiParser)

+ (id)newTweetWithTwitterJSONApiDictionary:(NSDictionary *)dict
                                     error:(NSError **)error
{
    JFFTweet *result = [self new];

    if (result)
    {
        result.tweetId = dict[@"id_str"];
        result.text    = dict[@"text"];

        {
            result.user = [JFFTwitterAccount newTwitterAccountWithTwitterJSONApiDictionary:dict[@"user"]
                                                                                     error:error];
            if (!result.user)
                return nil;
        }
    }

    return result;
}

@end
