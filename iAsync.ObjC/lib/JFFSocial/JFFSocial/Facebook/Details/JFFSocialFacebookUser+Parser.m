#import "JFFSocialFacebookUser+Parser.h"

@implementation JFFSocialFacebookUser (Parser)

+ (instancetype)newSocialFacebookUserWithJsonObject:(NSDictionary *)jsonObject
                                              error:(NSError **)outError
{
    JFFSocialFacebookUser *result = [self new];
    
    if (result) {
        
        result.facebookID = jsonObject[@"id"    ];
        result.email      = jsonObject[@"email" ]?:@"";
        result.name       = jsonObject[@"name"  ]?:@"";
        result.gender     = jsonObject[@"gender"]?:@"";
        result.biography  = jsonObject[@"bio"   ]?:@"";
        
        NSString *birthdayStr = jsonObject[@"birthday"];
        if (birthdayStr) {
            
            NSDateFormatter *formatter = [NSDateFormatter new];
            
            formatter.dateFormat = @"MM/dd/yyyy";
            formatter.locale   = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            formatter.timeZone = [[NSTimeZone alloc] initWithName:@"GMT"];
            
            result.birthday = [formatter dateFromString:birthdayStr];
        }
    }
    
    return result;
}

@end
