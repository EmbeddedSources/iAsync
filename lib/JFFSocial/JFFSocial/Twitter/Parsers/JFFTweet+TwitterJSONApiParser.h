#import "JFFTweet.h"

@interface JFFTweet (TwitterJSONApiParser)

+ (id)newTweetWithTwitterJSONApiDictionary:(NSDictionary *)dict
                                     error:(NSError **)error;

@end
