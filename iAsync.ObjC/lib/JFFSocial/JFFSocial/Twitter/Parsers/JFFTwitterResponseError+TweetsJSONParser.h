#import "JFFTwitterResponseError.h"

@interface JFFTwitterResponseError (TweetsJSONParser)

+ (instancetype)newTwitterResponseErrorWithTwitterJSONObject:(NSDictionary *)jsonObject
                                                     context:(id<NSCopying>)context;

@end
