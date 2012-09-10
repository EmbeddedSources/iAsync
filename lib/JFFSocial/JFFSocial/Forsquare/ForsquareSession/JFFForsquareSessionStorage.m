#import "JFFForsquareSessionStorage.h"

#define FORSQUARE_ACCESS_TOKEN_KEY @"FORSQUARE_ACCESS_TOKEN_KEY"

@implementation JFFForsquareSessionStorage

+ (NSString *)accessToken
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:FORSQUARE_ACCESS_TOKEN_KEY];
}


+ (void)saveAccessToken:(NSString *)accessToken
{
    [[NSUserDefaults standardUserDefaults] setValue:accessToken forKey:FORSQUARE_ACCESS_TOKEN_KEY];
}

@end
