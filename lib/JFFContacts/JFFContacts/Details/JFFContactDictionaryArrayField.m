#import "JFFContactDictionaryArrayField.h"

#import "NSArray+kABMultiValue.h"
#import "NSArray+ContactsDataFilters.h"

//STODO remove duplicates
static ABMutableMultiValueRef createMutableMultiValueWithArray( NSArray* elements_
                                                               , NSArray* labels_ )
{
    ABMutableMultiValueRef result = ABMultiValueCreateMutable( kABMultiDictionaryPropertyType );

    NSUInteger index_ = 0;
    for ( NSDictionary* element_ in elements_ )
    {
        id label_ = [ labels_ noThrowObjectAtIndex: index_ ];
        if ( ![ label_ isKindOfClass: [ NSDictionary class ] ] )
            label_ = nil;

        ABMultiValueAddValueAndLabel( result
                                     , (__bridge CFTypeRef)element_
                                     , (__bridge CFTypeRef)label_
                                     , NULL );
        ++index_;
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

-(void)setPropertyFromValue:( id )value_
                   toRecord:( ABRecordRef )record_
{
    NSParameterAssert( [ value_ isKindOfClass: [ NSArray class ] ] );

    self.value = value_;

    CFErrorRef error_ = NULL;
    ABMutableMultiValueRef values_ = createMutableMultiValueWithArray( value_, self->_labels );
    BOOL didSet = ABRecordSetValue( record_
                                   , self.propertyID
                                   , values_
                                   , &error_ );
    if (!didSet) { NSLog( @"can not set %@", self.name ); }
    if ( values_ )
        CFRelease( values_ );
}

@end
