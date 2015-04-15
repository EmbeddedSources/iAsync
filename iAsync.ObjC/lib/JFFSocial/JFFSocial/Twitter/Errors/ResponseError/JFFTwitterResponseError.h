#import <JFFSocial/Errors/JFFSocialError.h>

@interface JFFTwitterResponseError : JFFSocialError

@property (nonatomic) id<NSCopying> context;
@property (nonatomic) id<NSCopying> response;

@end
