#import "JFFError.h"

@implementation JFFError

+ (NSString *)jffErrorsDomain
{
    return @"com.just_for_fun.library";
}

- (instancetype)initWithDescription:(NSString *)description
                             domain:(NSString *)domain
                               code:(NSInteger)code
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : description};
    
    return [super initWithDomain:domain
                            code:code
                        userInfo:userInfo];
}

- (instancetype)initWithDescription:(NSString *)description code:(NSInteger)code
{
    return [self initWithDescription:description
                              domain:[[self class] jffErrorsDomain]
                                code:code];
}

- (instancetype)initWithDescription:(NSString *)description
{
    return [self initWithDescription:description code:0];
}

+ (instancetype)newErrorWithDescription:(NSString *)description
{
    return [self newErrorWithDescription:description code:0];
}

+ (instancetype)newErrorWithDescription:(NSString *)description
                                   code:(NSInteger)code
{
    return [[self alloc] initWithDescription:description code:code];
}

@end
