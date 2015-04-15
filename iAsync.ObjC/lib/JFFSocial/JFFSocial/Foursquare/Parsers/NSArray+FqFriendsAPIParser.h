#import <Foundation/Foundation.h>

@interface NSArray (FqFriendsAPIParser)

+ (NSArray *)fqFriendsWithDict:(NSDictionary *)dictionary error:(NSError **)outError;

@end
