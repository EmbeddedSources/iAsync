#import "JFFContactField.h"

@interface JFFContactDictionaryArrayField : JFFContactField

+(id)contactFieldWithName:( NSString* )name_
               propertyID:( ABPropertyID )propertyID_
                   labels:( NSArray* )labels_;

@end
