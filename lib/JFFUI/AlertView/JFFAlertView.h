#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFAlertButton;

@interface JFFAlertView : NSObject

@property (nonatomic) BOOL dismissBeforeEnterBackground;
@property (nonatomic, copy) JFFSimpleBlock didPresentHandler;
@property (nonatomic, copy) JFFSimpleBlock didDismissHandler;
@property (nonatomic, readonly) BOOL isOnScreen;


//cancelButtonTitle, otherButtonTitles - pass NSString(button title) or JFFAlertButton
+ (instancetype)alertWithTitle:(NSString *)title
                       message:(NSString *)message
             cancelButtonTitle:(id)cancelButtonTitle
             otherButtonTitles:(id)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

//pass NSString(button title) or JFFAlertButton
- (void)addAlertButton:(id)alertButton;

- (void)addAlertButtonWithTitle:(NSString *)title
                         action:(JFFSimpleBlock)action;

+ (id)waitAlertWithTitle:(NSString *)title
            cancelButton:(JFFAlertButton *)button;

+ (void)dismissAllAlertViews;

+ (void)showAlertWithTitle:(NSString *)title
               description:(NSString *)description;

+ (void)showAlertWithTitle:(NSString *)title
               description:(NSString *)description
                 exclusive:(BOOL)isExclusive;

+ (void)showExclusiveAlertWithTitle:(NSString *)title
                        description:(NSString *)description;

+ (void)showErrorWithDescription:(NSString *)description;
+ (void)showExclusiveErrorWithDescription:(NSString *)description;
+ (void)showInformationWithDescription:(NSString *)description;
+ (void)showExclusiveAlertWithDescription:(NSString *)description;

//If call several times, only first alert will be showed
- (void)exclusiveShow;
- (void)show;
- (void)forceDismiss;

@end
