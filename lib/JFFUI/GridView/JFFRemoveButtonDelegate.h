#import <Foundation/Foundation.h>

@class JFFRemoveButton;

@protocol JFFRemoveButtonDelegate< NSObject >

- (void)didTapRemoveButton:(JFFRemoveButton *)button
              withUserInfo:(NSDictionary *)userInfo;

@end
