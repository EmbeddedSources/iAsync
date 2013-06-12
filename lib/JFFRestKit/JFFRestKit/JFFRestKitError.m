#import "JFFRestKitError.h"

@implementation JFFRestKitError

+ (NSString *)jffErrorsDomain
{
    return @"com.just_for_fun.rest_kit.library";
}

- (instancetype)init
{
    return [super initWithDescription:NSLocalizedString(@"REST_KIT_BASE_ERROR", nil)];
}

@end

@implementation JFFRestKitEmptyFileResponseError

- (instancetype)init
{
    return [super initWithDescription:NSLocalizedString(@"REST_KIT_EMPTY_FILE_RESPONSE_ERROR", nil)];
}

@end
