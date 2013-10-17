#import "JFFTweet.h"

@interface JFFTweet (TwitterJSONApiParser)

+ (instancetype)newTweetWithTwitterJSONApiDictionary:(NSDictionary *)dict
                                               error:(NSError **)error;

@end
