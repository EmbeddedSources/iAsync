#import <Foundation/Foundation.h>

#include <AddressBook/ABRecord.h>
#include <AddressBook/ABAddressBook.h>

@class UIImage;
@class JFFAddressBook;

@interface JFFContact : NSObject

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *company;
@property (nonatomic) NSDate   *birthday;
@property (nonatomic) NSArray  *emails;
@property (nonatomic) NSArray  *phones;
@property (nonatomic) NSArray  *sites;
@property (nonatomic) UIImage  *photo;
@property (nonatomic) NSArray  *addresses;
@property (nonatomic) ABRecordID contactInternalId;

@property (nonatomic, readonly) ABRecordRef      person;
@property (nonatomic, readonly) ABAddressBookRef addressBook;
@property (nonatomic, readonly) BOOL newContact;

- (instancetype)initWithPerson:(ABRecordRef)person
                   addressBook:(JFFAddressBook *)addressBook;

- (instancetype)initWithFieldsDict:(NSDictionary *)args
                       addressBook:(JFFAddressBook *)addressBook;

- (BOOL)save;
- (BOOL)remove;

+ (instancetype)findContactWithContactInternalId:(ABRecordID)contactInternalId
                                     addressBook:(JFFAddressBook *)addressBook;

+ (NSArray *)allContactsAddressBook:(JFFAddressBook *)addressBook;

@end
