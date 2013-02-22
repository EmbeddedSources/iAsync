#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFAlertButton : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic, copy) JFFSimpleBlock action;

+ (id)newAlertButton:(NSString *)title action:(JFFSimpleBlock)action;

@end
