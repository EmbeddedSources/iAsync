#import "JHttpFlagChecker.h"

#include <set>

@implementation JHttpFlagChecker

+ (BOOL)isDownloadErrorFlag:(CFIndex)statusCode
{
    BOOL result =
        ![self isSuccessFlag :statusCode] &&
        ![self isRedirectFlag:statusCode];
    
    return result;
}

+ (BOOL)isRedirectFlag:(CFIndex)statusCode
{
    static std::set<CFIndex> redirectFlags;
    if (redirectFlags.size() == 0) {
        redirectFlags.insert(301);
        redirectFlags.insert(302);
        redirectFlags.insert(303);
        redirectFlags.insert(307);
    };
    auto iFlag = redirectFlags.find(statusCode);

    BOOL result = (redirectFlags.end() != iFlag);
    return result;
}

+ (BOOL)isSuccessFlag:(CFIndex)statusCode
{
    return (200 == statusCode);
}

@end
