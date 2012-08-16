#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFAlertButton : NSObject

@property ( nonatomic ) NSString* title;
@property ( nonatomic, copy ) JFFSimpleBlock action;

+(id)alertButton:( NSString* )title_ action:( JFFSimpleBlock )action_;

@end
