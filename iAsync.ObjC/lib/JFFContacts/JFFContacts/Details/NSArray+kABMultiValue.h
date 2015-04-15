#import <Foundation/Foundation.h>

#import <AddressBook/ABMultiValue.h>

@interface NSArray (kABMultiValue)

+ (instancetype)arrayWithMultyValue:(ABMutableMultiValueRef)multyValue;

@end
