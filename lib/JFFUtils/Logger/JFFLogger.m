#import "JFFLogger.h"

static JFFLogHandler logHandler;

@implementation JLogger

+ (instancetype)sharedJLogger
{
    static JLogger *instance;
    if (!instance) {
        instance = [JLogger new];
    }
    return instance;
}

- (JFFLogHandler)logHandler
{
    if (!logHandler) {
        logHandler = ^(NSString *log, NSString *level, id context) {
            NSLog(@"%@: %@", level, log);
        };
    }
    
    return logHandler;
}

- (void)setLogHandler:(JFFLogHandler)handler
{
    logHandler = handler;
}

- (void)logError:(NSString *)str
{
    [self logHandler](str, @"error", nil);
}

- (void)logErrorWithContext:(id)context
                     format:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    [self logInfoWithLevel:@"error"
                   context:context
                    format:format
                   argList:args];
    
    va_end(args);
}

- (void)logInfoWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    [self logInfoWithLevel:@"info"
                   context:nil
                    format:format
                   argList:args];
    
    va_end(args);
}

- (void)logInfoWithLevel:(NSString *)level
                 context:(id)context
                  format:(NSString *)format
                 argList:(va_list)argList
{
    NSString *str = [[NSString alloc] initWithFormat:format arguments:argList];
    [self logHandler](str, level, context);
}

@end
