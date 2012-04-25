#import "JFFAlertView.h"

#import "JFFAlertButton.h"
#import "NSObject+JFFAlertButton.h"

static NSMutableArray* active_alerts_ = nil;
static NSInteger first_alert_index_ = 1;

@interface JFFAlertView () < UIAlertViewDelegate >

+(void)activeAlertsAddAlert:( UIAlertView* )alertView_;
-(void)forceShow;

@end

@implementation JFFAlertView
{
    BOOL _exclusive;
    __strong NSMutableArray* _alertButtons;
}

@synthesize dismissBeforeEnterBackground = _dismissBeforeEnterBackground;
@synthesize didPresentHandler = _didPresentHandler;

-(void)dealloc
{
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];
}

+(void)activeAlertsAddAlert:( UIAlertView* )alertView_
{
    if ( !active_alerts_ )
    {
        active_alerts_ = [ [ NSMutableArray alloc ] initWithCapacity: 1 ];
    }

    [ active_alerts_ addObject: alertView_ ];
}

+(BOOL)activeAlertsRemoveAlert:( UIAlertView* )alertView_
{
    if ( !active_alerts_ )
        return NO;

    NSUInteger result_ = [ active_alerts_ indexOfObject: alertView_ ];
    if ( result_ != NSNotFound )
        [ active_alerts_ removeObjectAtIndex: result_ ];

    if ( ![ active_alerts_ count ] )
    {
        active_alerts_ = nil;
    }

    return result_ != NSNotFound;
}

-(void)dismissWithClickedButtonIndex:( NSInteger )buttonIndex_ animated:( BOOL )animated_
{
    [ super dismissWithClickedButtonIndex: buttonIndex_ animated: NO ];

    [ self alertView: self didDismissWithButtonIndex: buttonIndex_ ];
}

-(void)forceDismiss
{
    [ self dismissWithClickedButtonIndex: [ self cancelButtonIndex ] animated: NO ];
    [ self dismissWithClickedButtonIndex: [ self cancelButtonIndex ] animated: NO ];
}

+(void)dismissAllAlertViews
{
    if ( !active_alerts_)
        return;

    NSArray* temporary_active_alerts_ = [ [ NSArray alloc ] initWithArray: active_alerts_ ];

    for ( JFFAlertView* alert_view_ in temporary_active_alerts_ )
    {
        [ alert_view_ forceDismiss ];
    }

    active_alerts_ = nil;
}

+(void)showAlertWithTitle:( NSString* )title_
              description:( NSString* )description_
{
    JFFAlertView* alert_ = [ JFFAlertView alertWithTitle: title_
                                                 message: description_
                                       cancelButtonTitle: NSLocalizedString( @"OK", nil )
                                       otherButtonTitles: nil ];

    [ alert_ show ];
}

+(void)showExclusiveAlertWithTitle:( NSString* )title_
                       description:( NSString* )description_
{
    JFFAlertView* alert_ = [ JFFAlertView alertWithTitle: title_
                                                 message: description_
                                       cancelButtonTitle: NSLocalizedString( @"OK", nil )
                                       otherButtonTitles: nil ];

    [ alert_ exclusiveShow ];
}

+(void)showErrorWithDescription:( NSString* )description_
{
    [ self showAlertWithTitle: NSLocalizedString( @"ERROR", nil ) description: description_ ];
}

+(void)showInformationWithDescription:( NSString* )description_
{
    [ self showAlertWithTitle: NSLocalizedString( @"INFORMATION", nil ) description: description_ ];
}

+(void)showExclusiveErrorWithDescription:( NSString* )description_
{
    [ self showExclusiveAlertWithTitle: NSLocalizedString( @"ERROR", nil ) description: description_ ];
}

-(id)initWithTitle:( NSString* )title_
           message:( NSString* )message_
          delegate:( id /*<UIAlertViewDelegate>*/ )delegate_
 cancelButtonTitle:( NSString* )cancel_button_title_
 otherButtonTitles:( NSString* )other_button_titles, ...
{
    NSAssert( NO, @"dont use this constructor of JFFAlertView" );
    return nil;
}

-(id)initWithTitle:( NSString* )title_
           message:( NSString* )message_
 cancelButtonTitle:( NSString* )cancel_button_title_
