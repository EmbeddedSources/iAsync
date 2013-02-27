#import "JFFAddressBookWrapperError.h"

#import "JFFAddressBookAccessError.h"

#include <AddressBook/AddressBook.h>

@implementation JFFAddressBookWrapperError

- (id)init
{
    return [self initWithDescription:NSLocalizedString(@"ADDRESS_BOOK_WRAPPER_ERROR", nil)];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFAddressBookWrapperError *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy->_nativeError = [_nativeError copyWithZone:zone];
    }
    
    return copy;
}

+ (id)newAddressBookWrapperErrorWithNativeError:(NSError *)nativeError
{
    Class class = Nil;
    
    NSString *domain = [nativeError domain];
    NSInteger code   = [nativeError code];
    
    if ([domain isEqualToString:(__bridge NSString*)ABAddressBookErrorDomain]
        && code == kABOperationNotPermittedByUserError) {
        
        class = [JFFAddressBookAccessError class];
    }
    
    if (class == Nil) {
        
        class = [JFFAddressBookWrapperError class];
    }
    
    JFFAddressBookWrapperError *error = [class new];
    error->_nativeError = nativeError;
    return error;
}

- (void)writeErrorWithJFFLogger
{
    [JFFLogger logErrorWithFormat:@"%@ nativeError:%@", [self localizedDescription], _nativeError];
}

@end
