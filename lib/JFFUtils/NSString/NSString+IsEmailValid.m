#import "NSString+IsEmailValid.h"

@implementation NSString (IsEmailValid)

//source: http://stackoverflow.com/questions/800123/best-practices-for-validating-email-address-in-objective-c-on-ios-2-0
-(BOOL)isEmailValid
{
    NSString* emailRegex_ = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate* emailTest_ = [ NSPredicate predicateWithFormat: @"SELF MATCHES %@", emailRegex_ ]; 

    return [ emailTest_ evaluateWithObject: self ];
}

@end
