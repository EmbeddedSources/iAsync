#import <Foundation/Foundation.h>

@interface NSArray (TweetsJSONParser)

+ (instancetype)newTweetsWithJSONObject:(NSDictionary *)jsonObject error:(NSError **)error;

@end
