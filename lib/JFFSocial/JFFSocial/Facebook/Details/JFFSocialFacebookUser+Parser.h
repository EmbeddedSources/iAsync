#import "JFFSocialFacebookUser.h"

@interface JFFSocialFacebookUser (Parser)

+ (id)newSocialFacebookUserWithJsonObject:(NSDictionary *)jsonObject error:(NSError **)outError;

@end
