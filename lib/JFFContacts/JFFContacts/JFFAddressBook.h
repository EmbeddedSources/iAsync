#import <Foundation/Foundation.h>
#include <AddressBook/ABAddressBook.h>

@interface JFFAddressBook : NSObject

@property (nonatomic, readonly) CF_RETURNS_NOT_RETAINED ABAddressBookRef rawBook;

- (instancetype)initWithRawBook:(ABAddressBookRef)CF_CONSUMED rawBook;

- (BOOL)removeAllContactsWithError:(NSError **)error;

@end
