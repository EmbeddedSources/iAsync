#import "JFFDirectTweetMessage.h"

@interface JFFDirectTweetMessage (TwitterJSONApiParser)

+ (id)newDirectTweetMessageWithTwitterJSONObject:(NSDictionary *)dict
                                           error:(NSError **)error;

@end
