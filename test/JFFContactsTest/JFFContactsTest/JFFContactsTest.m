
@interface JFFContactsTest : GHAsyncTestCase
@end

@implementation JFFContactsTest

- (void)testCreateFindAndRemoveContact
{
    __block JFFContact *savedContact;
    __block ABRecordID contactInternalId = 0;
    
    static NSString* const contactFirstName = @"First Name";
    static NSString* const contactLastName  = @"Last Name";
    NSArray *contactEmails = @[@"vlg@wishdates.com", @"usstass1@gmail.com"];
    NSArray *contactPhones = @[@"+380684453923"    , @"+380679758477"];
    UIImage *contactImage  = [UIImage imageNamed:@"avator"];
    
    NSArray *contactAddresses = @[ @{
    JFFContactAddresseStreetKey () : @"address street" ,
    JFFContactAddresseCityKey   () : @"address city"   ,
    JFFContactAddresseStateKey  () : @"address state"  ,
    JFFContactAddresseZIPKey    () : @"address zip"    ,
    JFFContactAddresseCountryKey() : @"address country",
    }];
    
    void (^block)(JFFSimpleBlock) = ^(JFFSimpleBlock finishTest) {
        
        JFFAddressBookSuccessCallback onSuccess = ^(JFFAddressBook *book) {
            
            NSDictionary *contactFields = @{
                                            JFFContactFirstName : contactFirstName,
                                            JFFContactLastName  : contactLastName ,
                                            JFFContactPhoto     : contactImage    ,
                                            JFFContactEmails    : contactEmails   ,
                                            JFFContactPhones    : contactPhones   ,
                                            JFFContactAddresses : contactAddresses,
                                            };
            
            
            {
                JFFContact *newContact = [[JFFContact alloc] initWithFieldsDict:contactFields
                                                                    addressBook:book];
                
                if (![newContact save]) {
                    
                    finishTest();
                    return;
                }
                
                contactInternalId = newContact.contactInternalId;
            }
            
            {
                savedContact = [JFFContact findContactWithContactInternalId:contactInternalId
                                                                addressBook:book];
                
                if (!savedContact) {
                    
                    finishTest();
                    return;
                }
            }
            
            finishTest();
        };
        JFFAddressBookErrorCallback onFailure = ^(ABAuthorizationStatus status, NSError *error) {
            
            finishTest();
        };
        
        [JFFAddressBookFactory asyncAddressBookWithSuccessBlock:onSuccess
                                                  errorCallback:onFailure];
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd
                                           timeout:1000.];
    
    GHAssertEqualObjects(savedContact.firstName, contactFirstName, @"contact fields values mismatch");
    GHAssertEqualObjects(savedContact.lastName , contactLastName , @"contact fields values mismatch");
    GHAssertEqualObjects(savedContact.emails   , contactEmails   , @"contact fields values mismatch");
    GHAssertEqualObjects(savedContact.phones   , contactPhones   , @"contact fields values mismatch");
    GHAssertEqualObjects(savedContact.addresses, contactAddresses, @"contact fields values mismatch");
    GHAssertNotNil(savedContact.photo, @"contact fields values mismatch");
    
    block = ^(JFFSimpleBlock finishTest) {
        
        JFFAddressBookErrorCallback onFailure = ^(ABAuthorizationStatus status, NSError *error) {
            
            finishTest();
        };
        
        JFFAddressBookSuccessCallback onSuccess = ^(JFFAddressBook *book) {
            
            savedContact = [JFFContact findContactWithContactInternalId:contactInternalId
                                                            addressBook:book];
            
            [savedContact remove];
            finishTest();
        };
        
        [JFFAddressBookFactory asyncAddressBookWithSuccessBlock:onSuccess
                                                  errorCallback:onFailure];
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd
                                           timeout:1000.];
}

