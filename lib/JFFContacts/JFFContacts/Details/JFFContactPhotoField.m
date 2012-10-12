#import "JFFContactPhotoField.h"

@implementation JFFContactPhotoField

+(id)contactFieldWithName:( NSString* )name_
{
    return [ self contactFieldWithName: name_
                            propertyID: 0 ];
    
}

-(void)readPropertyFromRecord:( ABRecordRef )record_
{
    CFDataRef dataRef_ = ABPersonCopyImageData( record_ );
    if ( dataRef_ )
    {
        NSData* data_ = ( __bridge_transfer NSData* )dataRef_;
        self.value = [ UIImage imageWithData: data_ ];
    }
}

-(void)setPropertyFromValue:( id )value_
                   toRecord:( ABRecordRef )record_
{
    NSParameterAssert( [ value_ isKindOfClass: [ UIImage class ] ]
                      || [ value_ isKindOfClass: [ NSData class ] ]
                      || [ value_ isKindOfClass: [ NSNull class ] ] );

    if ( [ value_ isKindOfClass: [ NSNull class ] ] )
    {
        if ( ABPersonHasImageData( record_ ) )
        {
            CFErrorRef error = NULL;
            ABPersonRemoveImageData( record_, &error );
        }
        return;
    }

    NSData* data_ = value_;
    if ( [ value_ isKindOfClass: [ UIImage class ] ] )
    {
        data_ = UIImagePNGRepresentation( value_ );
    }

    if ( data_ )
    {
        CFErrorRef error = NULL;
        bool didSet = ABPersonSetImageData( record_, ( __bridge CFDataRef )data_, &error );
        if (!didSet) { NSLog( @"can not set %@", self.name ); }
    }
}

@end
