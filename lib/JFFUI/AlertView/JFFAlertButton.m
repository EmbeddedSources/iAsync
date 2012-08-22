#import "JFFAlertButton.h"

@implementation JFFAlertButton

-(id)initButton:( NSString* )title_ action:( JFFSimpleBlock )action_
{
    self = [ super init ];

    if ( self )
    {
        self->_title  = title_;
        self->_action = action_;
    }

    return self;
}

+(id)alertButton:( NSString* )title_ action:( JFFSimpleBlock )action_
{
    return [ [ self alloc ] initButton: title_ action: action_ ];
}

@end
