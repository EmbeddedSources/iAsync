#import <Foundation/Foundation.h>
#include <AddressBook/ABAddressBook.h>

@interface JFFAddressBook : NSObject

@property ( nonatomic, readonly ) CF_RETURNS_NOT_RETAINED ABAddressBookRef rawBook;

-(id)initWithRawBook:( ABAddressBookRef )CF_CONSUMED rawBook_;

-(BOOL)removeAllContactsWithError:( NSError** )error_;

@end
