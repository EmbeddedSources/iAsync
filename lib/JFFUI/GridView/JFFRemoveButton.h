#import <UIKit/UIKit.h>

@protocol JFFRemoveButtonDelegate;

//TODO reomve this class
@interface JFFRemoveButton : UIButton

@property (weak, nonatomic) id<JFFRemoveButtonDelegate> delegate;

@property (nonatomic) NSDictionary *userInfo;

+ (instancetype)removeButtonWithUserInfo:(NSDictionary *)userInfo;

@end
