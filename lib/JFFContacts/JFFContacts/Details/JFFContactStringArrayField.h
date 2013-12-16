#import "JFFContactField.h"

@interface JFFContactStringArrayField : JFFContactField

+ (instancetype)newContactFieldWithName:(NSString *)name
                             propertyID:(ABPropertyID)propertyID
                                 labels:(NSArray *)labels
                                 record:(ABRecordRef)record;

@end
