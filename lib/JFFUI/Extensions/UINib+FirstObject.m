#import "UINib+FirstObject.h"

@implementation UINib (FirstObject)

+(id)firstObjectOfNibNamed:( NSString* )nib_name_ owner:( id )owner_or_nil_
{
    UINib* nib_ = [ self nibWithNibName: nib_name_ bundle: nil ];
    return [ nib_ instantiateWithOwner: owner_or_nil_ options: nil ][ 0 ];
}

@end
