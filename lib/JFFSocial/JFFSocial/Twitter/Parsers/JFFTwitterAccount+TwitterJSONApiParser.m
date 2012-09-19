#import "JFFTwitterAccount+TwitterJSONApiParser.h"

@implementation JFFTwitterAccount (TwitterJSONApiParser)

+ (id)newTwitterAccountWithTwitterJSONApiDictionary:(NSDictionary *)jsonObject
                                              error:(NSError **)outError
{
    id jsonPattern = @{
    @"id_str"            : [NSString class],
    @"name"              : [NSString class],
    @"profile_image_url" : [NSString class],
    };
    
    if (![JFFJsonObjectValidator validateJsonObject:jsonObject
                                    withJsonPattern:jsonPattern
                                              error:outError])
    {
        return nil;
    }
    
    JFFTwitterAccount *result = [self new];
    
    if (result)
    {
        result.twitterAccountId = jsonObject[@"id_str"];
        result.name             = jsonObject[@"name"  ];
        
        {
            NSString* avatarUrlString = jsonObject[@"profile_image_url"];
            result.avatarURL = [avatarUrlString toURL];
        }
    }
    
    return result;
}

@end
