#import <Foundation/Foundation.h>

@interface JFFSocialFacebookUser : NSObject <NSCopying>

@property (nonatomic) NSString *facebookID;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *gender;
@property (nonatomic) NSURL *avatarURL;
@property (nonatomic) NSURL *smallAvatarURL;

@end
