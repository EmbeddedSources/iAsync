#import <Foundation/Foundation.h>

@interface JNGzipErrorsLogger : NSObject

+(NSString*)zipErrorMessageFromCode:(int)error_code_;

@end
