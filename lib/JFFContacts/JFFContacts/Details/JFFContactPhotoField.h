#import "JFFContactField.h"

@interface JFFContactPhotoField : JFFContactField

+ (instancetype)newContactFieldWithName:(NSString *)name
                                 record:(ABRecordRef)record;

@end
