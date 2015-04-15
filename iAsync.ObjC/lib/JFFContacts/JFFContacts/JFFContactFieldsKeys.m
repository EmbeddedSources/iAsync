#import "JFFContactFieldsKeys.h"

#import <AddressBook/AddressBook.h>

NSString* const JFFContactFirstName = @"firstName";
NSString* const JFFContactLastName  = @"lastName" ;
NSString* const JFFContactCompany   = @"company"  ;
NSString* const JFFContactBirthday  = @"birthday" ;
NSString* const JFFContactPhoto     = @"photo"    ;
NSString* const JFFContactEmails    = @"emails"   ;
NSString* const JFFContactPhones    = @"phones"   ;
NSString* const JFFContactWebsites  = @"websites" ;
NSString* const JFFContactAddresses = @"addresses";

NSString *JFFContactAddresseStreetKey()
{
    return (__bridge NSString *)kABPersonAddressStreetKey;
}

NSString *JFFContactAddresseCityKey()
{
    return (__bridge NSString *)kABPersonAddressCityKey;
}

NSString *JFFContactAddresseStateKey()
{
    return (__bridge NSString *)kABPersonAddressStateKey;
}

NSString *JFFContactAddresseZIPKey()
{
    return (__bridge NSString *)kABPersonAddressZIPKey;
}

NSString *JFFContactAddresseCountryKey()
{
    return (__bridge NSString *)kABPersonAddressCountryKey;
}
