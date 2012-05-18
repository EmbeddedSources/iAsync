#import "JFFAlertView.h"

#import "JFFAlertButton.h"
#import "NSObject+JFFAlertButton.h"

#import "JFFAlertViewsContainer.h"

@interface JFFAlertView () < UIAlertViewDelegate >

+(void)activeAlertsAddAlert:( JFFAlertView* )alertView_;
-(void)forceShow;

@end

@implementation JFFAlertView
{
    BOOL _exclusive;
    NSMutableArray* _alertButtons;
    UIAlertView*    _alertView   ;
}

@synthesize dismissBeforeEnterBackground = _dismissBeforeEnterBackground;
@synthesize didPresentHandler = _didPresentHandler;
@dynamic isOnScreen;

-(void)dealloc
{
    [ NSThread assertMainThread ];

    self->_alertView.delegate = nil;
    [ self stopMonitoringBackgroundEvents ];
}

+(void)activeAlertsAddAlert:( JFFAlertView* )alertView_
{
    JFFAlertViewsContainer* container_ = [ JFFAlertViewsContainer sharedAlertViewsContainer ];
    [ container_ addAlertView: alertView_ ];
}

+(BOOL)activeAlertsRemoveAlert:( JFFAlertView* )alertView_
{
    JFFAlertViewsContainer* container_ = [ JFFAlertViewsContainer sharedAlertViewsContainer ];

    BOOL result_ = [ container_ containsAlertView: alertView_ ];

    [ container_ removeAlertView: alertView_ ];

    return result_;
}

-(void)dismissWithClickedButtonIndex:( NSInteger )buttonIndex_ animated:( BOOL )animated_
{
    [ self->_alertView dismissWithClickedButtonIndex: buttonIndex_ animated: NO ];

    [ self alertView: self->_alertView didDismissWithButtonIndex: buttonIndex_ ];
}

-(void)forceDismiss
{
    [ self dismissWithClickedButtonIndex: [ self->_alertView cancelButtonIndex ] animated: NO ];
//    [ self dismissWithClickedButtonIndex: [ self->_alertView cancelButtonIndex ] animated: NO ];
}

+(void)dismissAllAlertViews
{
    JFFAlertViewsContainer* container_ = [ JFFAlertViewsContainer sharedAlertViewsContainer ];
    NSArray* temporaryActiveAlerts_ = [ container_ allAlertViews ];

    for ( JFFAlertView* alertView_ in temporaryActiveAlerts_ )
    {
        [ alertView_ forceDismiss ];
    }

    //may be can be removed, test this
    [ container_ removeAllAlertViews ];
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
    self = [ super init ];
    if ( nil == self )
    {
        return nil;
    }
    
    self->_alertView = [ [ UIAlertView alloc ] initWithTitle: title_
                                                     message: message_ 
                                                    delegate: self
                                           cancelButtonTitle: cancel_button_title_
                                           otherButtonTitles: nil, nil ];

    if ( nil == self->_alertView )
    {
        return nil;
    }
    
    [ self addButtonsToAlertView: other_button_titles_ ];
    [ self startMonitoringBackgroundEvents ];
    
    return self;
}

-(void)addButtonsToAlertView:( NSArray* )other_button_titles_
{
    for ( NSString* button_title_ in other_button_titles_ )
    {
        [ self->_alertView addButtonWithTitle: button_title_ ];
    }
}

-(NSInteger)addAlertButtonWithIndex:( id )alert_button_id_
{
    JFFAlertButton* alert_button_ = [ alert_button_id_ toAlertButton ];
    NSInteger index_ = [ self->_alertView addButtonWithTitle: alert_button_.title ];
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
    JFFAlertViewsContainer* container_ = [ JFFAlertViewsContainer sharedAlertViewsContainer ];

    if ( [ [ container_ allAlertViews ] count ] == 0 )
    {
        [ self forceShow ];
    }

    [ container_ addAlertView: self ];
}

-(void)exclusiveShow
{
    self->_exclusive = YES;

    JFFAlertViewsContainer* container_ = [ JFFAlertViewsContainer sharedAlertViewsContainer ];

    UIAlertView* exclusiveAlertView_ = [ [ container_ allAlertViews ] firstMatch: ^BOOL( JFFAlertView* object_ )
    {
        return object_->_exclusive;
    } ];

    if ( !exclusiveAlertView_ )
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
    [ self->_alertView show ];
}

#pragma mark UIAlertViewDelegate

-(void)alertView:( UIAlertView* )alertView_ clickedButtonAtIndex:( NSInteger )buttonIndex_
{
    JFFAlertButton* alertButton_ = [ _alertButtons objectAtIndex: buttonIndex_ ];
    if ( alertButton_ )
        alertButton_.action();
}

-(void)didPresentAlertView:( UIAlertView* )alertView_
{
    if ( _didPresentHandler )
        _didPresentHandler();
}

-(void)alertView:( UIAlertView* )alert_view_ didDismissWithButtonIndex:( NSInteger )buttonIndex_
{
    [ [ self class ] activeAlertsRemoveAlert: self ];

    JFFAlertViewsContainer* container_ = [ JFFAlertViewsContainer sharedAlertViewsContainer ];
    [ [ container_ firstAlertView ] forceShow ];
}

-(BOOL)isOnScreen
{
    return self->_alertView.visible;
}

#pragma mark -
#pragma mark Notifications
-(void)startMonitoringBackgroundEvents
{
    [ [ NSNotificationCenter defaultCenter] addObserver: self
                                               selector: @selector( applicationDidEnterBackground: )
                                                   name: UIApplicationDidEnterBackgroundNotification 
                                                 object: nil ];    
}

-(void)stopMonitoringBackgroundEvents
{
    // dodikk - no need to unsubscribe a single event
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];    
}


@end
