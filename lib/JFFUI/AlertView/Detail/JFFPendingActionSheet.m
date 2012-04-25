#import "JFFPendingActionSheet.h"

@implementation JFFPendingActionSheet

@synthesize actionSheet = _actionSheet;
@synthesize view        = _view;

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
