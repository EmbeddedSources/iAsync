#import "JFFDirectTweetMessage.h"

@interface JFFDirectTweetMessage (TwitterJSONApiParser)

+ (instancetype)newDirectTweetMessageWithTwitterJSONObject:(NSDictionary *)dict
                                                     error:(NSError **)error;

@end
