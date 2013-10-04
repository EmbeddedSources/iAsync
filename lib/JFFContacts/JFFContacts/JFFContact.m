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

static ABRecordRef createOrGetContactPerson(ABRecordID contactInternalId,
                                            ABAddressBookRef addressBook)
{
    if (contactInternalId != 0) {
        
        ABRecordRef result = ABAddressBookGetPersonWithRecordID(addressBook,
                                                                contactInternalId);

        if (result) {
            CFRetain(result);
            return result;
        }
    }
    
    return ABPersonCreate();
}

@interface JFFContact ()

@property (nonatomic) BOOL newContact;

- (ABRecordRef)rawPerson CF_RETURNS_NOT_RETAINED;
- (void)setRawPerson:(ABRecordRef)person_;

@end

@implementation JFFContact
{
    NSMutableDictionary *_fieldByName;
    JFFAddressBook      *_addressBookWrapper;
    ABRecordRef          _person;
}

@dynamic addressBook;

@dynamic firstName,
lastName,
company,
emails,
phones,
sites,
birthday,
photo,
addresses;

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)forwardingTargetForSelector:(SEL)selector
{
    NSString *propertyName = NSStringFromSelector(selector);
    JFFContactField *field = _fieldByName[propertyName];
    if (!field) {
        
        propertyName = [propertyName propertyGetNameFromPropertyName];
        field = _fieldByName[propertyName];
    }
    return field?:self;
}

- (void)dealloc
{
    self.rawPerson = nil;
}

- (void)addField:(JFFContactField *)field
{
    _fieldByName[field.name] = field;
}

- (void)initializeDynamicFields
{
    _fieldByName = [NSMutableDictionary new];
    
    NSDictionary* fieldNameByPropertyId_ = @{
    @(kABPersonFirstNameProperty)    : JFFContactFirstName,
    @(kABPersonLastNameProperty)     : JFFContactLastName ,
    @(kABPersonOrganizationProperty) : JFFContactCompany  ,
    @(kABPersonBirthdayProperty)     : JFFContactBirthday ,
    };
    
    ABRecordRef person = self.person;
    
    [fieldNameByPropertyId_ enumerateKeysAndObjectsUsingBlock:^(NSNumber *propertyID, id fieldName, BOOL *stop) {
        
        JFFContactStringField *field = [JFFContactStringField newContactFieldWithName:fieldName
                                                                           propertyID:(ABPropertyID)[propertyID longLongValue]
                                                                               record:person];
        
        [self addField:field];
    }];
    
    [self addField:[JFFContactPhotoField newContactFieldWithName:JFFContactPhoto record:person]];
    
    //JTODO localize all labels
    NSArray *labels = @[@"home", @"work"];
    [self addField:[JFFContactEmailsField newContactFieldWithName:JFFContactEmails
                                                       propertyID:kABPersonEmailProperty
                                                           labels:labels
                                                           record:person]];
    
    labels = @[
    @"mobile",
    @"iPhone",
    @"home",
    @"work",
    @"main",
    @"home fax",
    @"work fax",
    @"other fax",
    @"pager",
    @"other",
    ];
    [self addField:[JFFContactStringArrayField newContactFieldWithName:JFFContactPhones
                                                            propertyID:kABPersonPhoneProperty
                                                                labels:labels
                                                                record:person]];
    
    labels = @[
    @"home page",
    @"home",
    @"work",
    @"other"
    ];
    [self addField:[JFFContactStringArrayField newContactFieldWithName:JFFContactWebsites
                                                            propertyID:kABPersonURLProperty
                                                                labels:labels
                                                                record:person]];
    
    labels = @[
    @"home",
    @"work",
    @"other",
    ];
    [self addField:[JFFContactDictionaryArrayField newContactFieldWithName:JFFContactAddresses
                                                                propertyID:kABPersonAddressProperty
                                                                    labels:labels
                                                                    record:person]];
}

