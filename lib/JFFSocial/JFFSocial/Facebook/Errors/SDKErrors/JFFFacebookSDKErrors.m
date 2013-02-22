#import "JFFFacebookSDKErrors.h"

#import "JFFFacebookLoginFailedCanceledError.h"

@implementation JFFFacebookSDKErrors

+ (NSString *)jffErrorsDomain
{
    return @"com.just_for_fun.facebook.sdk.errors.library";
}

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"FACEBOOK_GENERAL_ERROR", nil)];
}

+ (id)newFacebookSDKErrorsWithNativeError:(NSError *)nativeError
{
    Class class = Nil;
    
    NSString *domain = [nativeError domain];
    NSInteger code   = [nativeError code];
    NSDictionary *userInfo = [nativeError userInfo];
    
    if ([domain isEqualToString:@"com.facebook.sdk"]
        && [userInfo[@"com.facebook.sdk:ErrorLoginFailedReason"] isEqualToString:@"com.facebook.sdk:ErrorReauthorizeFailedReasonUserCancelled"]
        && code == 2) {
        
        class = [JFFFacebookLoginFailedCanceledError class];
    }
    
    if (class == Nil) {
        
        class = [JFFFacebookSDKErrors class];
    }
    
    JFFFacebookSDKErrors *error = [class new];
    error->_nativeError = nativeError;
    return error;
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFFacebookSDKErrors *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy->_nativeError = [_nativeError copyWithZone:zone];
    }
    
    return copy;
}

- (void)writeErrorWithJFFLogger
{
    [JFFLogger logErrorWithFormat:@"%@ nativeError:%@", [self localizedDescription], _nativeError];
}

@end
