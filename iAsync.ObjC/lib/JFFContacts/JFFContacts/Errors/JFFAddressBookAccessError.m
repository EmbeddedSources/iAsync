#import "JFFAddressBookAccessError.h"

@implementation JFFAddressBookAccessError

- (instancetype)init
{
    return [self initWithDescription:NSLocalizedString(@"ADDRESS_BOOK_ACCESS_ERROR", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

@end
