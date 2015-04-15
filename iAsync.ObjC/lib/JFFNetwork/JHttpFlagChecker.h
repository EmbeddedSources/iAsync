#import <Foundation/Foundation.h>

@interface JHttpFlagChecker : NSObject

+ (BOOL)isDownloadErrorFlag:(CFIndex)statusCode;
+ (BOOL)isRedirectFlag:(CFIndex)statusCode;
+ (BOOL)isSuccessFlag:(CFIndex)statusCode;

@end
