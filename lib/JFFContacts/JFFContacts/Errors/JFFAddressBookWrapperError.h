#import <JFFContacts/Errors/JFFAddressBookError.h>

@interface JFFAddressBookWrapperError : JFFAddressBookError

@property (nonatomic) NSError *nativeError;

+ (id)newAddressBookWrapperErrorWithNativeError:(NSError *)nativeError;

@end
