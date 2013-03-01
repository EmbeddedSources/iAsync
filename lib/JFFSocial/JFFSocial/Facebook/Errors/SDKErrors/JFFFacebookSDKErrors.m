#import "JFFFacebookSDKErrors.h"

#import "JFFFacebookLoginFailedCanceledError.h"
#import "JFFFacebookLoginFailedAccessForbidden.h"
#import "JFFFacebookLoginFailedPasswordWasChanged.h"

#import <FacebookSDK/FacebookSDK.h>

@implementation JFFFacebookSDKErrors

+ (NSString *)jffErrorsDomain
{
    return @"com.just_for_fun.facebook.sdk.errors.library";
}

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"FACEBOOK_GENERAL_ERROR", nil)];
}

+ (BOOL)isMineFacebookNativeError:(NSError *)error
{
    return NO;
}

+ (id)newFacebookSDKErrorsWithNativeError:(NSError *)nativeError
{
    Class class = Nil;
    
    NSString *domain = [nativeError domain];
    
    if ([domain isEqualToString:FacebookSDKDomain]) {
        
        NSArray *errorClasses =
        @[
          [JFFFacebookLoginFailedCanceledError      class],
          [JFFFacebookLoginFailedAccessForbidden    class],
          [JFFFacebookLoginFailedPasswordWasChanged class],
        ];
        
        class = [errorClasses firstMatch:^BOOL(id object) {
            
            Class someClass = object;
            return [someClass isMineFacebookNativeError:nativeError];
        }];
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