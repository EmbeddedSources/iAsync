#import "JFFLogger.h"

static JFFLogHandler logHandler;

@implementation JFFLogger

+ (JFFLogHandler)logHandler
{
    if (!logHandler) {
        logHandler = ^(NSString *log, NSString *level) {
            NSLog(@"%@: %@", level, log);
        };
    }
    
    return logHandler;
}

+ (void)setLogHandler:(JFFLogHandler)handler
{
    logHandler = handler;
}

+ (void)logErrorWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    [self logInfoWithLevel:@"error"
                    format:format
                   argList:args];
    
    va_end(args);
}

+ (void)logInfoWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    [self logInfoWithLevel:@"info"
                    format:format
                   argList:args];
    
    va_end(args);
}

+ (void)logInfoWithLevel:(NSString *)level
                  format:(NSString *)format
                 argList:(va_list)argList
{
    NSString *str = [[NSString alloc] initWithFormat:format arguments:argList];
    [self logHandler](str, level);
}

@end
