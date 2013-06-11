#import "JFFContactPhotoField.h"

@implementation JFFContactPhotoField

+ (instancetype)newContactFieldWithName:(NSString *)name
                                 record:(ABRecordRef)record
{
    return [self newContactFieldWithName:name
                              propertyID:0
                                  record:record];
    
}

- (id)readProperty
{
    CFDataRef dataRef = ABPersonCopyImageData(self.record);
    if (dataRef != NULL) {
        
        NSData *data = (__bridge_transfer NSData *)dataRef;
        self.value = [UIImage imageWithData:data];
    }
    return self.value;
}

- (void)setPropertyFromValue:(id)value
{
    NSParameterAssert( [value isKindOfClass:[UIImage class]]
                      || [value isKindOfClass:[NSData class]]
                      || [value isKindOfClass:[NSNull class]]);
    
    if ([value isKindOfClass:[NSNull class]])
    {
        if (ABPersonHasImageData(self.record)) {
            
            CFErrorRef error = NULL;
            ABPersonRemoveImageData(self.record, &error);
        }
        return;
    }
    
    NSData *data = value;
    if ([value isKindOfClass:[UIImage class]]) {
        
        data = UIImagePNGRepresentation(value);
    }
    
    if (data) {
        
        CFErrorRef error = NULL;
        bool didSet = ABPersonSetImageData(self.record, (__bridge CFDataRef)data, &error);
        if (!didSet) { NSLog( @"can not set %@", self.name ); }
    }
}

@end
