#import "NSArray+ContactsDataFilters.h"

@implementation NSArray (ContactsDataFilters)

- (instancetype)jffContactsSelectNotEmptyStrings
{
    NSArray *result = [self map:^id(NSString *str) {
        return [str stringByTrimmingWhitespaces];
    }];
    
    result = [result filter:^BOOL(NSString *str) {
        return [str length] != 0;
    }];
    
    return result;
}

- (instancetype)jffContactsSelectWithEmailOnly
{
    NSArray *result = [self map:^id(NSString *str) {
        return [str stringByTrimmingWhitespaces];
    }];
    
    result = [result filter:^BOOL(NSString *str) {
        return [str isEmailValid];
    }];
    
    return result;
}

@end
