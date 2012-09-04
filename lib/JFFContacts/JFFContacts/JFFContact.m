#import "JFFContact.h"

#import "JFFContactDateField.h"
#import "JFFContactStringField.h"
#import "JFFContactStringArrayField.h"
#import "JFFContactEmailsField.h"
#import "JFFContactPhotoField.h"
#import "JFFContactDictionaryArrayField.h"
#import "JFFContactFieldsKeys.h"
#import "JFFAddressBook.h"

#import "NSArray+kABMultiValue.h"

#import <AddressBook/AddressBook.h>

static ABRecordRef createOrGetContactPerson( ABRecordID contactInternalId_
                                            , ABAddressBookRef addressBook_ )
{
    if ( contactInternalId_ != 0 )
    {
        ABRecordRef result_ = ABAddressBookGetPersonWithRecordID( addressBook_
                                                                 , contactInternalId_ );

        if ( result_ )
        {
            CFRetain( result_ );
            return result_;
        }
    }

    return ABPersonCreate();
}

@interface JFFContact ()

@property ( nonatomic ) BOOL newContact;
-(ABRecordRef)rawPerson CF_RETURNS_NOT_RETAINED;
-(void)setRawPerson:( ABRecordRef )person_;


@end

@implementation JFFContact
{
    NSMutableDictionary* _fieldByName;
    JFFAddressBook*      _addressBookWrapper;
    ABRecordRef          _person;
}

@dynamic addressBook;

@dynamic firstName
, lastName
, company
, emails
, phones
, sites
, birthday
, photo
, addresses;

-(id)forwardingTargetForSelector:( SEL )selector_
{
    NSString* selectorName_ = NSStringFromSelector( selector_ );
    JFFContactField* field_ = self->_fieldByName[ selectorName_ ];
    if ( !field_ )
    {
        field_ = self->_fieldByName[ [ selectorName_ propertyGetNameFromPropertyName ] ];
    }
    return field_ ?: self;
}

-(void)dealloc
{
    self.rawPerson = nil;
}

-(void)addField:( JFFContactField* )field_
{
    self->_fieldByName[ field_.name ] = field_;
}

-(void)initializeDynamicFields
{
    self->_fieldByName = [ NSMutableDictionary new ];

    NSDictionary* fieldNameByPropertyId_ = @{
    @(kABPersonFirstNameProperty)    : JFFContactFirstName,
    @(kABPersonLastNameProperty)     : JFFContactLastName ,
    @(kABPersonOrganizationProperty) : JFFContactCompany  ,
    @(kABPersonBirthdayProperty)     : JFFContactBirthday ,
    };

    [ fieldNameByPropertyId_ enumerateKeysAndObjectsUsingBlock: ^( NSNumber* propertyID_, id fieldName_, BOOL* stop_ )
    {
        [ self addField: [ JFFContactStringField contactFieldWithName: fieldName_
                                                           propertyID: [ propertyID_ longLongValue ] ] ];
    } ];

    [ self addField: [ JFFContactPhotoField contactFieldWithName: JFFContactPhoto ] ];

    //JTODO localize all labels
    NSArray* labels_ = @[ @"home", @"work" ];
    [ self addField: [ JFFContactEmailsField contactFieldWithName: JFFContactEmails
                                                       propertyID: kABPersonEmailProperty
                                                           labels: labels_ ] ];

    labels_ = @[ @"mobile"
               , @"iPhone"
               , @"home"
               , @"work"
               , @"main"
               , @"home fax"
               , @"work fax"
               , @"other fax"
               , @"pager"
               , @"other" ];
    [ self addField: [ JFFContactStringArrayField contactFieldWithName: JFFContactPhones
                                                            propertyID: kABPersonPhoneProperty
                                                                labels: labels_ ] ];

    labels_ = @[ @"home page"
               , @"home"
               , @"work"
               , @"other" ];
    [ self addField: [ JFFContactStringArrayField contactFieldWithName: JFFContactWebsites
                                                            propertyID: kABPersonURLProperty
                                                                labels: labels_ ] ];

    labels_ = @[ @"home"
               , @"work"
               , @"other" ];
    [ self addField: [ JFFContactDictionaryArrayField contactFieldWithName: JFFContactAddresses
                                                                propertyID: kABPersonAddressProperty
                                                                    labels: labels_ ] ];
}

