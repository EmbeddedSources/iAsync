#import "JFFContactDateField.h"

@implementation JFFContactDateField

-(void)readPropertyFromRecord:( ABRecordRef )record_
{
    CFStringRef value_ = ABRecordCopyValue( record_, self.propertyID );
    self.value = ( __bridge_transfer NSDate* )value_;
}

-(void)setPropertyFromValue:( id )value_
                   toRecord:( ABRecordRef )record_
{
    NSParameterAssert( [ value_ isKindOfClass: [ NSString class ] ] );

    NSTimeInterval timeInterval_ = [ value_ longLongValue ] / 1000.;
    self.value = timeInterval_ == 0. ? nil : [ NSDate dateWithTimeIntervalSince1970: timeInterval_ ];

    CFErrorRef error_ = NULL;
    bool didSet = ABRecordSetValue( record_
                                   , self.propertyID
                                   , (__bridge CFTypeRef)self.value
                                   , &error_);
    if (!didSet) { NSLog( @"can not set %@", self.name ); }
}

@end
