#import "NSString+Format.h"

@implementation NSString (Format)

+ (id)stringWithFormatCheckNill:(NSString *)format, ...
{
    if ([format length] == 0) {
        return nil;
    }
    
    id eachObject;
    va_list argumentList;
    
    va_start(argumentList, format);
    eachObject = va_arg(argumentList, id);
    
    while (eachObject) {
        if (![eachObject isKindOfClass:[NSObject class]]) {
            return nil;
        }
        
        if ([[eachObject description] length] == 0) {
            return nil;
        }
        
        eachObject = va_arg(argumentList, id);
    }
    
    va_start(argumentList, format);
    return [[NSString alloc] initWithFormat:format
                                  arguments:argumentList];
}

- (NSString *)singleQuotedString
{
    return [[NSString alloc] initWithFormat:@"'%@'", self];
}

@end
