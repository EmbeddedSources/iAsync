#import <UIKit/UIKit.h>

@protocol JFFRemoveButtonDelegate;

@interface JFFRemoveButton : UIButton

@property (weak, nonatomic ) id<JFFRemoveButtonDelegate> delegate;

@property (nonatomic) NSDictionary *userInfo;

+ (id)removeButtonWithUserInfo:(NSDictionary *)userInfo;

@end
