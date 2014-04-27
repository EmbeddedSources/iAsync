#import "JFFWaitAlertView.h"

#include <objc/message.h>

@interface JFFAlertView (JFFWaitAlertView)

@property (nonatomic, readonly) UIAlertView *alertView;

@end

@implementation JFFWaitAlertView

- (void)showActivityIndicatorView
{
    UIActivityIndicatorView* indicator_ = [ [ UIActivityIndicatorView alloc ] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge ];

    // Adjust the indicator so it is up a few pixels from the bottom of the alert
    indicator_.center = CGPointMake( self.alertView.bounds.size.width / 2.f
                                    , self.alertView.bounds.size.height / 2.f - 10.f );
    [ indicator_ startAnimating ];
    [ self.alertView addSubview: indicator_ ];
}

#pragma mark UIAlertViewDelegate

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    SEL selector = @selector(willPresentAlertView:);
    if ([[self superclass] hasInstanceMethodWithSelector:selector]) {
        
        struct objc_super superTarget;
        superTarget.receiver = self;
        superTarget.super_class = [self superclass];
        
        typedef void (*AlignMsgSendFunction)(struct objc_super *super, SEL, UIView *);
        AlignMsgSendFunction alignFunction = (AlignMsgSendFunction)objc_msgSendSuper;
        alignFunction(&superTarget, selector, alertView);
    }

    [self showActivityIndicatorView];
}

@end
