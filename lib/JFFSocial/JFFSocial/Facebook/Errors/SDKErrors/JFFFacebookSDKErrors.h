#import <JFFUtils/JFFError.h>

#import <Foundation/Foundation.h>

@interface JFFFacebookSDKErrors : JFFError

@property (nonatomic) NSError *nativeError;

+ (id)newFacebookSDKErrorsWithNativeError:(NSError *)nativeError;

@end
