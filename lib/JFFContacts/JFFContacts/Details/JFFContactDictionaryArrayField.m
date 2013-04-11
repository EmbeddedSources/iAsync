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
        if ( ![label isKindOfClass: [ NSDictionary class ] ] )
            label = nil;
        
        ABMultiValueAddValueAndLabel( result
                                     , (__bridge CFTypeRef)element
                                     , (__bridge CFTypeRef)label
                                     , NULL );
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

+(id)contactFieldWithName:( NSString* )name_
               propertyID:( ABPropertyID )propertyID_
                   labels:( NSArray* )labels_
{
    JFFContactDictionaryArrayField* result_ = [ self contactFieldWithName: name_
                                                              propertyID: propertyID_ ];

    result_->_labels = labels_;

    return result_;
}

-(void)readPropertyFromRecord:( ABRecordRef )record_
{
    CFTypeRef value_ = ABRecordCopyValue( record_, self.propertyID );
    NSArray* address_ = [ NSArray arrayWithMultyValue: value_ ];

    self.value = address_;

    if ( value_ )
        CFRelease( value_ );
}

-(NSArray*)filteredValues:( NSArray* )values_
{
    return [ values_ jffContactsSelectNotEmptyStrings ];
}

- (void)setPropertyFromValue:( id )value_
                    toRecord:( ABRecordRef )record_
{
    NSParameterAssert([value_ isKindOfClass:[NSArray class]]);

    self.value = value_;

    CFErrorRef error = NULL;
    ABMutableMultiValueRef values_ = createMutableMultiValueWithArray( value_, _labels );
    BOOL didSet = ABRecordSetValue( record_
                                   , self.propertyID
                                   , values_
                                   , &error );
    if (!didSet) { NSLog( @"can not set %@", self.name ); }
    if ( values_ )
        CFRelease( values_ );
}

@end
