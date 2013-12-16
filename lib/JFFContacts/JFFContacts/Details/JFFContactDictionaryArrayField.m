#import "JFFContactDictionaryArrayField.h"

#import "NSArray+kABMultiValue.h"
#import "NSArray+ContactsDataFilters.h"

static ABMutableMultiValueRef createMutableMultiValueWithArray(NSArray *elements,
                                                               NSArray *labels)
{
    ABMutableMultiValueRef result = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    
    NSUInteger index = 0;
    for (NSDictionary *element in elements) {
        
        id label = [labels noThrowObjectAtIndex:index];
        if (![label isKindOfClass:[NSDictionary class]])
            label = nil;
        
        ABMultiValueAddValueAndLabel(result,
                                     (__bridge CFTypeRef)element,
                                     (__bridge CFTypeRef)label,
                                     NULL);
        ++index;
    }
    
    return result;
}

@interface JFFContactDictionaryArrayField ()
@end

@implementation JFFContactDictionaryArrayField
{
    NSArray* _labels;
}

+ (instancetype)newContactFieldWithName:(NSString *)name
                             propertyID:(ABPropertyID)propertyID
                                 labels:(NSArray *)labels
                                 record:(ABRecordRef)record
{
    JFFContactDictionaryArrayField *result = [self newContactFieldWithName:name
                                                                propertyID:propertyID
                                                                    record:record];
    
    if (result) {
        result->_labels = labels;
    }
    
    return result;
}

- (id)readProperty
{
    CFTypeRef value = ABRecordCopyValue(self.record, self.propertyID);
    NSArray *address_ = [ NSArray arrayWithMultyValue:value];
    
    self.value = address_;
    
    if (value)
        CFRelease(value);
    
    return self.value;
}

- (NSArray *)filteredValues:(NSArray *)values
{
    return [values jffContactsSelectNotEmptyStrings];
}

- (void)setPropertyFromValue:(id)value
{
    NSParameterAssert([value isKindOfClass:[NSArray class]]);

    self.value = value;

    CFErrorRef error = NULL;
    ABMutableMultiValueRef values = createMutableMultiValueWithArray(value, _labels);
    BOOL didSet = ABRecordSetValue(self.record,
                                   self.propertyID,
                                   values,
                                   &error);
    if (!didSet) { NSLog( @"can not set %@", self.name ); }
    if (values)
        CFRelease(values);
}

@end
