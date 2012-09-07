#import <Foundation/Foundation.h>

@interface NSArray (TweetsJSONParser)

+ (id)newTweetsWithJSONObject:(NSDictionary *)jsonObject error:(NSError **)error;

@end
