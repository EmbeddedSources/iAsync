#import "JFFActionSheet.h"

#import "JFFAlertButton.h"
#import "NSObject+JFFAlertButton.h"

#import "JFFPendingActionSheet.h"
#import "JFFActionSheetsContainer.h"

@interface JFFActionSheet () < UIActionSheetDelegate >
@end

@implementation JFFActionSheet
{
    NSMutableArray* _alertButtons;
    UIActionSheet*  _actionSheet;
}

-(void)dealloc
{
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];
}

+(void)dismissAllActionSheets
{
    JFFActionSheetsContainer* container_ = [ JFFActionSheetsContainer sharedActionSheetsContainer ];

    for ( JFFActionSheet* actionSheet_ in [ container_ allActionSheets ] )
    {
        [ actionSheet_ dismissWithClickedButtonIndex: [ actionSheet_ cancelButtonIndex ]
                                            animated: NO ];
    }

    [ container_ removeAllActionSheets ];
}

-(id)initWithTitle:( NSString* )title_
 cancelButtonTitle:( NSString* )cancelButtonTitle_
destructiveButtonTitle:( NSString* )destructiveButtonTitle_
otherButtonTitlesArray:( NSArray* )otherButtonTitles_
{
    self = [ super init ];

    if ( self )
    {
        _actionSheet = [ [ UIActionSheet alloc ] initWithTitle: title_
                                                      delegate: self
                                             cancelButtonTitle: nil
                                        destructiveButtonTitle: destructiveButtonTitle_
                                             otherButtonTitles: nil ];

        for ( NSString* buttonTitle_ in otherButtonTitles_ )
        {
            [ _actionSheet addButtonWithTitle: buttonTitle_ ];
        }
        
        if (cancelButtonTitle_)
        {
            [_actionSheet addButtonWithTitle:cancelButtonTitle_];
            _actionSheet.cancelButtonIndex = _actionSheet.numberOfButtons - 1;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil ];
    }

    return self;
}

-(NSInteger)addActionButton:( id )alertButtonObject_
{
    JFFAlertButton* alertButton_ = [ alertButtonObject_ toAlertButton ];
    NSInteger index_ = [ _actionSheet addButtonWithTitle: alertButton_.title ];
    [ _alertButtons insertObject: alertButton_ atIndex: index_ ];
    return index_;
}

- (void)addActionButtonWithTitle:(NSString *)title ation:(JFFSimpleBlock)action
{
    [self addActionButton:[JFFAlertButton newAlertButton:title action:action]];
}

- (NSInteger)addButtonWithTitle:(NSString *)title
{
    return [self addActionButton:title];
}

+ (id)actionSheetWithTitle:(NSString *)title
         cancelButtonTitle:(id)cancelButtonTitle
    destructiveButtonTitle:(id)destructiveButtonTitle
         otherButtonTitles:(id)otherButtonTitles, ...
{
    NSMutableArray *otherActionButtons      = [NSMutableArray new];
    NSMutableArray *otherActionStringTitles = [NSMutableArray new];

    if (destructiveButtonTitle)
    {
        JFFAlertButton *destructiveButton_ = [destructiveButtonTitle toAlertButton];
        [ otherActionButtons insertObject: destructiveButton_ atIndex: 0 ];
    }

    va_list args;
    va_start( args, otherButtonTitles );
    for ( NSString* buttonTitle = otherButtonTitles; buttonTitle != nil; buttonTitle = va_arg( args, NSString* ) )
    {
        JFFAlertButton *alertButton = [buttonTitle toAlertButton];
        [otherActionButtons addObject:alertButton];
        [otherActionStringTitles addObject:alertButton.title];
    }
    va_end( args );
    
    JFFAlertButton *cancelButton = [cancelButtonTitle toAlertButton];
    
    JFFActionSheet* actionSheet = [[self alloc] initWithTitle:title
                                            cancelButtonTitle:cancelButton.title
                                       destructiveButtonTitle:destructiveButtonTitle
                                       otherButtonTitlesArray:otherActionStringTitles];

    if (cancelButton)
    {
        [otherActionButtons addObject:cancelButton];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    }

    actionSheet->_alertButtons = otherActionButtons;

    return actionSheet;
}

-(void)showInView:( UIView* )view_
{
    JFFActionSheetsContainer* container_ = [ JFFActionSheetsContainer sharedActionSheetsContainer ];

    if ( [ container_ count ] == 0 )
    {
        [ _actionSheet showInView: view_ ];
    }

    [ container_ addActionSheet: self withView: view_ ];
}

-(void)applicationDidEnterBackground:( id )sender_
{
    if ( self.dismissBeforeEnterBackground )
    {
        [ self dismissWithClickedButtonIndex: [ self cancelButtonIndex ] animated: NO ];
    }
}

#pragma mark UIActionSheetDelegate

-(void)actionSheet:( UIActionSheet* )actionSheet_ clickedButtonAtIndex:( NSInteger )button_index_
{
    JFFAlertButton* alertButton_ = _alertButtons[ button_index_ ];

    if ( alertButton_ )
        alertButton_.action();
}

-(void)actionSheet:( UIActionSheet* )actionSheet_ didDismissWithButtonIndex:( NSInteger )button_index_
{
    JFFActionSheetsContainer* container_ = [ JFFActionSheetsContainer sharedActionSheetsContainer ];
    [ container_ removeActionSheet: self ];

    JFFPendingActionSheet* actionSheetsStruct_ = [ container_ firstPendingActionSheet ];
    if ( actionSheetsStruct_ )
        [ actionSheetsStruct_.actionSheet->_actionSheet showInView: actionSheetsStruct_.view ];
}

#pragma mark -
#pragma mark forward ActionSeet methods

-(id)forwardingTargetForSelector:( SEL )selector_
{
    return _actionSheet;
}

-(void)dismissWithClickedButtonIndex:( NSInteger )buttonIndex_ animated:( BOOL )animated_
{
    JFFActionSheetsContainer* container_ = [ JFFActionSheetsContainer sharedActionSheetsContainer ];

    JFFPendingActionSheet* actionSheetsStruct_ = [ container_ firstPendingActionSheet ];
    if ( actionSheetsStruct_.actionSheet == self )
    {
        [ _actionSheet dismissWithClickedButtonIndex: buttonIndex_ animated: animated_ ];
        return;
    }

    [ container_ removeActionSheet: self ];
}

@end
