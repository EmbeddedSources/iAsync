#import "NSArray+ContactsDataFilters.h"

@implementation NSArray (ContactsDataFilters)

-(id)jffContactsSelectNotEmptyStrings
{
    NSArray* result_ = [ self map: ^id( NSString* str_ )
    {
        return [ str_ stringByTrimmingWhitespaces ];
    } ];

    result_ = [ result_ select: ^BOOL( NSString* str_ )
    {
        return [ str_ length ] != 0;
    } ];

    return result_;
}

-(id)jffContactsSelectWithEmailOnly
{
    NSArray* result_ = [ self map: ^id( NSString* str_ )
    {
        return [ str_ stringByTrimmingWhitespaces ];
    } ];

    result_ = [ result_ select: ^BOOL( NSString* str_ )
    {
        return [ str_ isEmailValid ];
    } ];

    return result_;
}

@end
