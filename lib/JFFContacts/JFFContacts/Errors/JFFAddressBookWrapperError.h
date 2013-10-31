#import <JFFContacts/Errors/JFFAddressBookError.h>

#import <AddressBook/ABAddressBook.h>

@interface JFFAddressBookWrapperError : JFFAddressBookError

@property (nonatomic) NSError *nativeError;
@property (nonatomic) ABAuthorizationStatus authorizationStatus;

+ (instancetype)newAddressBookWrapperErrorWithNativeError:(NSError *)nativeError;

@end
