#import "JFFWaitAlertView.h"

#include <objc/message.h>

@interface JFFAlertView (JFFWaitAlertView)

@property ( nonatomic, readonly ) UIAlertView* alertView;

@end

@implementation JFFWaitAlertView

-(void)showActivityIndicatorView
{
    UIActivityIndicatorView* indicator_ = [ [ UIActivityIndicatorView alloc ] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge ];

    // Adjust the indicator so it is up a few pixels from the bottom of the alert
    indicator_.center = CGPointMake( self.alertView.bounds.size.width / 2.f
                                    , self.alertView.bounds.size.height / 2.f - 10.f );
    [ indicator_ startAnimating ];
    [ self.alertView addSubview: indicator_ ];
}

#pragma mark UIAlertViewDelegate

-(void)willPresentAlertView:( UIAlertView* )alertView_
{
    SEL selector_ = @selector( willPresentAlertView: );
    if ( [ [ self superclass ] hasInstanceMethodWithSelector: selector_ ] )
    {
        struct objc_super superTarget_;
        superTarget_.receiver = self;
        superTarget_.super_class = [ self superclass ];
        objc_msgSendSuper( &superTarget_, selector_, alertView_ );
    }

    [ self showActivityIndicatorView ];
}

@end
