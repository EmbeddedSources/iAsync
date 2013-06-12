#import <Foundation/Foundation.h>

@class JFFActionSheet;
@class JFFPendingActionSheet;

@interface JFFActionSheetsContainer : NSObject

+ (instancetype)sharedActionSheetsContainer;

- (NSUInteger)count;

- (void)addActionSheet:(JFFActionSheet *)actionSheet_ withView:(UIView *)view;
- (void)removeActionSheet:(JFFActionSheet *)actionSheet_;
- (BOOL)containsActionSheet:(JFFActionSheet *)actionSheet_;

- (JFFPendingActionSheet *)firstPendingActionSheet;

- (NSArray *)allActionSheets;
- (void)removeAllActionSheets;

@end
