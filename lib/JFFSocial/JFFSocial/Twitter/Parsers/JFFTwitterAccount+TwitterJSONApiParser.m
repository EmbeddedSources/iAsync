#import "JFFTwitterAccount+TwitterJSONApiParser.h"

#import "JFFParseJSONObjectError.h"

@implementation JFFTwitterAccount (TwitterJSONApiParser)

+ (id)newTwitterAccountWithTwitterJSONApiDictionary:(NSDictionary *)dict
                                              error:(NSError **)error
{
    if (!dict)
    {
        if (error)
        {
            JFFParseJSONObjectError *jsonError = [JFFParseJSONObjectError new];
            jsonError.jsonObject = dict;
            *error = jsonError;
        }
        return nil;
    }

    JFFTwitterAccount *result = [self new];

    if (result)
    {
        result.twitterAccountId = dict[@"id_str"];
        result.name             = dict[@"name"  ];

        {
            NSString* avatarUrlString = dict[@"profile_image_url"];
            result.avatarURL = [avatarUrlString toURL];
        }
    }

    return result;
}

@end
