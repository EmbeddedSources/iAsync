#import "NSObject+NsNullAsNil.h"

@implementation NSObject (NsNullAsNil)

- (id)nsNullAsNil
{
    return self;
}

@end

@implementation NSNull (NsNullAsNil)

- (id)nsNullAsNil
{
    return nil;
}

@end
