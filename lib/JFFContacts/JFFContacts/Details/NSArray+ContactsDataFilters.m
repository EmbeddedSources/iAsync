#import "NSArray+ContactsDataFilters.h"

@implementation NSArray (ContactsDataFilters)

- (id)jffContactsSelectNotEmptyStrings
{
    NSArray *result = [self map:^id(NSString *str) {
        return [str stringByTrimmingWhitespaces];
    }];
    
    result = [result select:^BOOL(NSString *str) {
        return [str length ] != 0;
    }];
    
    return result;
}

- (id)jffContactsSelectWithEmailOnly
{
    NSArray *result = [self map:^id(NSString *str) {
        return [str stringByTrimmingWhitespaces];
    } ];
    
    result = [result select:^BOOL(NSString *str) {
        return [str isEmailValid];
    }];
    
    return result;
}

@end
