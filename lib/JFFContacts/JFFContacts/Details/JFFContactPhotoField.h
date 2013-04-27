#import "JFFContactField.h"

@interface JFFContactPhotoField : JFFContactField

+ (id)newContactFieldWithName:(NSString *)name
                       record:(ABRecordRef)record;

@end
