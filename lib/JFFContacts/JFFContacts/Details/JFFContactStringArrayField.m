#import "JFFContactStringArrayField.h"

#import "NSArray+kABMultiValue.h"
#import "NSArray+ContactsDataFilters.h"

static ABMutableMultiValueRef createMutableMultiValueWithArray(NSArray *elements,
                                                               NSArray *labels)
{
    ABMutableMultiValueRef result = ABMultiValueCreateMutable(kABMultiStringPropertyType);

    NSUInteger index = 0;
    for (NSString *element in elements)
    {
        id label = [labels noThrowObjectAtIndex:index];
        if (![label isKindOfClass:[NSString class]])
            label = nil;
        
        ABMultiValueAddValueAndLabel(result,
                                     (__bridge CFTypeRef)element,
                                     (__bridge CFTypeRef)label,
                                     NULL);
        ++index;
    }
    
    return result;
}

@interface JFFContactStringArrayField ()
@end

@implementation JFFContactStringArrayField
{
    NSArray *_labels;
}

+ (instancetype)newContactFieldWithName:(NSString *)name
                             propertyID:(ABPropertyID)propertyID
                                 labels:(NSArray *)labels
                                 record:(ABRecordRef)record
{
    JFFContactStringArrayField *result = [self newContactFieldWithName:name
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
    
    self.value = [NSArray arrayWithMultyValue:value];
    
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
    self.value = [self filteredValues:value];
    
    CFErrorRef error = NULL;
    ABMutableMultiValueRef values_ = createMutableMultiValueWithArray(self.value, _labels);
    BOOL didSet = ABRecordSetValue(self.record,
                                   self.propertyID,
                                   values_,
                                   &error);
    if (!didSet) { NSLog( @"can not set %@", self.name ); }
    if ( values_ )
        CFRelease( values_ );
}

@end
