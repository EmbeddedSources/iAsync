#import <Foundation/Foundation.h>

@class JFFLogInfo;

typedef void(^JFFLogHandler)(NSString *log, NSString *level, id context);

@interface JFFLogger : NSObject

+ (void)setLogHandler:(JFFLogHandler)handler;

+ (void)logErrorWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

+ (void)logErrorWithContext:(id)context format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);

+ (void)logInfoWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end
