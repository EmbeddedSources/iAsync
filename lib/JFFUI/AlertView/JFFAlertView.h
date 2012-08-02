#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

@class JFFAlertButton;

@interface JFFAlertView : NSObject

@property ( nonatomic ) BOOL dismissBeforeEnterBackground;
@property ( nonatomic, copy ) JFFSimpleBlock didPresentHandler;
@property ( nonatomic, readonly ) BOOL isOnScreen;


//cancelButtonTitle, otherButtonTitles - pass NSString(button title) or JFFAlertButton
+(id)alertWithTitle:( NSString* )title_
            message:( NSString* )message_
  cancelButtonTitle:( id )cancelButtonTitle_
  otherButtonTitles:( id )otherButtonTitles_, ... NS_REQUIRES_NIL_TERMINATION;

//pass NSString(button title) or JFFAlertButton
-(void)addAlertButton:( id )alertButton_;

-(void)addAlertButtonWithTitle:( NSString* )title_
                        action:( JFFSimpleBlock )action_;

+(id)waitAlertWithTitle:( NSString* )title_
           cancelButton:( JFFAlertButton* )button_;

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
