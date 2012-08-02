#import "JFFPageSlider.h"

#import "JFFPageSliderDelegate.h"
#import "UIView+AddSubviewAndScale.h"

#include <math.h>

@interface JFFPageSlider () < UIScrollViewDelegate >

@property ( nonatomic ) UIScrollView* scrollView;
@property ( nonatomic ) NSInteger activeIndex;
@property ( nonatomic ) NSInteger firstIndex;
@property ( nonatomic ) NSMutableDictionary* viewByIndex;

@end

@implementation JFFPageSlider
{
    NSInteger _previousIndex;
    NSInteger _cachedNumberOfElements;
    NSRange   _previousVisiableIndexesRange;
}

-(void)dealloc
{
    self.scrollView.delegate = nil;

    [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];
}

-(id)initWithFrame:( CGRect )frame_
          delegate:( id< JFFPageSliderDelegate > )delegate_
{
    self = [ super initWithFrame: frame_ ];

    if ( self )
    {
        self.delegate = delegate_;
        [ self initialize ];
    }

    return self;
}

-(void)initialize
{
    self->_viewByIndex = [ NSMutableDictionary new ];

    self->_scrollView = [ [ UIScrollView alloc ] initWithFrame: self.bounds ];
    self->_scrollView.backgroundColor = [ UIColor clearColor ];
    self->_scrollView.delegate      = self;
    self->_scrollView.clipsToBounds = YES;
    self->_scrollView.pagingEnabled = YES;
    self->_scrollView.bounces       = NO;
    self->_scrollView.scrollEnabled = NO;
    [ self addSubviewAndScale: self->_scrollView ];

    NSRange range_ = { 0, 1 };
    self->_previousVisiableIndexesRange = range_;

    if ( self.delegate )
        [ self reloadData ];

    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector( didReceiveMemoryWarning: )
                                                    name: UIApplicationDidReceiveMemoryWarningNotification
                                                  object: nil ];
}

-(void)awakeFromNib
{
    [ self initialize ];
}

-(void)didReceiveMemoryWarning:( NSNotification* )notification_
{
    for ( NSInteger index_ = self->_firstIndex; index_ <= self.lastIndex; ++index_ )
    {
        if ( index_ != self.activeIndex )
        {
            if ( [ self.delegate respondsToSelector: @selector( pageSlider:handleMemoryWarningForElementAtIndex: ) ] )
                [ self.delegate pageSlider: self handleMemoryWarningForElementAtIndex: index_ ];
        }
    }
}

-(CGRect)elementFrameForIndex:( NSInteger )index_
{
    CGFloat x_ = self.bounds.size.width * ( index_ - self->_firstIndex );
    CGRect frame_ = { { x_, 0.f }, { self.bounds.size.width, self.bounds.size.height } };
    return frame_;
}

-(void)removeAllElements
{
    [ self->_viewByIndex enumerateKeysAndObjectsUsingBlock: ^( id key, UIView* view_, BOOL* stop )
    {
        [ view_ removeFromSuperview ];
    } ];
    [ self->_viewByIndex removeAllObjects ];
}

-(void)updateScrollViewContentSize
{
    //calls layoutSubviews
    self->_scrollView.contentSize = CGSizeMake( self.bounds.size.width * _cachedNumberOfElements,
                                        self.bounds.size.height );
}

-(UIView*)viewAtIndex:( NSInteger )index_
{
    return self->_viewByIndex[ @( index_ ) ];
}

-(void)cacheAndPositionView:( UIView* )view_
                    toIndex:( NSInteger )index_
{
    self->_viewByIndex[ @( index_ ) ] = view_;
    view_.frame = [ self elementFrameForIndex: index_ ];
}

-(void)addViewForIndex:( NSInteger )index_
{
    UIView* view_ = [ self.delegate stripeView: self
                                elementAtIndex: index_ ];

    [ self->_scrollView addSubview: view_ ];

    [ self cacheAndPositionView: view_
                        toIndex: index_ ];
}

-(void)reloadData
{
    [ self removeAllElements ];

    self->_cachedNumberOfElements = [ self->_delegate numberOfElementsInStripeView: self ];
    if ( 0 == _cachedNumberOfElements )
    {
        self->_scrollView.contentSize = CGSizeZero;
        return;
    }

    self.activeIndex = fmin( self->_activeIndex, self.lastIndex );

    [ self addViewForIndex: self->_activeIndex ];

    [ self updateScrollViewContentSize ];
}

-(CGPoint)offsetForIndex:( NSInteger )index_
{
    CGPoint result_ = { ( index_ - self->_firstIndex ) * self->_scrollView.bounds.size.width
        , self->_scrollView.contentOffset.y };
    return result_;
}

-(void)layoutSubviews
{
    [ super layoutSubviews ];

    [ self->_viewByIndex enumerateKeysAndObjectsUsingBlock: ^( NSNumber* index_, UIView* view_, BOOL* stop_ )
    {
        view_.frame = [ self elementFrameForIndex: [ index_ integerValue ] ];
    } ];

    [ self updateScrollViewContentSize ];
    CGPoint offset_ = [ self offsetForIndex: self->_activeIndex ];
    [ self->_scrollView setContentOffset: offset_ animated: NO ];
}

