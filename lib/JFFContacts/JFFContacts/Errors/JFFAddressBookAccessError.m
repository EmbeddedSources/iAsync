#import "JFFAddressBookAccessError.h"

@implementation JFFAddressBookAccessError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"ADDRESS_BOOK_ACCESS_FORBIDDEN", nil)];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFAddressBookAccessError *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_nativeError = [self->_nativeError copyWithZone:zone];
    }
    
    return copy;
}

@end
