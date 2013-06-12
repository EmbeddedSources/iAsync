#import "UIView+AllSubviews.h"

@implementation UIView (AllSubviews)

- (instancetype)findSubviewOfClass:(Class)cls
{
    if ([self isKindOfClass:cls])
        return self;
    
    for (UIView *subview in self.subviews) {
        
        UIView *overlayView = [subview findSubviewOfClass:cls];
        if (overlayView) {
            return overlayView;
        }
    }

    return nil;
}

- (void)logAllSubviewsWithLevel:( NSUInteger )level_
{
    NSLog( @"level: %d view: %@", level_++, self );

    for ( UIView* sub_view_ in self.subviews )
    {
        [ sub_view_ logAllSubviewsWithLevel: level_ ];
    }
}

- (void)logAllSubviews
{
    [ self logAllSubviewsWithLevel: 0 ];
}

- (void)removeAllSubviews
{
    [ self.subviews makeObjectsPerformSelector: @selector( removeFromSuperview ) ];
}

@end