-(id)initWithPerson:( ABRecordRef )person_
        addressBook:( JFFAddressBook* )addressBook_
{
    self = [ super init ];

    if ( !self )
    {
        return nil;
    }

    NSParameterAssert( person_ );
    NSParameterAssert( nil != addressBook_ );
    self->_addressBookWrapper = addressBook_;
    
    [ self initializeDynamicFields ];

    self->_contactInternalId = ABRecordGetRecordID( person_ );

    [ self->_fieldByName enumerateKeysAndObjectsUsingBlock: ^( id key, JFFContactField* field_, BOOL* stop )
    {
        [ field_ readPropertyFromRecord: person_ ];
    } ];

    self.rawPerson = person_;

    return self;
}

-(id)initWithFieldsDict:( NSDictionary* )args_
            addressBook:( JFFAddressBook* )addressBook_
{
    self = [ super init ];

    NSParameterAssert( nil != addressBook_ );

    if ( !self )
    {
        return nil;
    }

    self->_addressBookWrapper = addressBook_;

    [ self initializeDynamicFields ];

    NSString* contactInternalId_ = args_[ @"contactInternalId" ];
    self->_contactInternalId = [ contactInternalId_ longLongValue ];
    self.newContact = contactInternalId_ == nil;

    ABRecordRef person_ = self.person;
    [ args_ enumerateKeysAndObjectsUsingBlock: ^( id fieldName_, id value_, BOOL* stop )
    {
        JFFContactField* field_ = self->_fieldByName[ fieldName_ ];
        if ( !field_ )
        {
            NSLog( @"!!!WARNING!!! unsupported field name: %@", fieldName_ );
        }
        [ field_ setPropertyFromValue: value_
                             toRecord: person_ ];
    } ];

    return self;
}

-(ABAddressBookRef)addressBook
{
    return self->_addressBookWrapper.rawBook;
}

-(ABRecordRef)person
{
    if ( !self->_person )
    {
        self->_person = createOrGetContactPerson( self.contactInternalId, self.addressBook );
    }
    return self->_person;
}

-(ABRecordRef)rawPerson
{
    return self->_person;
}

-(void)setRawPerson:( ABRecordRef )person_
{
    if ( person_ == self->_person )
    {
        return;
    }

    if ( NULL != self->_person )
    {
        CFRelease( self->_person );
    }
    self->_person = NULL;

    if ( NULL != person_ )
    {
        self->_person = CFRetain( person_ );
    }
}

-(BOOL)save
{
    CFErrorRef error_ = NULL;

    bool result_ = false;
    if ( self.newContact )
    {
        result_ = ABAddressBookAddRecord( self.addressBook, self.person, &error_ );
        if ( !result_ )
        {
            NSLog( @"can not add Person" );
            return NO;
        }
    }

    result_ = ABAddressBookSave( self.addressBook, &error_ );
    if ( !result_ )
    {
        NSLog( @"can not save Person" );
        return NO;
    }

    self->_contactInternalId = ABRecordGetRecordID( self.person );

    return YES;
}

-(BOOL)remove
{
    if ( 0 == self->_contactInternalId || NULL == self.rawPerson )
    {
        NSLog( @"record has no id" );
        return NO;
    }

    CFErrorRef error_ = NULL;
    bool result_ = ABAddressBookRemoveRecord( self.addressBook, self.rawPerson, &error_ );
    if ( !result_ )
    {
        NSLog( @"can not remove record from AddressBook" );
        return NO;
    }

    error_ = NULL;
    result_ = ABAddressBookSave( self.addressBook, &error_ );
    if ( !result_ )
    {
        NSLog( @"can not save AddressBook" );
        return NO;
    }

    return YES;
}

+(id)findContactWithContactInternalId:( ABRecordID )contactInternalId_
                          addressBook:( JFFAddressBook* )addressBook_
{
    ABAddressBookRef addressBookRef_ = addressBook_.rawBook;

    ABRecordRef record_ = ABAddressBookGetPersonWithRecordID( addressBookRef_
                                                             , contactInternalId_ );

    if ( NULL == record_ )
    {
        return nil;
    }

    return [ [ self alloc ] initWithPerson: record_
                               addressBook: addressBook_ ];
}

+(id)allContactsAddressBook:( JFFAddressBook* )addressBook_
{
    ABAddressBookRef addressBookRef_ = addressBook_.rawBook;

    NSArray* result_ = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople( addressBookRef_ );

    result_ = [ result_ map: ^id( id object_ )
    {
        ABRecordRef person_ = ( __bridge ABRecordRef )object_;
        return [ [ JFFContact alloc ] initWithPerson: person_
                                         addressBook: addressBook_ ];
    } ];

    return result_;
}

@end