otherButtonTitlesArray:( NSArray* )other_button_titles_
{
    self = [ super initWithTitle: title_
                         message: message_ 
                        delegate: self
               cancelButtonTitle: cancel_button_title_
               otherButtonTitles: nil, nil ];

    if ( self )
    {
        for ( NSString* button_title_ in other_button_titles_ )
        {
            [ super addButtonWithTitle: button_title_ ];
        }

        [ [ NSNotificationCenter defaultCenter] addObserver: self
                                                   selector: @selector( applicationDidEnterBackground: )
                                                       name: UIApplicationDidEnterBackgroundNotification 
                                                     object: nil ];
    }

    return self;
}

-(NSInteger)addAlertButtonWithIndex:( id )alert_button_id_
{
    JFFAlertButton* alert_button_ = [ alert_button_id_ toAlertButton ];
    NSInteger index_ = [ super addButtonWithTitle: alert_button_.title ];
    [ _alertButtons insertObject: alert_button_ atIndex: index_ ];
    return index_;
}

-(void)addAlertButton:( id )alert_button_
{
    [ self addAlertButtonWithIndex: alert_button_ ];
}

-(void)addAlertButtonWithTitle:( NSString* )title_ action:( JFFSimpleBlock )action_
{
    [ self addAlertButton: [ JFFAlertButton alertButton: title_ action: action_ ] ];
}

-(NSInteger)addButtonWithTitle:( NSString* )title_
{
    return [ self addAlertButtonWithIndex: title_ ];
}

+(id)alertWithTitle:( NSString* )title_
            message:( NSString* )message_
  cancelButtonTitle:( id )cancel_button_title_
  otherButtonTitles:( id )other_button_titles_, ...
{
    [ NSThread assertMainThread ];

    NSMutableArray* other_alert_buttons_ = [ NSMutableArray new ];
    NSMutableArray* other_alert_string_titles_ = [ NSMutableArray new ];

    va_list args;
    va_start( args, other_button_titles_ );
    for ( NSString* button_title_ = other_button_titles_;
         button_title_ != nil;
         button_title_ = va_arg( args, NSString* ) )
    {
        JFFAlertButton* alert_button_ = [ button_title_ toAlertButton ];
        [ other_alert_buttons_ addObject: alert_button_ ];
        [ other_alert_string_titles_ addObject: alert_button_.title ];
    }
    va_end( args );

    JFFAlertButton* cancel_button_ = [ cancel_button_title_ toAlertButton ];
    if ( cancel_button_ )
    {
        [ other_alert_buttons_ insertObject: cancel_button_ atIndex: 0 ];
    }

    JFFAlertView* alert_view_ = [ [ self alloc ] initWithTitle: title_
                                                       message: message_
                                             cancelButtonTitle: cancel_button_.title
                                        otherButtonTitlesArray: other_alert_string_titles_ ];

    alert_view_->_alertButtons = other_alert_buttons_;

    return alert_view_;
}

-(void)show
{
    [ [ self class ] activeAlertsAddAlert: self ];

    //JTODO move to container pending logic
    if ( [ active_alerts_ count ] == first_alert_index_ )
    {
        [ self forceShow ];
    }
}

-(void)exclusiveShow
{
    _exclusive = YES;

    //JTODO remove predicate
    NSPredicate* predicate_ = [ NSPredicate predicateWithFormat: @"SELF.exclusive = %d", YES ];
    if ( [ [ active_alerts_ filteredArrayUsingPredicate: predicate_ ] count ] == 0 )
    {
        [ self show ];
    }
}

-(void)applicationDidEnterBackground:( id )sender_
{
    if ( self.dismissBeforeEnterBackground )
    {
        [ self forceDismiss ];
    }
}

-(void)forceShow
{
    [ super show ];
}

#pragma mark UIAlertViewDelegate

-(void)alertView:( UIAlertView* )alertView_ clickedButtonAtIndex:( NSInteger )buttonIndex_
{
    JFFAlertButton* alert_button_ = [ _alertButtons objectAtIndex: buttonIndex_ ];
    if ( alert_button_ )
        alert_button_.action();
}

-(void)didPresentAlertView:( UIAlertView* )alertView_
{
    if ( _didPresentHandler )
        _didPresentHandler();
}

-(void)alertView:( UIAlertView* )alert_view_ didDismissWithButtonIndex:( NSInteger )buttonIndex_
{
    BOOL removed_ = [ [ self class ] activeAlertsRemoveAlert: self ];

    if ( [ active_alerts_ count ] <= 0 )
        return;

    if ( removed_ )
        [ [ active_alerts_ objectAtIndex: 0 ] forceShow ];
}

@end
