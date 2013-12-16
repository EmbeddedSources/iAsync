#import <JFFUtils/Errors/JFFError.h>

#import <Foundation/Foundation.h>

@interface JFFFacebookSDKErrors : JFFError

@property (nonatomic) NSError *nativeError;

+ (instancetype)newFacebookSDKErrorsWithNativeError:(NSError *)nativeError;

@end
