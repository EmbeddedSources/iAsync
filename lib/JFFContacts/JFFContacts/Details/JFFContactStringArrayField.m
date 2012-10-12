#import "JFFContactStringArrayField.h"

#import "NSArray+kABMultiValue.h"
#import "NSArray+ContactsDataFilters.h"

static ABMutableMultiValueRef createMutableMultiValueWithArray( NSArray* elements_
                                                               , NSArray* labels_ )
{
    ABMutableMultiValueRef result = ABMultiValueCreateMutable( kABMultiStringPropertyType );

    NSUInteger index_ = 0;
    for ( NSString* element_ in elements_ )
    {
        id label_ = [ labels_ noThrowObjectAtIndex: index_ ];
        if ( ![ label_ isKindOfClass: [ NSString class ] ] )
            label_ = nil;

        ABMultiValueAddValueAndLabel( result
                                     , (__bridge CFTypeRef)element_
                                     , (__bridge CFTypeRef)label_
                                     , NULL );
        ++index_;
    }

    return result;
}

@interface JFFContactStringArrayField ()
@end

@implementation JFFContactStringArrayField
{
    NSArray* _labels;
}

+(id)contactFieldWithName:( NSString* )name_
               propertyID:( ABPropertyID )propertyID_
                   labels:( NSArray* )labels_
{
    JFFContactStringArrayField* result_ = [ self contactFieldWithName: name_
                                                          propertyID: propertyID_ ];

    result_->_labels = labels_;

    return result_;
}

-(void)readPropertyFromRecord:( ABRecordRef )record_
{
    CFTypeRef value_ = ABRecordCopyValue( record_, self.propertyID );
    self.value = [ NSArray arrayWithMultyValue: value_ ];
    if ( value_ )
        CFRelease( value_ );
}

-(NSArray*)filteredValues:( NSArray* )values_
{
    return [ values_ jffContactsSelectNotEmptyStrings ];
}

- (void)setPropertyFromValue:(id)value_
                    toRecord:(ABRecordRef)record_
{
    NSParameterAssert([value_ isKindOfClass:[NSArray class]]);
    self.value = [ self filteredValues: value_ ];

    CFErrorRef error = NULL;
    ABMutableMultiValueRef values_ = createMutableMultiValueWithArray( self.value, self->_labels );
    BOOL didSet = ABRecordSetValue( record_
                                   , self.propertyID
                                   , values_
                                   , &error);
    if (!didSet) { NSLog( @"can not set %@", self.name ); }
    if ( values_ )
        CFRelease( values_ );
}

@end
