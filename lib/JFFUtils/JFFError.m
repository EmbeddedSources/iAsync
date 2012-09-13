#import "JFFError.h"

@implementation JFFError

- (id)initWithDescription:(NSString *)description
                   domain:(NSString *)domain
                     code:(NSInteger)code
{
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : description };

    return [super initWithDomain:domain
                            code:code
                        userInfo:userInfo];
}

- (id)initWithDescription:(NSString *)description code:(NSInteger)code
{
    return [self initWithDescription:description
                              domain:@"com.just_for_fun.library"
                                code:code];
}

- (id)initWithDescription:(NSString *)description
{
    return [self initWithDescription:description code:0];
}

+ (id)newErrorWithDescription:(NSString *)description
{
    return [self newErrorWithDescription:description code:0];
}

+ (id)newErrorWithDescription:(NSString *)description
                         code:(NSInteger)code
{
    return [[self alloc] initWithDescription:description code:code];
}

@end
