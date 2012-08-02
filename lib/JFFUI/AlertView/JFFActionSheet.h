#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <UIKit/UIKit.h>

@interface JFFActionSheet : NSObject

@property ( nonatomic ) BOOL dismissBeforeEnterBackground;
@property ( nonatomic ) NSInteger cancelButtonIndex;
@property ( nonatomic, readonly ) NSInteger numberOfButtons;

//cancelButtonTitle, otherButtonTitles - pass NSString(button title) or JFFAlertButton
+(id)actionSheetWithTitle:( NSString* )title_
        cancelButtonTitle:( id )cancel_button_title_
   destructiveButtonTitle:( id )destructive_button_title_
        otherButtonTitles:( id )other_button_titles_, ... NS_REQUIRES_NIL_TERMINATION;

-(void)showInView:( UIView* )view_;

-(void)dismissWithClickedButtonIndex:( NSInteger )buttonIndex_
                            animated:( BOOL )animated_;

//pass NSString(button title) or JFFAlertButton
-(NSInteger)addActionButton:( id )alertButton_;

-(void)addActionButtonWithTitle:( NSString* )title_ ation:( JFFSimpleBlock )action_;

+(void)dismissAllActionSheets;

@end
