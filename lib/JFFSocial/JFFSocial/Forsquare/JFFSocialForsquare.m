#import "JFFSocialForsquare.h"

@implementation JFFSocialForsquare

+ (JFFAsyncOperation)authLoader
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


+ (JFFAsyncOperation)friendsLoader
{
    /*https://api.foursquare.com/v2/users/USER_ID/friends */
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
