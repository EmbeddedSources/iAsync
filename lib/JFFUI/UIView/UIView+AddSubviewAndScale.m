#import "UIView+AddSubviewAndScale.h"

@implementation UIView (AddSubviewAndScale)

-(void)addSubviewAndScale:( UIView* )view_
{
    [ view_ removeFromSuperview ];

    view_.frame = self.bounds;
    view_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [ self addSubview: view_ ];
}

@end