-(UIView*)elementAtIndex:( NSInteger )index_
{
    return self->_viewByIndex[ @( index_ ) ];
}

-(NSArray*)visibleElements
{
    [ self doesNotRecognizeSelector: _cmd ];
    return nil;
}

-(void)slideForward
{
    [ self doesNotRecognizeSelector: _cmd ];
}

-(void)slideBackward
{
    [ self doesNotRecognizeSelector: _cmd ];
}

-(void)slideToIndex:( NSInteger )index_ animated:( BOOL )animated_
{
    _previousIndex = self.activeIndex;
    self.activeIndex = index_;
    CGPoint offset_ = [ self offsetForIndex: index_ ];
    [ self->_scrollView setContentOffset: offset_ animated: animated_ ];
}

-(void)removeViewAtIndex:( NSInteger )index_
{
    NSAssert( index_ != self->_activeIndex, @"Can not remove View at active index" );

    if ( index_ < self->_activeIndex )
    {
        self.firstIndex += 1;
    }

    NSNumber* numberIndex_ = @( index_ );
    UIView* view_ = self->_viewByIndex[ numberIndex_ ];
    [ view_ removeFromSuperview ];
    [ self->_viewByIndex removeObjectForKey: numberIndex_ ];
}

-(void)removeViewsInRange:( JSignedRange )range_
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
    CGPoint offset_ = [ self offsetForIndex: self->_activeIndex ];
    [ self->_scrollView setContentOffset: offset_ animated: NO ];
}

-(void)slideToIndex:( NSInteger )index_
{
    [ self slideToIndex: index_ animated: NO ];
}

-(NSRange)visiableIndexesRange
{
    NSInteger first_index_ = floorf( self->_scrollView.contentOffset.x / self->_scrollView.bounds.size.width ) + self->_firstIndex;
    NSInteger last_index_ = ceilf( self->_scrollView.contentOffset.x / self->_scrollView.bounds.size.width ) + self->_firstIndex;
    last_index_ = fmin( last_index_, self.lastIndex );

    NSRange range_ = { first_index_, last_index_ - first_index_ + 1 };
    self->_previousVisiableIndexesRange = range_;
    return self->_previousVisiableIndexesRange;
}

-(NSInteger)lastIndex
{
    return self->_firstIndex + _cachedNumberOfElements - 1;
}

-(void)shiftRightElementsFromIndex:( NSInteger )shift_from_index_
                           toIndex:( NSInteger )to_index_
{
    for ( NSInteger index_ = to_index_; index_ >= shift_from_index_; --index_ )
    {
        UIView* view_ = [ self elementAtIndex: index_ ];
        if ( !view_ )
            continue;

        [ self cacheAndPositionView: view_ toIndex: index_ ];
    }
}

-(void)inserElementAtIndex:( NSInteger )index_
{
    NSInteger prevLastIndex_ = self.lastIndex;

    NSInteger last_elements_count_ = _cachedNumberOfElements;
    _cachedNumberOfElements = [ self.delegate numberOfElementsInStripeView: self ];

    NSAssert( _cachedNumberOfElements - 1 == last_elements_count_, @"invalid elements count" );
    NSAssert( ( index_ >= self->_firstIndex - 1 ) && ( index_ <= self.lastIndex + 1 ), @"invalid index" );

    self.firstIndex = fmin( self->_firstIndex, index_ );
    if ( index_ <= prevLastIndex_ )
        [ self shiftRightElementsFromIndex: index_ toIndex: prevLastIndex_ ];

    [ self addViewForIndex: index_ ];

    [ self updateScrollViewContentSize ];

    [ self slideToIndex: self->_activeIndex ];
}

-(void)pushFrontElement
{
    [ self inserElementAtIndex: self.lastIndex + 1 ];
}

-(void)pushBackElement
{
    [ self inserElementAtIndex: self.firstIndex - 1 ];
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSRange previuosRange_ = _previousVisiableIndexesRange;
    NSRange index_range_ = [ self visiableIndexesRange ];

    if ( NSEqualRanges( previuosRange_, index_range_ ) )
        return;

    NSInteger to_index_ = index_range_.location + index_range_.length;
    for ( NSInteger index_ = index_range_.location; index_ < to_index_; ++index_ )
    {
        if ( [ self elementAtIndex: index_ ] )
            continue;

        [ self addViewForIndex: index_ ];
    }
}

-(void)syncContentOffsetWithActiveElement
{
//    self.previousIndex = self.activeIndex;
    self.activeIndex = floor( self->_scrollView.contentOffset.x / self->_scrollView.bounds.size.width ) + self->_firstIndex;

    [ self updateScrollViewContentSize ];
    CGPoint offset_ = [ self offsetForIndex: self->_activeIndex ];
    [ self->_scrollView setContentOffset: offset_ animated: NO ];

    [ self.delegate pageSlider: self
    didChangeActiveElementFrom: _previousIndex
                            to: self.activeIndex ];
}

-(void)scrollViewDidEndDecelerating:( UIScrollView* )scrollView_
{
    [ self syncContentOffsetWithActiveElement ];
}

-(void)scrollViewDidEndScrollingAnimation:( UIScrollView* )scrollView_
{
    [ self syncContentOffsetWithActiveElement ];
}

@end
