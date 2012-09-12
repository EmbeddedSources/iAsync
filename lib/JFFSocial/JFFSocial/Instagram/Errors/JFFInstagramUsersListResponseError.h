#import <JFFSocial/Errors/JFFSocialError.h>

#import <Foundation/Foundation.h>

@interface JFFInstagramUsersListResponseError : JFFSocialError

@property (nonatomic) NSDictionary *jsonObject;

@end
