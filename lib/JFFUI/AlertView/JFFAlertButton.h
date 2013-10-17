#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class UIImage;

@interface JFFAlertButton : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) UIImage  *backgroundImage;
@property (nonatomic, copy) JFFSimpleBlock action;

+ (instancetype)newAlertButton:(NSString *)title action:(JFFSimpleBlock)action;

@end
