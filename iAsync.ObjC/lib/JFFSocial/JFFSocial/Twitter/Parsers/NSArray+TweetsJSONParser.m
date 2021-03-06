#import "NSArray+TweetsJSONParser.h"

#import "JFFTweet+TwitterJSONApiParser.h"

@implementation NSArray (TweetsJSONParser)

+ (instancetype)newTweetsWithJSONObject:(NSDictionary *)jsonObject error:(NSError **)outError
{
    id jsonPattern = @{
    @"statuses" : [NSArray class],
    };
    
    if (![JFFJsonObjectValidator validateJsonObject:jsonObject
                                    withJsonPattern:jsonPattern
                                              error:outError]) {
        return nil;
    }
    
    NSArray *tweets = jsonObject[@"statuses"];
    
    NSArray *result = [tweets map:^id(id object, NSError *__autoreleasing *outError) {
        
        return [JFFTweet newTweetWithTwitterJSONApiDictionary:object
                                                        error:outError];
    } outError:outError];
    
    return result;
}

@end
