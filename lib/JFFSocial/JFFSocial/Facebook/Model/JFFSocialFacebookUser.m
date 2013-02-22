#import "JFFSocialFacebookUser.h"

@implementation JFFSocialFacebookUser

- (id)copyWithZone:(NSZone *)zone
{
    JFFSocialFacebookUser *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_facebookID     = [_facebookID     copyWithZone:zone];
        copy->_name           = [_name           copyWithZone:zone];
        copy->_gender         = [_gender         copyWithZone:zone];
        copy->_avatarURL      = [_avatarURL      copyWithZone:zone];
        copy->_smallAvatarURL = [_smallAvatarURL copyWithZone:zone];
    }
    
    return copy;
}

@end
