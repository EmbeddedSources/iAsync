#import <Foundation/Foundation.h>

@interface JNGzipErrorsLogger : NSObject

+(NSString*)zipErrorMessageFromCode:(int)errorCode;

@end
