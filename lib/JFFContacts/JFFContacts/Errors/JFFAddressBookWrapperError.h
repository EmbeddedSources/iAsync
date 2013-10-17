#import <JFFContacts/Errors/JFFAddressBookError.h>

@interface JFFAddressBookWrapperError : JFFAddressBookError

@property (nonatomic) NSError *nativeError;

+ (instancetype)newAddressBookWrapperErrorWithNativeError:(NSError *)nativeError;

@end
