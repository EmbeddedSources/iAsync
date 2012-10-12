#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFAlertView;

@interface JFFAlertViewsContainer : NSObject

+ (id)sharedAlertViewsContainer;

- (NSUInteger)count;

- (void)addAlertView:(JFFAlertView *)alertView;
- (void)removeAlertView:(JFFAlertView *)alertView;
- (BOOL)containsAlertView:(JFFAlertView *)alertView;

- (JFFAlertView *)firstAlertView;

- (void)removeAllAlertViews;

- (void)each:(void(^)(JFFAlertView *alertView))block;
- (id)firstMatch:(JFFPredicateBlock)predicate;

@end
