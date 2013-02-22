#import "JFFAlertViewsContainer.h"

#import "JFFAlertView.h"

@implementation JFFAlertViewsContainer
{
    NSMutableArray *_activeAlertViews;
}

+ (id)sharedAlertViewsContainer
{
    static id instance = nil;
    if (!instance)
    {
        instance = [self new];
    }
    return instance;
}

- (void)addAlertView:(JFFAlertView *)alertView
{
    if (!_activeAlertViews)
    {
        _activeAlertViews = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    [_activeAlertViews addObject:alertView];
}

- (void)removeAlertView:(JFFAlertView *)alertView
{
    if ( !_activeAlertViews )
        return;
    
    [_activeAlertViews removeObject:alertView];
    
    if (![_activeAlertViews count])
    {
        _activeAlertViews = nil;
    }
}

- (BOOL)containsAlertView:(JFFAlertView *)alertView
{
    return [_activeAlertViews containsObject:alertView];
}

- (JFFAlertView*)firstAlertView
{
    return [_activeAlertViews noThrowObjectAtIndex:0];
}

- (NSUInteger)count
{
    return [_activeAlertViews count];
}

- (void)each:(void(^)(JFFAlertView *alertView))block
{
    if (!block || !_activeAlertViews)
        return;
    
    NSArray *tmpArray = [_activeAlertViews copy];
    for (JFFAlertView *alertView in tmpArray) {
        block(alertView);
    }
}

- (id)firstMatch:(JFFPredicateBlock)predicate
{
    return [_activeAlertViews firstMatch:predicate];
}

- (void)removeAllAlertViews
{
    _activeAlertViews = nil;
}

@end
