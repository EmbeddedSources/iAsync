#import "JFFAlertButton.h"

@implementation JFFAlertButton

@synthesize title;
@synthesize action;

-(id)initButton:( NSString* )title_ action:( JFFSimpleBlock )action_
{
    self = [ super init ];

    if ( self )
    {
        self.title = title_;
        self.action = action_;
    }

    return self;
}

+(id)alertButton:( NSString* )title_ action:( JFFSimpleBlock )action_
{
    return [ [ self alloc ] initButton: title_ action: action_ ];
}

@end
