#import "JFFFacebookLoginFailedCanceledError.h"

#import <FacebookSDK/FacebookSDK.h>

@implementation JFFFacebookLoginFailedCanceledError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"FACEBOOK_LOGIN_ERROR_CANCELED", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

+ (BOOL)isMineFacebookNativeError:(NSError *)nativeError
{
    NSInteger code = [nativeError code];
    NSDictionary *userInfo = [nativeError userInfo];
    
    NSString *reason = userInfo[FBErrorLoginFailedReason];
    
    return [reason isKindOfClass:[NSString class]]
    && [reason isEqualToString:FBErrorReauthorizeFailedReasonUserCancelled]
    && code == FBErrorLoginFailedOrCancelled;
}

@end