- (instancetype)initWithPerson:(ABRecordRef)person
                   addressBook:(JFFAddressBook *)addressBook
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    NSParameterAssert(person);
    NSParameterAssert(nil!=addressBook);
    _addressBookWrapper = addressBook;
    
    _contactInternalId = ABRecordGetRecordID(person);
    
    [self initializeDynamicFields];
    
    return self;
}

- (instancetype)initWithFieldsDict:(NSDictionary *)args
                       addressBook:(JFFAddressBook *)addressBook
{
    self = [super init];
    
    NSParameterAssert(nil != addressBook);
    
    if (!self) {
        return nil;
    }
    
    _addressBookWrapper = addressBook;
    
    NSString *contactInternalId = args[@"contactInternalId"];
    _contactInternalId = (ABRecordID)[contactInternalId longLongValue];
    self.newContact = contactInternalId == nil;
    
    [self initializeDynamicFields];
    
    [args enumerateKeysAndObjectsUsingBlock:^(id fieldName, id value, BOOL *stop)
    {
        JFFContactField *field = _fieldByName[fieldName];
        if (!field) {
            NSLog( @"!!!WARNING!!! unsupported field name: %@", fieldName);
        }
        [field setPropertyFromValue:value];
    }];
    
    return self;
}

- (ABAddressBookRef)addressBook
{
    return _addressBookWrapper.rawBook;
}

- (ABRecordRef)person
{
    if (!_person) {
        
        _person = createOrGetContactPerson(self.contactInternalId, self.addressBook);
    }
    return _person;
}

- (ABRecordRef)rawPerson
{
    return _person;
}

- (void)setRawPerson:(ABRecordRef)person
{
    if (person == _person) {
        return;
    }
    
    if (NULL != _person) {
        
        CFRelease(_person);
    }
    _person = NULL;
    
    if (NULL != person) {
        
        _person = CFRetain(person);
    }
}

- (BOOL)save
{
    CFErrorRef error = NULL;
    
    bool result = false;
    if (self.newContact) {
        result = ABAddressBookAddRecord(self.addressBook, self.person, &error);
        if (!result) {
            NSLog(@"can not add Person");
            return NO;
        }
    }
    
    result = ABAddressBookSave(self.addressBook, &error);
    if (!result) {
        NSLog(@"can not save Person");
        return NO;
    }
    
    _contactInternalId = ABRecordGetRecordID(self.person);
    
    return YES;
}

- (BOOL)remove
{
    if (0 == _contactInternalId || NULL == self.rawPerson) {
        NSLog( @"record has no id" );
        return NO;
    }
    
    CFErrorRef error = NULL;
    bool result = ABAddressBookRemoveRecord( self.addressBook, self.rawPerson, &error );
    if (!result) {
        
        NSLog(@"can not remove record from AddressBook");
        return NO;
    }
    
    error = NULL;
    result = ABAddressBookSave(self.addressBook, &error);
    if (!result) {
        
        NSLog(@"can not save AddressBook");
        return NO;
    }
    
    return YES;
}

+ (instancetype)findContactWithContactInternalId:(ABRecordID)contactInternalId
                                     addressBook:(JFFAddressBook *)addressBook
{
    ABAddressBookRef addressBookRef = addressBook.rawBook;
    
    ABRecordRef record = ABAddressBookGetPersonWithRecordID(addressBookRef,
                                                            contactInternalId);
    
    if (NULL == record) {
        return nil;
    }
    
    return [[self alloc] initWithPerson:record
                            addressBook:addressBook];
}

+ (NSArray *)allContactsAddressBook:(JFFAddressBook *)addressBook
{
    ABAddressBookRef addressBookRef = addressBook.rawBook;
    
    NSArray *result = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    result = [result map:^id(id object) {
        ABRecordRef person = (__bridge ABRecordRef)object;
        return [[JFFContact alloc] initWithPerson:person
                                      addressBook:addressBook];
    }];
    
    return result;
}

@end
