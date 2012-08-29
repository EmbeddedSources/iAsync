#import "UIViewController+OnCloseActions.h"

#import <JFFUtils/NSObject/NSObject+RuntimeExtensions.h>

typedef void (^JFFCloseSelfBlock) ( BOOL animated_ );

static char closeActionKey_;
static char willCloseActionKey_;
static char didCloseActionKey_;

@interface UIViewController (OnCloseActionsPrivate)

@property ( nonatomic, copy ) JFFCloseSelfBlock closeAction;
@property ( nonatomic, retain, readonly ) UIViewController* actController;

@end

@implementation UIViewController (OnCloseActions)

-(void)setCloseAction:( JFFCloseSelfBlock )close_action_
{
    objc_setAssociatedObject( self, &closeActionKey_, close_action_, OBJC_ASSOCIATION_COPY_NONATOMIC ) ;   
}

-(JFFCloseSelfBlock)closeAction
{
    return ( JFFCloseSelfBlock )objc_getAssociatedObject( self, &closeActionKey_ );
}

-(void)setWillCloseAction:( JFFWillCloseActionBlock )will_close_action_
{
    objc_setAssociatedObject( self.actController, &willCloseActionKey_, will_close_action_, OBJC_ASSOCIATION_COPY_NONATOMIC ) ;   
}

-(JFFWillCloseActionBlock)willCloseAction
{
    return ( JFFWillCloseActionBlock )objc_getAssociatedObject( self.actController, &willCloseActionKey_ );
}

-(void)setDidCloseAction:( JFFDidCloseActionBlock )did_close_action_
{
    objc_setAssociatedObject( self.actController, &didCloseActionKey_, did_close_action_, OBJC_ASSOCIATION_COPY_NONATOMIC ) ;   
}

-(JFFDidCloseActionBlock)didCloseAction
{
    return ( JFFDidCloseActionBlock )objc_getAssociatedObject( self.actController, &didCloseActionKey_ );
}

-(UIViewController*)actController
{
    UIViewController* controller_ = ( self.navigationController.topViewController == self )
        ? self.navigationController
        : self;
    NSAssert( controller_, @"act Controller should be set" );
    return controller_;
}

-(void)closeControllerWithReason:( BOOL )ok_
{
    JFFWillCloseActionBlock willCloseBlock_ = self.actController.willCloseAction;

    JFFDidCloseActionBlock didCloseBlock_ = self.actController.didCloseAction;
    self.actController.didCloseAction = nil;

    JFFCloseSelfBlock closeAction_ = self.actController.closeAction;
    self.actController.closeAction = nil;

    if ( closeAction_ )
    {
        closeAction_( willCloseBlock_ ? willCloseBlock_() : YES );
        self.actController.willCloseAction = nil;
    }

    if ( didCloseBlock_ )
    {
        didCloseBlock_( ok_ );
    }
}

@end

@interface JFFPresentViewControllerHooks : NSObject
@end

@implementation JFFPresentViewControllerHooks

-(void)presentModalViewControllerPrototype:( UIViewController* )modal_view_controller_
                                  animated:( BOOL )animated_
{
    __unsafe_unretained UIViewController* controller_to_close_ = modal_view_controller_;
    controller_to_close_.closeAction = ^void( BOOL animated_ )
    {
        [ controller_to_close_ dismissModalViewControllerAnimated: animated_ ];
    };

    objc_msgSend( self
                 , @selector( presentModalViewControllerHook:animated: )
                 , modal_view_controller_
                 , animated_ );
}

-(void)pushViewControllerPrototype:( UIViewController* )viewController_ animated:( BOOL )animated_
{
    if ( viewController_.navigationController.topViewController )
    {
        __unsafe_unretained UIViewController* controllerToClose_ = viewController_;
        controllerToClose_.closeAction = ^void( BOOL animated_ )
        {
            [ controllerToClose_.navigationController popViewControllerAnimated: animated_ ];
        };
    }

    objc_msgSend( self, @selector( pushViewControllerHook:animated: ), viewController_, animated_ );
}

+(void)load
{
    [ self hookInstanceMethodForClass: [ UINavigationController class ]
                         withSelector: @selector( pushViewController:animated: )
              prototypeMethodSelector: @selector( pushViewControllerPrototype:animated: )
                   hookMethodSelector: @selector( pushViewControllerHook:animated: ) ];

    //JTODO remove deprecated
    [ self hookInstanceMethodForClass: [ UIViewController class ]
                         withSelector: @selector( presentModalViewController:animated: )
              prototypeMethodSelector: @selector( presentModalViewControllerPrototype:animated: )
                   hookMethodSelector: @selector( presentModalViewControllerHook:animated: ) ];
}

@end
