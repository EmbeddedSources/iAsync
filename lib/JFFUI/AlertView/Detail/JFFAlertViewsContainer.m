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
    if (!self->_activeAlertViews)
    {
        self->_activeAlertViews = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    [self->_activeAlertViews addObject:alertView];
}

- (void)removeAlertView:(JFFAlertView *)alertView
{
    if ( !self->_activeAlertViews )
        return;
    
    [self->_activeAlertViews removeObject:alertView];
    
    if (![self->_activeAlertViews count])
    {
        self->_activeAlertViews = nil;
    }
}

- (BOOL)containsAlertView:(JFFAlertView *)alertView
{
    return [self->_activeAlertViews containsObject:alertView];
}

- (JFFAlertView*)firstAlertView
{
    return [self->_activeAlertViews noThrowObjectAtIndex:0];
}

- (NSUInteger)count
{
    return [self->_activeAlertViews count];
}

- (void)each:(void(^)(JFFAlertView *alertView))block
{
    if (!block || !self->_activeAlertViews)
        return;
    
    NSArray *tmpArray = [self->_activeAlertViews copy];
    for (JFFAlertView *alertView in tmpArray) {
        block(alertView);
    }
}

- (id)firstMatch:(JFFPredicateBlock)predicate
{
    return [self->_activeAlertViews firstMatch:predicate];
}

- (void)removeAllAlertViews
{
    self->_activeAlertViews = nil;
}

@end
