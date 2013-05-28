#import "UINib+FirstObject.h"

@implementation UINib (FirstObject)

+ (id)firstObjectOfNibNamed:(NSString *)nibName owner:(id)ownerOrNil
{
    UINib *nib = [self nibWithNibName:nibName bundle:nil];
    return [nib instantiateWithOwner:ownerOrNil options:nil][0];
}

@end
