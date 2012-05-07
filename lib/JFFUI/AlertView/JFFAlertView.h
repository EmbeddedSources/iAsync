#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

@interface JFFAlertView : NSObject

@property ( nonatomic ) BOOL dismissBeforeEnterBackground;
@property ( nonatomic, copy ) JFFSimpleBlock didPresentHandler;
@property ( nonatomic, readonly ) BOOL isOnScreen;


//cancelButtonTitle, otherButtonTitles - pass NSString(button title) or JFFAlertButton
+(id)alertWithTitle:( NSString* )title_
            message:( NSString* )message_
  cancelButtonTitle:( id )cancel_button_title_
  otherButtonTitles:( id )other_button_titles_, ...;

//pass NSString(button title) or JFFAlertButton
-(void)addAlertButton:( id )alert_button_;

-(void)addAlertButtonWithTitle:( NSString* )title_
                        action:( JFFSimpleBlock )action_;


+(void)dismissAllAlertViews;

+(void)showAlertWithTitle:( NSString* )title_
              description:( NSString* )description_;

+(void)showErrorWithDescription:( NSString* )description_;
+(void)showExclusiveErrorWithDescription:( NSString* )description_;
+(void)showInformationWithDescription:( NSString* )description_;

//If call several times, only first alert will be showed
-(void)exclusiveShow;
-(void)show;
-(void)forceDismiss;


@end
