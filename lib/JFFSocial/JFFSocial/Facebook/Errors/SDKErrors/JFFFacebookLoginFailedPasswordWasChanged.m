#import "JFFFacebookLoginFailedPasswordWasChanged.h"

#import <FacebookSDK/FacebookSDK.h>

@implementation JFFFacebookLoginFailedPasswordWasChanged

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"FACEBOOK_LOGIN_ERROR_USER_DENIED_PERMISSION", nil)];
}

- (void)writeErrorWithJFFLogger
{
    [self writeErrorToNSLog];
}

+ (BOOL)isMineFacebookNativeError:(NSError *)nativeError
{
    NSDictionary *userInfo = [nativeError userInfo];
    
    id jsonPattern =
    @{
      FBErrorInnerErrorKey     : [NSError class],
      FBErrorLoginFailedReason : @"com.facebook.sdk:SystemLoginCancelled",
      FBErrorSessionKey        : [FBSession class],
      };
    
    if (![JFFJsonObjectValidator validateJsonObject:userInfo
                                    withJsonPattern:jsonPattern
                                              error:NULL]) {
        
        return NO;
    }
    
    NSError *subError = userInfo[FBErrorInnerErrorKey];
    
    NSInteger code = [nativeError code];
    
    return code == FBErrorLoginFailedOrCancelled
    && [subError code] == ACErrorPermissionDenied
    && [[subError domain] isEqualToString:ACErrorDomain];
}

@end
