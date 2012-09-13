#import "JFFInstagramUsersListResponseError.h"

@implementation JFFInstagramUsersListResponseError

-(id)init
{
    return [ self initWithDescription: NSLocalizedString( @"INVALID_INSTAGRAM_USER_LIST_RESPONSE", nil ) ];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFInstagramUsersListResponseError *copy = [[[self class] allocWithZone:zone]init];

    if (copy)
    {
        copy->_jsonObject = [self->_jsonObject copy];
    }

    return copy;
}

@end
