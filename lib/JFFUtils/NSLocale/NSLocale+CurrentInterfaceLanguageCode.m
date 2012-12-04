#import "NSLocale+CurrentInterfaceLanguageCode.h"

#import "NSArray+NoThrowObjectAtIndex.h"

@implementation NSLocale (CurrentInterfaceLanguageCode)

+ (NSString *)currentInterfaceLanguageCode
{
    NSString *languageCode = [[self preferredLanguages] noThrowObjectAtIndex:0];
    return languageCode;
}

+ (NSString *)currentInterfaceISO2LanguageCode
{
    NSString *languageCode = [self currentInterfaceLanguageCode];
    
    return [[languageCode componentsSeparatedByString:@"_"] noThrowObjectAtIndex:0];
}

@end
