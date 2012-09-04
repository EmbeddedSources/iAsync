#import "JFFContactStringField.h"

@implementation JFFContactStringField

-(void)readPropertyFromRecord:( ABRecordRef )record_
{
    CFStringRef value_ = ABRecordCopyValue( record_, self.propertyID );
    self.value = ( __bridge_transfer NSString* )value_;
}

-(void)setPropertyFromValue:( id )value_
                   toRecord:( ABRecordRef )record_
{
    NSParameterAssert( value_ );
    self.value = value_;

    CFErrorRef error_ = NULL;
    bool didSet = ABRecordSetValue( record_
                                   , self.propertyID
                                   , (__bridge CFTypeRef)self.value
                                   , &error_);
    if (!didSet) { NSLog( @"can not set %@", self.name ); }
}

@end
