#import "JFFContactEmailsField.h"

#import "NSArray+ContactsDataFilters.h"

@implementation JFFContactEmailsField

- (NSArray *)filteredValues:(NSArray *)values
{
    return [values jffContactsSelectWithEmailOnly];
}

@end
