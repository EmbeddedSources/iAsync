#import <JFFContacts/Errors/JFFAddressBookError.h>

@interface JFFAddressBookAccessError : JFFAddressBookError

@property (nonatomic) NSError *nativeError;

@end
