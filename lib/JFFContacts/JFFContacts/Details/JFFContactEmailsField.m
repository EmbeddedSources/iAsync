#import "JFFContactEmailsField.h"

#import "NSArray+ContactsDataFilters.h"

@implementation JFFContactEmailsField

-(NSArray*)filteredValues:( NSArray* )values_
{
    return [ values_ jffContactsSelectWithEmailOnly ];
}

@end
