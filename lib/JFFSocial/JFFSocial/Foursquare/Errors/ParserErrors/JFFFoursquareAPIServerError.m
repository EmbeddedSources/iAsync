#import "JFFFoursquareAPIServerError.h"

@implementation JFFFoursquareAPIServerError

- (id)initWithDictionary:(NSDictionary *)errorDict
{
    NSInteger code = [errorDict integerForKey:@"code"];
    NSString *message = [errorDict stringForKey:@"errorDetail"];
    NSString *domain = [errorDict stringForKey:@"invalid_auth"];
    return [self initWithDescription:message domain:domain code:code];
}

@end
