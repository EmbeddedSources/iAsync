#import "JFFSocialFacebookUser+Parser.h"

#import <JFFJsonTools/JFFJsonValidator.h>

@implementation JFFSocialFacebookUser (Parser)

+ (id)newSocialFacebookUserWithJsonObject:(NSDictionary *)jsonObject
                                    error:(NSError **)outError
{
    id jsonPattern =
    @{
      @"id"     : [NSString class],
      @"name"   : [NSString class],
      @"gender" : [NSString class],
      jOptionalKey(@"bio") : [NSString class],
      };
    
    if (![JFFJsonObjectValidator validateJsonObject:jsonObject
                                    withJsonPattern:jsonPattern
                                              error:outError]) {
        
        return nil;
    }
    
    JFFSocialFacebookUser *result = [self new];
    
    if (result) {
        
        result.facebookID = jsonObject[@"id"    ];
        result.name       = jsonObject[@"name"  ];
        result.gender     = jsonObject[@"gender"];
        result.biography  = jsonObject[@"bio"   ]?:@"";
    }
    
    return result;
}

@end
