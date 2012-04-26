#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <UIKit/UIKit.h>

@interface JFFActionSheet : NSObject

@property ( nonatomic, assign ) BOOL dismissBeforeEnterBackground;
@property ( nonatomic, assign ) NSInteger cancelButtonIndex;
@property ( nonatomic, assign, readonly ) NSInteger numberOfButtons;

//cancelButtonTitle, otherButtonTitles - pass NSString(button title) or JFFAlertButton
+(id)actionSheetWithTitle:( NSString* )title_
        cancelButtonTitle:( id )cancel_button_title_
   destructiveButtonTitle:( id )destructive_button_title_
        otherButtonTitles:( id )other_button_titles_, ...;

-(void)showInView:( UIView* )view_;

-(void)dismissWithClickedButtonIndex:( NSInteger )buttonIndex_
                            animated:( BOOL )animated_;

//pass NSString(button title) or JFFAlertButton
-(NSInteger)addActionButton:( id )alertButton_;

-(void)addActionButtonWithTitle:( NSString* )title_ ation:( JFFSimpleBlock )action_;

+(void)dismissAllActionSheets;

@end
