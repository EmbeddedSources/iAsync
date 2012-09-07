#import "NSArray+TweetsJSONParser.h"

#import "JFFParseJSONObjectError.h"

#import "JFFTweet+TwitterJSONApiParser.h"

@implementation NSArray (TweetsJSONParser)

+ (id)newTweetsWithJSONObject:(NSDictionary *)jsonObject error:(NSError **)error
{
    NSParameterAssert(jsonObject);

    NSArray *tweets = jsonObject[@"statuses"];

    if (!tweets)
    {
        if (error)
        {
            JFFParseJSONObjectError *jsonError = [JFFParseJSONObjectError new];
            jsonError.jsonObject = jsonObject;
            *error = jsonError;
        }
        return nil;
    }

    NSArray *result = [tweets map:^id(id object, NSError *__autoreleasing *outError)
    {
        return [JFFTweet newTweetWithTwitterJSONApiDictionary:object
                                                        error:outError];
    } error:error];

    return result;
}

@end
