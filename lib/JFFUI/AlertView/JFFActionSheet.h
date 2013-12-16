#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class UIView;

@interface JFFActionSheet : NSObject

@property (nonatomic) BOOL dismissBeforeEnterBackground;
@property (nonatomic) NSInteger cancelButtonIndex;
@property (nonatomic, readonly) NSInteger numberOfButtons;

//cancelButtonTitle, otherButtonTitles - pass NSString(button title) or JFFAlertButton
+ (instancetype)actionSheetWithTitle:(NSString *)title
                   cancelButtonTitle:(id)cancelButtonTitle
              destructiveButtonTitle:(id)destructiveButtonTitle
                   otherButtonTitles:(id)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)showInView:(UIView *)view;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex
                             animated:(BOOL)animated;

//pass NSString(button title) or JFFAlertButton
- (NSInteger)addActionButton:(id)alertButton;

- (void)addActionButtonWithTitle:(NSString *)title ation:(JFFSimpleBlock)action;

+ (void)dismissAllActionSheets;

@end
