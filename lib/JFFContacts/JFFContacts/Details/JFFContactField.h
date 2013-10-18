#import <AddressBook/AddressBook.h>

#import <Foundation/Foundation.h>

@interface JFFContactField : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) ABPropertyID propertyID;
@property (nonatomic, readonly) ABRecordRef record;

@property (nonatomic) id value;

+ (instancetype)newContactFieldWithName:(NSString *)name
                             propertyID:(ABPropertyID)propertyID
                                 record:(ABRecordRef)record;

- (void)setPropertyFromValue:(id)value;

@end
