#import "JFFTweet+TwitterJSONApiParser.h"

#import "JFFTwitterAccount+TwitterJSONApiParser.h"

@implementation JFFTweet (TwitterJSONApiParser)

+ (id)newTweetWithTwitterJSONApiDictionary:(NSDictionary *)jsonObject
                                     error:(NSError **)outError
{
    id jsonPattern = @{
    @"user"   : [NSDictionary class],
    @"id_str" : [NSString class],
    @"text"   : [NSString class],
    };

    if (![JFFJsonObjectValidator validateJsonObject:jsonObject
                                    withJsonPattern:jsonPattern
                                              error:outError])
    {
        return nil;
    }

    JFFTwitterAccount *user = [JFFTwitterAccount newTwitterAccountWithTwitterJSONApiDictionary:jsonObject[@"user"]
                                                                                         error:outError];

    if (!user)
        return nil;

    JFFTweet *result = [self new];

    if (result)
    {
        result.tweetId = jsonObject[@"id_str"];
        result.text    = jsonObject[@"text"];
        result.user    = user;
    }

    return result;
}

@end
