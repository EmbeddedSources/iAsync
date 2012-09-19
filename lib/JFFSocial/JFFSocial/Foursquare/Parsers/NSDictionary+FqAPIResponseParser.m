#import "NSDictionary+FqAPIresponseParser.h"

@implementation NSDictionary (FqAPIresponseParser)

+ (id)fqApiresponseDictWithDict:(NSDictionary *)jsonObject error:(NSError **)outError
{
    id jsonPattern = @{
    @"meta"     :
    @{
        @"code"                   : [NSNumber numberWithInteger:200],
        jOptional(@"errorDetail") : [NSString class],
        jOptional(@"errorType")   : [NSString class],
    },
    @"response" : [NSDictionary class],
    };
    
    if (![JFFJsonObjectValidator validateJsonObject:jsonObject
                                    withJsonPattern:jsonPattern
                                              error:outError])
    {
        return nil;
    }
    
    NSDictionary *response = jsonObject[@"response"];
    
    return response;
}

@end
