#import <Foundation/Foundation.h>

@interface NSDictionary (FqAPIresponseParser)

+ (instancetype)fqApiresponseDictWithDict:(NSDictionary *)dict error:(NSError **)outError;

@end
