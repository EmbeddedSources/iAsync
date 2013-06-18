#import "JFFPageSlider.h"

#import "JFFPageSliderDelegate.h"
#import "UIView+AddSubviewAndScale.h"

#include <math.h>

@interface JFFPageSlider () <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSInteger activeIndex;
@property (nonatomic) NSInteger firstIndex;
@property (nonatomic) NSMutableDictionary *viewByIndex;

@end

@implementation JFFPageSlider
{
    NSInteger _previousIndex;
    NSInteger _cachedNumberOfElements;
    NSRange   _previousVisiableIndexesRange;
}

- (void)dealloc
{
    self.scrollView.delegate = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(id< JFFPageSliderDelegate >)delegate
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.delegate = delegate;
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    _viewByIndex = [NSMutableDictionary new];

    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.backgroundColor = [ UIColor clearColor ];
    _scrollView.delegate      = self;
    _scrollView.clipsToBounds = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces       = YES;
    _scrollView.scrollEnabled = YES;
    [self addSubviewAndScale:_scrollView];
    
    NSRange range_ = { 0, 1 };
    _previousVisiableIndexesRange = range_;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

- (void)awakeFromNib
{
    [self initialize];
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
    for ( NSInteger index_ = _firstIndex; index_ <= self.lastIndex; ++index_ )
    {
        if ( index_ != self.activeIndex )
        {
            if ( [ self.delegate respondsToSelector: @selector( pageSlider:handleMemoryWarningForElementAtIndex: ) ] )
                [ self.delegate pageSlider: self handleMemoryWarningForElementAtIndex: index_ ];
        }
    }
}

- (CGRect)elementFrameForIndex:( NSInteger )index_
{
    CGFloat x_ = self.bounds.size.width * ( index_ - _firstIndex );
    CGRect frame_ = { { x_, 0.f }, { self.bounds.size.width, self.bounds.size.height } };
    return frame_;
}

- (void)removeAllElements
{
    [_viewByIndex enumerateKeysAndObjectsUsingBlock:^(id key, UIView *view, BOOL *stop) {
        [view removeFromSuperview];
    }];
    [_viewByIndex removeAllObjects];
}

- (void)updateScrollViewContentSize
{
    //calls layoutSubviews
    _scrollView.contentSize = CGSizeMake(self.bounds.size.width * _cachedNumberOfElements,
                                         self.bounds.size.height);
}

- (UIView *)viewAtIndex:(NSInteger)index
{
    return _viewByIndex[@(index)];
}

- (void)cacheAndPositionView:(UIView *)view
                     toIndex:(NSInteger)index
{
    _viewByIndex[@(index)] = view;
    view.frame = [self elementFrameForIndex:index];
}

- (void)addViewForIndex:(NSInteger)index
{
    UIView *view = [self.delegate stripeView:self
                              elementAtIndex:index];
    
    [_scrollView addSubview:view];
    
    [self cacheAndPositionView:view
                       toIndex:index];
}

- (void)reloadData
{
    [self removeAllElements];
    
    _cachedNumberOfElements = [_delegate numberOfElementsInStripeView:self];
    if (0 == _cachedNumberOfElements) {
        _scrollView.contentSize = CGSizeZero;
        return;
    }
    
    self.activeIndex = fmin(_activeIndex, self.lastIndex);
    
    [self addViewForIndex:_activeIndex];
    
    [self updateScrollViewContentSize];
}

- (CGPoint)offsetForIndex:( NSInteger )index_
{
    CGPoint result_ = { ( index_ - _firstIndex ) * _scrollView.bounds.size.width
        , _scrollView.contentOffset.y };
    return result_;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_viewByIndex enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, UIView *view, BOOL *stop) {
        view.frame = [self elementFrameForIndex:[index integerValue]];
    }];
    
    [self updateScrollViewContentSize];
    CGPoint offset = [self offsetForIndex:_activeIndex];
    [_scrollView setContentOffset:offset animated:NO];
}

- (UIView *)elementAtIndex:(NSInteger)index
{
    return _viewByIndex[@(index)];
}

- (NSArray *)visibleElements
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)slideForward
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)slideBackward
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)slideToIndex:( NSInteger )index_ animated:( BOOL )animated_
{
    _previousIndex = self.activeIndex;
    self.activeIndex = index_;
    CGPoint offset_ = [ self offsetForIndex: index_ ];
    [ _scrollView setContentOffset: offset_ animated: animated_ ];
}

- (void)removeViewAtIndex:( NSInteger )index_
{
    NSAssert( index_ != _activeIndex, @"Can not remove View at active index" );

    if ( index_ < _activeIndex )
    {
        self.firstIndex += 1;
    }

    NSNumber* numberIndex_ = @( index_ );
    UIView* view_ = _viewByIndex[ numberIndex_ ];
    [ view_ removeFromSuperview ];
    [ _viewByIndex removeObjectForKey: numberIndex_ ];
}

