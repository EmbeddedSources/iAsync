#import <Foundation/Foundation.h>

@class JFFLogInfo;

typedef void(^JFFLogHandler)(NSString *log, NSString *level, id context);

@interface JLogger : NSObject

+ (instancetype)sharedJLogger;

- (void)setLogHandler:(JFFLogHandler)handler;

- (void)logError:(NSString *)str;

- (void)logErrorWithContext:(id)context format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);

- (void)logInfoWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end
