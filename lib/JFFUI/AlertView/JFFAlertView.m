#import "JFFAlertView.h"

#import "JFFAlertButton.h"
#import "NSObject+JFFAlertButton.h"

#import "JFFAlertViewsContainer.h"

#import "JFFWaitAlertView.h"

@interface JFFAlertView () < UIAlertViewDelegate >

+ (void)activeAlertsAddAlert:(JFFAlertView *)alertView;
- (void)forceShow;

@end

@implementation JFFAlertView
{
    BOOL _exclusive;
    NSMutableArray * _alertButtons;
    UIAlertView    * _alertView   ;

    BOOL _ignoreDismiss;
}

@dynamic isOnScreen;

- (void)dealloc
{
    [NSThread assertMainThread];
    
    self->_alertView.delegate = nil;
    [self stopMonitoringBackgroundEvents];
}

- (UIAlertView *)alertView
{
    return self->_alertView;
}

+ (void)activeAlertsAddAlert:(JFFAlertView *)alertView
{
    JFFAlertViewsContainer *container = [JFFAlertViewsContainer sharedAlertViewsContainer];
    [container addAlertView:alertView];
}

+ (BOOL)activeAlertsRemoveAlert:(JFFAlertView *)alertView
{
    JFFAlertViewsContainer *container = [JFFAlertViewsContainer sharedAlertViewsContainer];
    
    BOOL result = [container containsAlertView:alertView];
    
    [container removeAlertView:alertView];
    
    return result;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    self->_alertView.delegate = nil;
    [self->_alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
    [self alertView:self->_alertView didDismissWithButtonIndex:buttonIndex];
}

- (void)forceDismiss
{
    if (!self->_ignoreDismiss)
    {
        NSUInteger index = [self->_alertView cancelButtonIndex];
        [self dismissWithClickedButtonIndex:index animated:NO];
    }
}

+ (void)dismissAllAlertViews
{
    JFFAlertViewsContainer *container = [JFFAlertViewsContainer sharedAlertViewsContainer];
    [container each:^void(JFFAlertView *alertView) {
        [alertView forceDismiss];
    }];
    
    //may be can be removed, test this
    [container removeAllAlertViews];
}

+ (void)showAlertWithTitle:(NSString *)title
               description:(NSString *)description
{
    JFFAlertView *alert = [JFFAlertView alertWithTitle:title
                                               message:description
                                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                     otherButtonTitles:nil ];
    
    [alert show];
}

+ (void)showExclusiveAlertWithTitle:(NSString *)title
                        description:(NSString *)description
{
    JFFAlertView *alert = [JFFAlertView alertWithTitle:title
                                               message:description
                                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                     otherButtonTitles:nil];
    
    [alert exclusiveShow];
}

+ (void)showErrorWithDescription:(NSString *)description
{
    [self showAlertWithTitle:NSLocalizedString(@"ERROR", nil)
                 description:description];
}

+ (void)showInformationWithDescription:(NSString *)description
{
    [self showAlertWithTitle:NSLocalizedString(@"INFORMATION", nil)
                 description:description];
}

+ (void)showExclusiveErrorWithDescription:(NSString *)description
{
    [self showExclusiveAlertWithTitle:NSLocalizedString(@"ERROR", nil)
                          description:description];
}

//may we should not use it ???? and remove
+ (void)showExclusiveAlertWithDescription:(NSString *)description
{
    [self showExclusiveAlertWithTitle:nil
                          description:description];
}

+ (id)waitAlertWithTitle:(NSString *)title
            cancelButton:(JFFAlertButton *)button
{
    button = button ?: [NSLocalizedString(@"CANCEL", nil) toAlertButton];
    
    title = [title ?: @"" stringByAppendingString:@"\n\n"];
    
    JFFAlertView *alertView = [JFFWaitAlertView alertWithTitle:title
                                                       message:nil
                                             cancelButtonTitle:button
                                             otherButtonTitles:nil];
    
    alertView.dismissBeforeEnterBackground = NO;
    
    return alertView;
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id /*<UIAlertViewDelegate>*/)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    NSAssert(NO, @"dont use this constructor of JFFAlertView");
    return nil;
}

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
otherButtonTitlesArray:(NSArray *)otherButtonTitles
{
    self = [super init];
    if (nil == self)
    {
        return nil;
    }
    
    self->_alertView = [[UIAlertView alloc] initWithTitle:title
                                                  message:message
                                                 delegate:self
                                        cancelButtonTitle:cancelButtonTitle
                                        otherButtonTitles:nil];

    if (nil == self->_alertView)
    {
        return nil;
    }
    
    [self addButtonsToAlertView:otherButtonTitles];
    [self startMonitoringBackgroundEvents];
    
    return self;
}

