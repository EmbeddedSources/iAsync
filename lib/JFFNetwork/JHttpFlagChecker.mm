#import "JHttpFlagChecker.h"

#include <set>

@implementation JHttpFlagChecker

+ (BOOL)isDownloadErrorFlag:( CFIndex )statusCode
{
    BOOL result =
        ![self isSuccessFlag :statusCode] &&
        ![self isRedirectFlag:statusCode];

    return result;
}

+ (BOOL)isRedirectFlag:(CFIndex)statusCode
{
    std::set<CFIndex> redirectFlags;
    {
        redirectFlags.insert(301);
        redirectFlags.insert(302);
        redirectFlags.insert(303);
        redirectFlags.insert(307);
    };
    auto iFlag = redirectFlags.find(statusCode);

    BOOL result_ = (redirectFlags.end() != iFlag);
    return result_;
}

+ (BOOL)isSuccessFlag:(CFIndex)statusCode
{
    return (200 == statusCode);
}

@end
