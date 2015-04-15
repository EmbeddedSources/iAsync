#import "JFFPendingActionSheet.h"

@implementation JFFPendingActionSheet

- (instancetype)initWithActionSheet:(JFFActionSheet *)actionSheet
                               view:(UIView *)view
{
    self = [super init];
    
    if (self) {
        
        self.actionSheet = actionSheet;
        self.view        = view;
    }
    
    return self;
}

@end
