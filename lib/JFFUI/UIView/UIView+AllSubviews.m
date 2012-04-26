#import "UIView+AllSubviews.h"

@implementation UIView (AllSubviews)

-(UIView*)findSubviewOfClass:( Class )class_
{
    if ( [ self isKindOfClass: class_ ] )
        return self;

    for ( UIView* subview_ in self.subviews )
    {
        UIView* overlay_view_ = [ subview_ findSubviewOfClass: class_ ];
        if ( overlay_view_ )
        {
            return overlay_view_;
        }
    }

    return nil;
}

-(void)logAllSubviewsWithLevel:( NSUInteger )level_
{
    NSLog( @"level: %d view: %@", level_++, self );

    for ( UIView* sub_view_ in self.subviews )
    {
        [ sub_view_ logAllSubviewsWithLevel: level_ ];
    }
}

-(void)logAllSubviews
{
    [ self logAllSubviewsWithLevel: 0 ];
}

-(void)removeAllSubviews
{
    [ self.subviews makeObjectsPerformSelector: @selector( removeFromSuperview ) ];
}

@end
