#import "NSDictionary+FqAPIresponseParser.h"

#import "JFFFoursquareAPIServerError.h"

@implementation NSDictionary (FqAPIresponseParser)

+ (id)fqApiresponseDictWithDict:(NSDictionary *)dict error:(NSError **)outError
{
    NSDictionary *metaDict = [dict dictionaryForKey:@"meta"];
    NSInteger responseCode = [metaDict integerForKey:@"code"];
    
    if (responseCode != 200) {
        [[[JFFFoursquareAPIServerError alloc] initWithDictionary:metaDict] setToPointer:outError];
        return nil;
    }
    
    NSDictionary *response = [dict dictionaryForKey:@"response"];
    if (!response) {
        [[[JFFFoursquareAPIServerError alloc] initWithDescription:NSLocalizedString(@"response dictionary not found", nil)] setToPointer:outError];
        return nil;
    }
    
    return response;
}

@end
