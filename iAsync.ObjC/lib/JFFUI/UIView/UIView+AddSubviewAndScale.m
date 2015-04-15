#import "UIView+AddSubviewAndScale.h"

@implementation UIView (AddSubviewAndScale)

- (void)addSubviewAndScale:(UIView *)view
{
    [view removeFromSuperview];
    
    view.frame = self.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:view];
}

@end
