#import "NSLocale+CurrentInterfaceLanguageCode.h"

#import "NSArray+NoThrowObjectAtIndex.h"

@implementation NSLocale (CurrentInterfaceLanguageCode)

+ (NSString *)currentInterfaceLanguageCode
{
    NSString *languageCode = [[self preferredLanguages] firstObject];
    return languageCode;
}

+ (NSString *)currentInterfaceISO2LanguageCode
{
    NSString *languageCode = [self currentInterfaceLanguageCode];
    
    return [[languageCode componentsSeparatedByString:@"_"] firstObject];
}

@end