- (void)testEnumerateAllContacts
{
    __block NSArray *savedContacts;
    __block NSArray *allContacts;
    __block NSArray *contactIds;
    
    static NSString *const contactFirstName = @"First Name";
    static NSString *const contactLastName  = @"Last Name";
    NSArray *contactEmails = @[@"vlg@wishdates.com", @"usstass1@gmail.com"];
    NSArray *contactPhones = @[@"+380684453923"    , @"+380679758477"];
    UIImage *contactImage  = [UIImage imageNamed:@"avator"];
    
    NSUInteger contactsCount = 5;
    
    void (^block)(JFFSimpleBlock) = ^(JFFSimpleBlock finishTest) {
        
        JFFAddressBookSuccessCallback onSuccess = ^(JFFAddressBook *book)
        {
            NSDictionary *contactFields = @{
            JFFContactFirstName : contactFirstName,
            JFFContactLastName  : contactLastName ,
            JFFContactPhoto     : contactImage    ,
            JFFContactEmails    : contactEmails   ,
            JFFContactPhones    : contactPhones   ,
            };

            {
                NSArray *contacts = [NSArray arrayWithSize:contactsCount
                                                  producer:^id(NSUInteger index) {
                                                      
                    return [[JFFContact alloc] initWithFieldsDict:contactFields
                                                      addressBook:book];
                }];
                
                for (JFFContact *contact in contacts)
                {
                    if (![contact save]) {
                        
                        finishTest();
                        return;
                    }
                }
                
                contactIds = [contacts map:^id(JFFContact *contact) {
                    
                    return @(contact.contactInternalId);
                }];
            }
            
            {
                savedContacts = [contactIds forceMap:^id(NSNumber *contactId)
                {
                    return [JFFContact findContactWithContactInternalId:[contactId longLongValue]
                                                            addressBook:book];
                }];
                
                if ([savedContacts count] < contactsCount) {
                    
                    finishTest();
                    return;
                }
            }
            
            asyncAllContactsLoader()(nil, nil, ^(NSArray *result, NSError *error) {
                
                allContacts = result;
                finishTest();
            });
        };
        JFFAddressBookErrorCallback onFailure = ^(ABAuthorizationStatus status, NSError *error) {
            
            finishTest();
        };
        
        [JFFAddressBookFactory asyncAddressBookWithSuccessBlock:onSuccess
                                                  errorCallback:onFailure];
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd
                                           timeout:1000.];
    
    for (JFFContact *contact in savedContacts) {
        
        GHAssertEqualObjects(contact.firstName, contactFirstName, @"contact fields values mismatch");
        GHAssertEqualObjects(contact.lastName , contactLastName , @"contact fields values mismatch");
        GHAssertEqualObjects(contact.emails   , contactEmails   , @"contact fields values mismatch");
        GHAssertEqualObjects(contact.phones   , contactPhones   , @"contact fields values mismatch");
        GHAssertNotNil(contact.photo, @"contact fields values mismatch");
    }
    
    GHAssertTrue([allContacts count] >= [savedContacts count], @"contact fields values mismatch" );
    
    NSArray *savedContactsCopy = [allContacts select:^BOOL(JFFContact *contact) {
        
        return [contactIds containsObject:@(contact.contactInternalId)];
    }];
    
    GHAssertTrue(contactsCount == [savedContactsCopy count], @"OK");
    
    for (JFFContact *contact in savedContactsCopy) {
        
        GHAssertEqualObjects(contact.firstName, contactFirstName, @"contact fields values mismatch");
        GHAssertEqualObjects(contact.lastName , contactLastName , @"contact fields values mismatch");
        GHAssertEqualObjects(contact.emails   , contactEmails   , @"contact fields values mismatch");
        GHAssertEqualObjects(contact.phones   , contactPhones   , @"contact fields values mismatch");
        GHAssertNotNil(contact.photo, @"contact fields values mismatch");
    }
    
    block = ^(JFFSimpleBlock finishTest) {
        
        JFFAddressBookSuccessCallback onSuccess = ^(JFFAddressBook *book)
        {
            NSArray *savedContacts = [contactIds forceMap:^id(NSNumber *contactId) {
                return [JFFContact findContactWithContactInternalId:[contactId longLongValue]
                                                        addressBook:book];
            }];
            
            [savedContacts enumerateObjectsUsingBlock:^(JFFContact *removedContact, NSUInteger idx, BOOL *stop) {
                
                if (![removedContact remove]) {
                    
                    finishTest();
                    return;
                }
            }];
            
            finishTest();
        };
        JFFAddressBookErrorCallback onFailure = ^(ABAuthorizationStatus status, NSError *error) {
            
            finishTest();
        };
        
        [JFFAddressBookFactory asyncAddressBookWithSuccessBlock:onSuccess
                                                  errorCallback:onFailure];
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd
                                           timeout:1000.];
}

@end
