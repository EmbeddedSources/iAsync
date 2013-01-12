#import <Foundation/Foundation.h>

@class JFFLogInfo;

typedef void(^JFFLogHandler)(NSString *log, NSString *level);

@interface JFFLogger : NSObject

+ (void)setLogHandler:(JFFLogHandler)handler;

+ (void)logErrorWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

+ (void)logInfoWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end
