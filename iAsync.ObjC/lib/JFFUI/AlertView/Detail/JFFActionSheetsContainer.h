#import <Foundation/Foundation.h>

@class
UIView,
JFFActionSheet,
JFFPendingActionSheet;

@interface JFFActionSheetsContainer : NSObject

+ (instancetype)sharedActionSheetsContainer;

- (NSUInteger)count;

- (void)addActionSheet:(JFFActionSheet *)actionSheet withView:(UIView *)view;
- (void)removeActionSheet:(JFFActionSheet *)actionSheet;
- (BOOL)containsActionSheet:(JFFActionSheet *)actionSheet;

- (JFFPendingActionSheet *)firstPendingActionSheet;

- (NSArray *)allActionSheets;
- (void)removeAllActionSheets;

@end
