#import <Foundation/Foundation.h>
#include <AddressBook/ABAddressBook.h>

@protocol JFFAddressBookOwner;
@class JFFAddressBook;

typedef void(^JFFAddressBookOnCreated)(JFFAddressBook *addressBook, ABAuthorizationStatus status, NSError *error);
typedef void(^JFFAddressBookSuccessCallback)(JFFAddressBook *addressBook);
typedef void(^JFFAddressBookErrorCallback)(ABAuthorizationStatus status, NSError *error);

@interface JFFAddressBookFactory : NSObject

+ (void)asyncAddressBookWithOnCreatedBlock:(JFFAddressBookOnCreated)callback;
+ (void)asyncAddressBookWithSuccessBlock:(JFFAddressBookSuccessCallback)onSuccess
                           errorCallback:(JFFAddressBookErrorCallback)onFailure;

+ (NSString *)bookStatusToString:(ABAuthorizationStatus)status;

@end
