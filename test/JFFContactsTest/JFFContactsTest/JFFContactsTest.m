
@interface JFFContactsTest : GHAsyncTestCase
@end

@implementation JFFContactsTest

-(void)testCreateFindAndRemoveContact
{
    [ self prepare ];

    __block JFFContact* savedContact_;

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
    } ];

    JFFAddressBookSuccessCallback onSuccess_ = ^( JFFAddressBook* book_ )
    {
        NSDictionary* contactFields_ = @{
        JFFContactFirstName : contactFirstName_,
        JFFContactLastName  : contactLastName_ ,
        JFFContactPhoto     : contactImage_    ,
        JFFContactEmails    : contactEmails_   ,
        JFFContactPhones    : contactPhones_   ,
        JFFContactAddresses : contactAddresses_,
        };

        ABRecordID contactInternalId_ = 0;
        {
            JFFContact* newContact_ = [ [ JFFContact alloc ] initWithFieldsDict: contactFields_
                                                                    addressBook: book_ ];

            if ( ![ newContact_ save ] )
            {
                [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
                return;
            }

            contactInternalId_ = newContact_.contactInternalId;
        }

        {
            savedContact_ = [ JFFContact findContactWithContactInternalId: contactInternalId_
                                                              addressBook: book_ ];

            if ( !savedContact_ )
            {
                [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
                return;
            }
        }

        if ( ![ savedContact_ remove ] )
        {
            [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
            return;
        }

        [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
    };
    JFFAddressBookErrorCallback onFailure_ = ^( ABAuthorizationStatus status_, NSError* error_ )
    {
        [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
    };

    [ JFFAddressBookFactory asyncAddressBookWithSuccessBlock: onSuccess_
                                               errorCallback: onFailure_ ];

    [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 10000. ];

    GHAssertEqualObjects( savedContact_.firstName, contactFirstName_, @"contact fields values mismatch" );
    GHAssertEqualObjects( savedContact_.lastName , contactLastName_ , @"contact fields values mismatch" );
    GHAssertEqualObjects( savedContact_.emails   , contactEmails_   , @"contact fields values mismatch" );
    GHAssertEqualObjects( savedContact_.phones   , contactPhones_   , @"contact fields values mismatch" );
    GHAssertEqualObjects( savedContact_.addresses, contactAddresses_, @"contact fields values mismatch" );
    GHAssertNotNil( savedContact_.photo, @"contact fields values mismatch" );
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

    JFFAddressBookSuccessCallback onSuccess_ = ^( JFFAddressBook* book_ )
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

            if ( [ savedContacts_ count ] < contactsCount_ )
            {
                [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
                return;
            }
        }

        asyncAllContactsLoader()( nil, nil, ^( NSArray* result_, NSError* error_ )
        {
            allContacts_ = result_;

            for ( JFFContact* contact_ in savedContacts_ )
            {
                if ( ![ contact_ remove ] )
                {
                    [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
                    return;
                }
            }

            [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
        } );
    };
    JFFAddressBookErrorCallback onFailure_ = ^( ABAuthorizationStatus status_, NSError* error_ )
    {
        [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
    };

    [ JFFAddressBookFactory asyncAddressBookWithSuccessBlock: onSuccess_
                                               errorCallback: onFailure_ ];

    [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 10000. ];

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
}

@end
