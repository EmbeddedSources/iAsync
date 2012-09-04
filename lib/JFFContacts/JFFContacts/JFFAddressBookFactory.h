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

typedef void(^JFFAddressBookOnCreated)( JFFAddressBook* book_, ABAuthorizationStatus status_, NSError* error_ );
typedef void(^JFFAddressBookSuccessCallback)( JFFAddressBook* book_ );
typedef void(^JFFAddressBookErrorCallback)( ABAuthorizationStatus status_, NSError* error_ );

@interface JFFAddressBookFactory : NSObject

+(void)asyncAddressBookWithOnCreatedBlock:( JFFAddressBookOnCreated )callback_;
+(void)asyncAddressBookWithSuccessBlock:( JFFAddressBookSuccessCallback )onSuccess_
                          errorCallback:( JFFAddressBookErrorCallback )onFailure_;

+(NSString*)bookStatusToString:( ABAuthorizationStatus) status_;

@end
