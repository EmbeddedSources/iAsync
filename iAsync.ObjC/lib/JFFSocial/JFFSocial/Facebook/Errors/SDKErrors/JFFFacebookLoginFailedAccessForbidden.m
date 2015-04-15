#import "JFFFacebookLoginFailedAccessForbidden.h"

#import <FacebookSDK/FacebookSDK.h>

@implementation JFFFacebookLoginFailedAccessForbidden

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"FACEBOOK_LOGIN_ERROR_ACCESS_FORBIDDEN", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

//This error happens when user forbid access when it try access it or something ither very strange
//TODO retest it
+ (BOOL)isMineFacebookNativeError_whenInvalidSettings:(NSError *)nativeError
{
    NSDictionary *userInfo = [nativeError userInfo];
    
    id jsonPattern =
    @{
      FBErrorInnerErrorKey         : [NSError class],
      FBErrorParsedJSONResponseKey : @{@"body" : @{@"error" : @{@"code" : @190, @"error_subcode" : @65001}}},
      };
    
    if (![JFFJsonObjectValidator validateJsonObject:userInfo
                                    withJsonPattern:jsonPattern
                                              error:NULL]) {
        
        return NO;
    }
    
    NSError *subError = userInfo[FBErrorInnerErrorKey];
    
    NSInteger code = [nativeError code];
    
    return code == FBErrorHTTPError
    && [subError code] == ACErrorUnknown
    && [[subError domain] isEqualToString:ACErrorDomain];
}

+ (BOOL)isMineFacebookNativeError_whenForbidWebLogin:(NSError *)nativeError
{
    NSInteger code = [nativeError code];
    NSDictionary *userInfo = [nativeError userInfo];
    
    return code == FBErrorLoginFailedOrCancelled
    && [userInfo[FBErrorLoginFailedReason] isEqualToString:FBErrorLoginFailedReasonUserCancelledValue]
    && [[nativeError domain] isEqualToString:FacebookSDKDomain];
}

+ (BOOL)isMineFacebookNativeError:(NSError *)nativeError
{
    BOOL result =
       [self isMineFacebookNativeError_whenInvalidSettings:nativeError]
    || [self isMineFacebookNativeError_whenForbidWebLogin:nativeError];
    
    if (result)
        return YES;
    
    NSInteger code = [nativeError code];
    NSDictionary *userInfo = [nativeError userInfo];
    
    return code == FBErrorLoginFailedOrCancelled
    && [userInfo[FBErrorLoginFailedReason] isEqualToString:FBErrorLoginFailedReasonSystemDisallowedWithoutErrorValue];
}

@end
