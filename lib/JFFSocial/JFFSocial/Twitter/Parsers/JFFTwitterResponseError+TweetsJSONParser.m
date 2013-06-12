#import "JFFTwitterResponseError+TweetsJSONParser.h"

@implementation JFFTwitterResponseError (TweetsJSONParser)

+ (instancetype)newTwitterResponseErrorWithTwitterJSONObject:(NSDictionary *)jsonObject
                                                     context:(id<NSCopying>)context
{
    
    NSArray *errors = jsonObject[@"errors"];
    
    if ([errors count] == 0) {
        
        return nil;
    }
    
    JFFTwitterResponseError *result = [self new];
    
    result.context  = context;
    result.response = jsonObject;
    
    return result;
}


@end
