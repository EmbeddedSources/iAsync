#import "JFFContactField.h"

@interface JFFContactStringArrayField : JFFContactField

+(id)contactFieldWithName:( NSString* )name_
               propertyID:( ABPropertyID )propertyID_
                   labels:( NSArray* )labels_;

@end
