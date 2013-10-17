
@interface JFFContactsTest : GHAsyncTestCase
@end

@implementation JFFContactsTest

- (void)testCreateFindAndRemoveContact
{
    [self prepare];
    
    __block JFFContact *savedContact;
    __block ABRecordID contactInternalId = 0;
    
    static NSString* const contactFirstName_ = @"First Name";
    static NSString* const contactLastName_  = @"Last Name";
    NSArray* contactEmails_ = @[ @"vlg@wishdates.com", @"usstass1@gmail.com" ];
    NSArray* contactPhones_ = @[ @"+380684453923"    , @"+380679758477" ];
    UIImage* contactImage_  = [ UIImage imageNamed: @"avator" ];
    
    NSArray* contactAddresses_ = @[ @{
    JFFContactAddresseStreetKey () : @"address street" ,
    JFFContactAddresseCityKey   () : @"address city"   ,
    JFFContactAddresseStateKey  () : @"address state"  ,
    JFFContactAddresseZIPKey    () : @"address zip"    ,
    JFFContactAddresseCountryKey() : @"address country",
    }];
    
    JFFAddressBookSuccessCallback onSuccess = ^(JFFAddressBook *book)
    {
        NSDictionary *contactFields = @{
        JFFContactFirstName : contactFirstName_,
        JFFContactLastName  : contactLastName_ ,
        JFFContactPhoto     : contactImage_    ,
        JFFContactEmails    : contactEmails_   ,
        JFFContactPhones    : contactPhones_   ,
        JFFContactAddresses : contactAddresses_,
        };
        
        
        {
            JFFContact *newContact = [[JFFContact alloc] initWithFieldsDict:contactFields
                                                                addressBook:book];
            
            if ( ![ newContact save ] )
            {
                [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
                return;
            }
            
            contactInternalId = newContact.contactInternalId;
        }
        
        {
            savedContact = [JFFContact findContactWithContactInternalId:contactInternalId
                                                            addressBook:book];
            
            if ( !savedContact )
            {
                [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
                return;
            }
        }

        [self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
    };
    JFFAddressBookErrorCallback onFailure = ^( ABAuthorizationStatus status_, NSError* error_ )
    {
        [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
    };

    [JFFAddressBookFactory asyncAddressBookWithSuccessBlock:onSuccess
                                              errorCallback:onFailure];

    [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 10000. ];

    GHAssertEqualObjects( savedContact.firstName, contactFirstName_, @"contact fields values mismatch" );
    GHAssertEqualObjects( savedContact.lastName , contactLastName_ , @"contact fields values mismatch" );
    GHAssertEqualObjects( savedContact.emails   , contactEmails_   , @"contact fields values mismatch" );
    GHAssertEqualObjects( savedContact.phones   , contactPhones_   , @"contact fields values mismatch" );
    GHAssertEqualObjects( savedContact.addresses, contactAddresses_, @"contact fields values mismatch" );
    GHAssertNotNil( savedContact.photo, @"contact fields values mismatch" );
    
    onSuccess = ^(JFFAddressBook *book)
    {
        savedContact = [JFFContact findContactWithContactInternalId:contactInternalId
                                                        addressBook:book];
        
        if (![savedContact remove]) {
            
            [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
            return;
        }
    };
    
    [JFFAddressBookFactory asyncAddressBookWithSuccessBlock:onSuccess
                                              errorCallback:onFailure];
}

-(void)testEnumerateAllContacts
{
    [ self prepare ];

    __block NSArray* savedContacts_;
    __block NSArray* allContacts_;
    __block NSArray* contactIds_;

    static NSString* const contactFirstName_ = @"First Name";
    static NSString* const contactLastName_  = @"Last Name";
    NSArray* contactEmails_ = @[ @"vlg@wishdates.com", @"usstass1@gmail.com" ];
    NSArray* contactPhones_ = @[ @"+380684453923"    , @"+380679758477" ];
    UIImage* contactImage_  = [ UIImage imageNamed: @"avator" ];

    NSUInteger contactsCount_ = 5;

    JFFAddressBookSuccessCallback onSuccess = ^( JFFAddressBook* book_ )
    {
        NSDictionary* contactFields_ = @{
        JFFContactFirstName : contactFirstName_,
        JFFContactLastName  : contactLastName_ ,
        JFFContactPhoto     : contactImage_,
        JFFContactEmails    : contactEmails_,
        JFFContactPhones    : contactPhones_,
        };

        {
            NSArray* contacts_ = [ NSArray arrayWithSize: contactsCount_
                                                producer: ^id(NSUInteger index_)
            {
                return [ [ JFFContact alloc ] initWithFieldsDict: contactFields_
                                                     addressBook: book_ ];
            } ];

            for ( JFFContact* contact_ in contacts_ )
            {
                if ( ![ contact_ save ] )
                {
                    [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
                    return;
                }
            }

            contactIds_ = [ contacts_ map: ^id( JFFContact* contact_ )
            {
                return @( contact_.contactInternalId );
            } ];
        }

        {
            savedContacts_ = [ contactIds_ forceMap: ^id( NSNumber* contactId_ )
            {
                return [ JFFContact findContactWithContactInternalId: [ contactId_ longLongValue ]
                                                         addressBook: book_ ];
            } ];

            if ( [ savedContacts_ count ] < contactsCount_ ) {
                
                [self notify:kGHUnitWaitStatusFailure forSelector:_cmd];
                return;
            }
        }
        
        asyncAllContactsLoader()(nil, nil, ^(NSArray *result, NSError *error)
        {
            allContacts_ = result;
            [self notify:kGHUnitWaitStatusSuccess forSelector:_cmd];
        });
    };
    JFFAddressBookErrorCallback onFailure = ^( ABAuthorizationStatus status_, NSError* error_ )
    {
        [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
    };

    [JFFAddressBookFactory asyncAddressBookWithSuccessBlock:onSuccess
                                              errorCallback:onFailure];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10000.];
    
    for ( JFFContact* contact_ in savedContacts_ )
    {
        GHAssertEqualObjects( contact_.firstName, contactFirstName_, @"contact fields values mismatch" );
        GHAssertEqualObjects( contact_.lastName , contactLastName_ , @"contact fields values mismatch" );
        GHAssertEqualObjects( contact_.emails   , contactEmails_   , @"contact fields values mismatch" );
        GHAssertEqualObjects( contact_.phones   , contactPhones_   , @"contact fields values mismatch" );
        GHAssertNotNil( contact_.photo, @"contact fields values mismatch" );
    }

    GHAssertTrue( [ allContacts_ count ] >= [ savedContacts_ count ], @"contact fields values mismatch" );

    NSArray* savedContactsCopy_ = [ allContacts_ select: ^BOOL( JFFContact* contact_ )
    {
        return [ contactIds_ containsObject: @( contact_.contactInternalId ) ];
    } ];

    GHAssertTrue( contactsCount_ == [ savedContactsCopy_ count ], @"OK" );

    for ( JFFContact* contact_ in savedContactsCopy_ )
    {
        GHAssertEqualObjects( contact_.firstName, contactFirstName_, @"contact fields values mismatch" );
        GHAssertEqualObjects( contact_.lastName , contactLastName_ , @"contact fields values mismatch" );
        GHAssertEqualObjects( contact_.emails   , contactEmails_   , @"contact fields values mismatch" );
        GHAssertEqualObjects( contact_.phones   , contactPhones_   , @"contact fields values mismatch" );
        GHAssertNotNil( contact_.photo, @"contact fields values mismatch" );
    }
    
    onSuccess = ^(JFFAddressBook *book)
    {
        NSArray *savedContacts = [contactIds_ forceMap: ^id(NSNumber *contactId) {
            return [JFFContact findContactWithContactInternalId:[contactId longLongValue]
                                                    addressBook:book];
        }];
        
        [savedContacts enumerateObjectsUsingBlock:^(JFFContact *removedContact, NSUInteger idx, BOOL *stop) {
            
            if (![removedContact remove]) {
                
                [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
                return;
            }
        }];
    };
    
    [JFFAddressBookFactory asyncAddressBookWithSuccessBlock:onSuccess
                                              errorCallback:onFailure];
}

@end
