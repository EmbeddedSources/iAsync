#import "JFFPendingActionSheet.h"

@implementation JFFPendingActionSheet

-(id)initWithActionSheet:( JFFActionSheet* )actionSheet_
                    view:( UIView* )view_
{
    self = [ super init ];
    
    if ( self )
    {
        self.actionSheet = actionSheet_;
        self.view        = view_;
    }
    
    return self;
}

@end
