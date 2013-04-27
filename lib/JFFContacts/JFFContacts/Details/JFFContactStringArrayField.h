#import "JFFContactField.h"

@interface JFFContactStringArrayField : JFFContactField

+ (id)newContactFieldWithName:(NSString *)name
                   propertyID:(ABPropertyID)propertyID
                       labels:(NSArray *)labels
                       record:(ABRecordRef)record;

@end
