#import <Foundation/Foundation.h>

@interface JHttpFlagChecker : NSObject

+(BOOL)isDownloadErrorFlag:( CFIndex )statusCode_;
+(BOOL)isRedirectFlag:( CFIndex )statusCode_;
+(BOOL)isSuccessFlag:( CFIndex )statusCode_;

@end
