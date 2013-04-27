#import "JFFAddressBookAccessError.h"

@implementation JFFAddressBookAccessError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"ADDRESS_BOOK_ACCESS_ERROR", nil)];
}

- (void)writeErrorWithJFFLogger
{
}

@end
