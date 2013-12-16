#import "JFFSocialFacebookUser.h"

@interface JFFSocialFacebookUser (Parser)

+ (instancetype)newSocialFacebookUserWithJsonObject:(NSDictionary *)jsonObject error:(NSError **)outError;

@end
