#import "JNGzipErrorsLogger.h"

@implementation JNGzipErrorsLogger

+ (NSString *)zipErrorMessageFromCode:(int)errorCode
{
    static NSString *zipErrors[] =
    {
        @"Z_VERSION_ERROR",
        @"Z_BUF_ERROR"    ,
        @"Z_MEM_ERROR"    ,
        @"Z_DATA_ERROR"   ,
        @"Z_STREAM_ERROR" ,
        @"Z_ERRNO"
    };
    
    NSUInteger errorIndex    = errorCode + abs(Z_VERSION_ERROR);
    NSUInteger maxErrorIndex = Z_ERRNO   + abs(Z_VERSION_ERROR);
    
    if (errorIndex > maxErrorIndex) {
        return @"Z_UnknownError";
    }
    
    return zipErrors[errorIndex];
}

@end