- (void)addButtonsToAlertView:(NSArray *)otherButtonTitles
{
    for (NSString *buttonTitle in otherButtonTitles)
    {
        [self->_alertView addButtonWithTitle:buttonTitle];
    }
}

- (NSInteger)addAlertButtonWithIndex:(id)alertButtonId
{
    JFFAlertButton *alertButton = [alertButtonId toAlertButton];
    NSInteger index = [self->_alertView addButtonWithTitle:alertButton.title];
    [self->_alertButtons insertObject:alertButton atIndex:index];
    return index;
}

- (void)addAlertButton:(id)alertButton
{
    [self addAlertButtonWithIndex:alertButton];
}

- (void)addAlertButtonWithTitle:(NSString *)title action:(JFFSimpleBlock)action
{
    [self addAlertButton:[JFFAlertButton alertButton:title action:action]];
}

- (NSInteger)addButtonWithTitle:(NSString *)title
{
    return [self addAlertButtonWithIndex:title];
}

+ (id)alertWithTitle:(NSString *)title
             message:(NSString *)message
   cancelButtonTitle:(id)cancelButtonTitle
   otherButtonTitles:(id)otherButtonTitles, ...
{
    [NSThread assertMainThread];
    
    NSMutableArray *otherAlertButtons      = [NSMutableArray new];
    NSMutableArray *otherAlertStringTitles = [NSMutableArray new];
    
    va_list args;
    va_start(args, otherButtonTitles);
    for (NSString *buttonTitle = otherButtonTitles;
         buttonTitle != nil;
         buttonTitle = va_arg(args, NSString*))
    {
        JFFAlertButton *alertButton = [buttonTitle toAlertButton];
        [otherAlertButtons addObject:alertButton];
        [otherAlertStringTitles addObject:alertButton.title];
    }
    va_end( args );
    
    JFFAlertButton *cancelButton = [cancelButtonTitle toAlertButton];
    if (cancelButton)
    {
        [otherAlertButtons insertObject:cancelButton atIndex:0];
    }
    
    JFFAlertView* alertView = [[self alloc] initWithTitle:title
                                                  message:message
                                        cancelButtonTitle:cancelButton.title
                                   otherButtonTitlesArray:otherAlertStringTitles];
    
    alertView->_alertButtons = otherAlertButtons;
    
    return alertView;
}

- (void)show
{
    JFFAlertViewsContainer *container = [JFFAlertViewsContainer sharedAlertViewsContainer];
    
    if ([container count] == 0)
    {
        [self forceShow];
    }
    
    [container addAlertView:self];
}

- (void)exclusiveShow
{
    self->_exclusive = YES;
    
    JFFAlertViewsContainer *container = [JFFAlertViewsContainer sharedAlertViewsContainer];
    
    UIAlertView *exclusiveAlertView = [container firstMatch: ^BOOL(JFFAlertView *object) {
        return object->_exclusive;
    }];
    
    if (!exclusiveAlertView ) {
        [self show];
    }
}

- (void)applicationDidEnterBackground:(id)sender
{
    if (self.dismissBeforeEnterBackground)
    {
        [self forceDismiss];
    }
}

- (void)forceShow
{
    [self->_alertView show];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    JFFAlertButton *alertButton = self->_alertButtons[buttonIndex];
    
    if (alertButton)
    {
        self->_ignoreDismiss = YES;
        alertButton.action();
        self->_ignoreDismiss = NO;
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    if (self->_didPresentHandler)
        self->_didPresentHandler();
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[self class] activeAlertsRemoveAlert:self];
    
    JFFAlertViewsContainer *container = [JFFAlertViewsContainer sharedAlertViewsContainer];
    [[container firstAlertView] forceShow];
}

- (BOOL)isOnScreen
{
    return self->_alertView.visible;
}

#pragma mark -
#pragma mark Notifications
- (void)startMonitoringBackgroundEvents
{
    SEL selector = @selector(applicationDidEnterBackground:);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:selector
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)stopMonitoringBackgroundEvents
{
    // dodikk - no need to unsubscribe a single event
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
