#import <Foundation/Foundation.h>

#include <AddressBook/ABRecord.h>
#include <AddressBook/ABAddressBook.h>

@class UIImage;
@class JFFAddressBook;

@interface JFFContact : NSObject

@property ( nonatomic ) NSString* firstName;
@property ( nonatomic ) NSString* lastName;
@property ( nonatomic ) NSString* company;
@property ( nonatomic ) NSDate  * birthday;
@property ( nonatomic ) NSArray * emails;
@property ( nonatomic ) NSArray * phones;
@property ( nonatomic ) NSArray * sites;
@property ( nonatomic ) UIImage * photo;
@property ( nonatomic ) NSArray * addresses;
@property ( nonatomic ) ABRecordID contactInternalId;

@property ( nonatomic, readonly ) ABRecordRef      person;
@property ( nonatomic, readonly ) ABAddressBookRef addressBook;
@property ( nonatomic, readonly ) BOOL newContact;

-(id)initWithPerson:( ABRecordRef )person_
        addressBook:( JFFAddressBook* )addressBook_;

-(id)initWithFieldsDict:( NSDictionary* )args_
            addressBook:( JFFAddressBook* )addressBook_;

-(BOOL)save;
-(BOOL)remove;

+(id)findContactWithContactInternalId:( ABRecordID )contactInternalId_
                          addressBook:( JFFAddressBook* )addressBook_;

+(id)allContactsAddressBook:( JFFAddressBook* )addressBook_;

@end
