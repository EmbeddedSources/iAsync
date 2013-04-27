#import <Foundation/Foundation.h>
#include <AddressBook/ABAddressBook.h>

#ifndef __IPHONE_6_0
    enum ABAuthorizationStatusEnum
    {
        kABAuthorizationStatusNotDetermined = 0,
        kABAuthorizationStatusRestricted,
        kABAuthorizationStatusDenied,
        kABAuthorizationStatusAuthorized
    };
    typedef CFIndex ABAuthorizationStatus;
#endif //__IPHONE_6_


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
