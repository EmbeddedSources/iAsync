#import "JFFDirectTweetMessage+TwitterJSONApiParser.h"

@implementation JFFDirectTweetMessage (TwitterJSONApiParser)

+ (id)newDirectTweetMessageWithTwitterJSONObject:(NSDictionary *)jsonObject
                                           error:(NSError **)outError
{
    NSArray *errors = jsonObject[@"errors"];
    
    if ([errors count] > 0) {
        
        if (outError) {
            
            NSDictionary *firstError = errors[0];
            *outError = [[JFFError alloc] initWithDescription:firstError[@"message"]
                                                       domain:@"parse.message.tweet"
                                                         code:[firstError[@"code"] integerValue]];
        }
        return nil;
    }
    
    id jsonPattern = @{
    @"text" : [NSString class],
    };
    
    if (![JFFJsonObjectValidator validateJsonObject:jsonObject
                                    withJsonPattern:jsonPattern
                                              error:outError]) {
        return nil;
    }
    
    JFFDirectTweetMessage *result = [self new];
    
    if (result) {
        result.text = jsonObject[@"text"];
    }
    
    return result;
}

@end
