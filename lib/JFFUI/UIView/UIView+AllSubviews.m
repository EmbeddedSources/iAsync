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

- (void)logAllSubviewsWithLevel:(NSUInteger)level
{
    NSLog( @"level: %lu view: %@", (unsigned long)level++, self );
    
    for (UIView *subView in self.subviews)
    {
        [subView logAllSubviewsWithLevel:level];
    }
}

- (void)logAllSubviews
{
    [self logAllSubviewsWithLevel:0];
}

- (void)removeAllSubviews
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
