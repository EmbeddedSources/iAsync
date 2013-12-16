#import "JFFContactDateField.h"

@implementation JFFContactDateField

- (id)readProperty
{
    CFStringRef value = ABRecordCopyValue(self.record, self.propertyID);
    self.value = ( __bridge_transfer NSDate* )value;
    return self.value;
}

- (void)setPropertyFromValue:(id)value
{
    NSParameterAssert([value isKindOfClass:[NSString class]]);
    
    NSTimeInterval timeInterval_ = [value longLongValue] / 1000.;
    self.value = timeInterval_ == 0. ? nil : [ NSDate dateWithTimeIntervalSince1970: timeInterval_ ];
    
    CFErrorRef error = NULL;
    bool didSet = ABRecordSetValue(self.record,
                                   self.propertyID,
                                   (__bridge CFTypeRef)self.value,
                                   &error);
    if (!didSet) { NSLog( @"can not set %@", self.name ); }
}

@end
