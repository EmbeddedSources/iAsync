#import "JFFContactStringField.h"

@implementation JFFContactStringField

- (id)readProperty
{
    CFStringRef value = ABRecordCopyValue(self.record, self.propertyID);
    self.value = (__bridge_transfer NSString *)value;
    
    return self.value;
}

- (void)setPropertyFromValue:(id)value
{
    NSParameterAssert(value);
    self.value = value;
    
    CFErrorRef error = NULL;
    bool didSet = ABRecordSetValue(self.record,
                                   self.propertyID,
                                   (__bridge CFTypeRef)self.value,
                                   &error);
    if (!didSet) { NSLog( @"can not set %@", self.name ); }
}

@end