- (void)removeViewsInRange:( JSignedRange )range_
{
    for ( NSInteger index_ = range_.location;
         index_ < range_.location + range_.length;
         ++index_ )
    {
        [ self removeViewAtIndex: index_ ];
    }

    NSInteger last_elements_count_ = _cachedNumberOfElements;
    _cachedNumberOfElements = [ self.delegate numberOfElementsInStripeView: self ];
    NSAssert( _cachedNumberOfElements == last_elements_count_ - range_.length, @"invalid elements count" );

    [ self updateScrollViewContentSize ];
    CGPoint offset_ = [ self offsetForIndex: _activeIndex ];
    [ _scrollView setContentOffset: offset_ animated: NO ];
}

- (void)slideToIndex:( NSInteger )index_
{
    [ self slideToIndex: index_ animated: NO ];
}

- (NSRange)visiableIndexesRange
{
    if (_scrollView.bounds.size.width == 0) {
        NSLog(@"[!!!ERROR!!!] division by zero");
        return _previousVisiableIndexesRange;
    }
    
    NSInteger firstIndex = floorf( _scrollView.contentOffset.x / _scrollView.bounds.size.width ) + _firstIndex;
    NSInteger lastIndex  = ceilf( _scrollView.contentOffset.x / _scrollView.bounds.size.width ) + _firstIndex;
    lastIndex = fmin( lastIndex, self.lastIndex );
    
    firstIndex = firstIndex > 0 ?: 0;

    NSRange range_ = { firstIndex, lastIndex - firstIndex + 1 };
    _previousVisiableIndexesRange = range_;
    return _previousVisiableIndexesRange;
}

- (NSInteger)lastIndex
{
    return _firstIndex + _cachedNumberOfElements - 1;
}

- (void)shiftRightElementsFromIndex:(NSInteger)shiftFromIndex
                            toIndex:(NSInteger)toIndex
{
    for (NSInteger index = toIndex; index >= shiftFromIndex; --index) {
        
        UIView *view = [self elementAtIndex:index];
        if (!view)
            continue;
        
        [self cacheAndPositionView:view toIndex:index];
    }
}

- (void)inserElementAtIndex:( NSInteger )index_
{
    NSInteger prevLastIndex_ = self.lastIndex;

    NSInteger last_elements_count_ = _cachedNumberOfElements;
    _cachedNumberOfElements = [ self.delegate numberOfElementsInStripeView: self ];

    NSAssert( _cachedNumberOfElements - 1 == last_elements_count_, @"invalid elements count" );
    NSAssert( ( index_ >= _firstIndex - 1 ) && ( index_ <= self.lastIndex + 1 ), @"invalid index" );

    self.firstIndex = fmin( _firstIndex, index_ );
    if ( index_ <= prevLastIndex_ )
        [ self shiftRightElementsFromIndex: index_ toIndex: prevLastIndex_ ];

    [ self addViewForIndex: index_ ];

    [ self updateScrollViewContentSize ];

    [ self slideToIndex: _activeIndex ];
}

- (void)pushFrontElement
{
    [ self inserElementAtIndex: self.lastIndex + 1 ];
}

- (void)pushBackElement
{
    [ self inserElementAtIndex: self.firstIndex - 1 ];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSRange previuosRange = _previousVisiableIndexesRange;
    NSRange indexRange = [self visiableIndexesRange];
    
    if (NSEqualRanges(previuosRange, indexRange))
        return;
    
    NSInteger toIndex = indexRange.location + indexRange.length;
    for (NSInteger index = indexRange.location; index < toIndex; ++index) {
        
        if ([self elementAtIndex:index])
            continue;
        
        [self addViewForIndex:index];
    }
}

- (void)syncContentOffsetWithActiveElement
{
    if (_scrollView.bounds.size.width == 0)
    {
        NSLog(@"[!!!ERROR!!!] division by zero");
        return;
    }
    
    self.activeIndex = floor( _scrollView.contentOffset.x / _scrollView.bounds.size.width ) + _firstIndex;
    
    [ self updateScrollViewContentSize ];
    CGPoint offset_ = [ self offsetForIndex: _activeIndex ];
    [ _scrollView setContentOffset: offset_ animated: NO ];

    [ self.delegate pageSlider: self
    didChangeActiveElementFrom: _previousIndex
                            to: self.activeIndex ];
}

- (void)scrollViewDidEndDecelerating:( UIScrollView* )scrollView_
{
    [ self syncContentOffsetWithActiveElement ];
}

- (void)scrollViewDidEndScrollingAnimation:( UIScrollView* )scrollView_
{
    [ self syncContentOffsetWithActiveElement ];
}

@end
