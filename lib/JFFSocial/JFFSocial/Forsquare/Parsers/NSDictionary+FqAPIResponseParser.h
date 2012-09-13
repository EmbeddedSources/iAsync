#import <Foundation/Foundation.h>

@interface NSDictionary (FqAPIresponseParser)

+ (id)fqApiresponseDictWithDict:(NSDictionary *)dict error:(NSError **)outError;

@end
