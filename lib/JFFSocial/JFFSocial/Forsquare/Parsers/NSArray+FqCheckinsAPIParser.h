#import <Foundation/Foundation.h>

@interface NSArray (FqCheckinsAPIParser)

+ (NSArray *)fqCheckinsWithDict:(NSDictionary *)dictionary error:(NSError **)outError;

@end
