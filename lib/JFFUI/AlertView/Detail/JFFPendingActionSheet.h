#import <Foundation/Foundation.h>

@class JFFActionSheet;

@interface JFFPendingActionSheet : NSObject

@property (nonatomic) JFFActionSheet *actionSheet;
@property (nonatomic) UIView *view;

- (instancetype)initWithActionSheet:(JFFActionSheet *)actionSheet
                               view:(UIView *)view;

@end
