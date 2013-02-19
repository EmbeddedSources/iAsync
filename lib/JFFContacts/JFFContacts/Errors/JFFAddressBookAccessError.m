#import "JFFAddressBookAccessError.h"

@implementation JFFAddressBookAccessError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"ADDRESS_BOOK_ACCESS_FORBIDDEN", nil)];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFAddressBookAccessError *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy->_nativeError = [_nativeError copyWithZone:zone];
    }
    
    return copy;
}

@end
