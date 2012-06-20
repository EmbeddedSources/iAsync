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

@synthesize scrollView
, activeIndex
, firstIndex
, delegate
, viewByIndex = _viewByIndex;

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

    scrollView = [ [ UIScrollView alloc ] initWithFrame: self.bounds ];
    scrollView.backgroundColor = [ UIColor clearColor ];
    scrollView.delegate      = self;
    scrollView.clipsToBounds = YES;
    scrollView.pagingEnabled = YES;
    scrollView.bounces       = NO;
    scrollView.scrollEnabled = NO;
    [ self addSubviewAndScale: scrollView ];

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
    for ( NSInteger index_ = firstIndex; index_ <= self.lastIndex; ++index_ )
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
    CGFloat x_ = self.bounds.size.width * ( index_ - firstIndex );
    CGRect frame_ = { { x_, 0.f }, self.bounds.size };
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
    scrollView.contentSize = CGSizeMake( self.bounds.size.width * _cachedNumberOfElements,
                                        self.bounds.size.height );
}

-(UIView*)viewAtIndex:( NSInteger )index_
{
    NSNumber* index_number_ = [ [ NSNumber alloc ] initWithInteger: index_ ];
    return [ self->_viewByIndex objectForKey: index_number_ ];
}

-(void)cacheAndPositionView:( UIView* )view_
                    toIndex:( NSInteger )index_
{
    NSNumber* index_number_ = [ [ NSNumber alloc ] initWithInteger: index_ ];
    [ self->_viewByIndex setObject: view_ forKey: index_number_ ];
    view_.frame = [ self elementFrameForIndex: index_ ];
}

-(void)addViewForIndex:( NSInteger )index_
{
    UIView* view_ = [ self.delegate stripeView: self
                                elementAtIndex: index_ ];

    [ scrollView addSubview: view_ ];

    [ self cacheAndPositionView: view_
                        toIndex: index_ ];
}

-(void)reloadData
{
    [ self removeAllElements ];

    _cachedNumberOfElements = [ delegate numberOfElementsInStripeView: self ];
    if ( 0 == _cachedNumberOfElements )
    {
        scrollView.contentSize = CGSizeZero;
        return;
    }

    self.activeIndex = fmin( activeIndex, self.lastIndex );

    [ self addViewForIndex: activeIndex ];

    [ self updateScrollViewContentSize ];
}

-(CGPoint)offsetForIndex:( NSInteger )index_
{
    CGPoint result_ = { ( index_ - firstIndex ) * scrollView.bounds.size.width
        , scrollView.contentOffset.y };
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
    CGPoint offset_ = [ self offsetForIndex: activeIndex ];
    [ scrollView setContentOffset: offset_ animated: NO ];
}

-(UIView*)elementAtIndex:( NSInteger )index_
{
    NSNumber* number_index_ = [ [ NSNumber alloc ] initWithInteger: index_ ];
    return [ self->_viewByIndex objectForKey: number_index_ ];
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
    [ scrollView setContentOffset: offset_ animated: animated_ ];
}

-(void)removeViewAtIndex:( NSInteger )index_
{
    NSAssert( index_ != activeIndex, @"Can not remove View at active index" );

    if ( index_ < activeIndex )
    {
        self.firstIndex += 1;
    }

    NSNumber* numberIndex_ = [ NSNumber numberWithInteger: index_ ];
    UIView* view_ = [ self->_viewByIndex objectForKey: numberIndex_ ];
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
    CGPoint offset_ = [ self offsetForIndex: activeIndex ];
    [ scrollView setContentOffset: offset_ animated: NO ];
}

-(void)slideToIndex:( NSInteger )index_
{
    [ self slideToIndex: index_ animated: NO ];
}

-(NSRange)visiableIndexesRange
{
    NSInteger first_index_ = floorf( scrollView.contentOffset.x / scrollView.bounds.size.width ) + firstIndex;
    NSInteger last_index_ = ceilf( scrollView.contentOffset.x / scrollView.bounds.size.width ) + firstIndex;
    last_index_ = fmin( last_index_, self.lastIndex );

    NSRange range_ = { first_index_, last_index_ - first_index_ + 1 };
    self->_previousVisiableIndexesRange = range_;
    return self->_previousVisiableIndexesRange;
}

-(NSInteger)lastIndex
{
    return firstIndex + _cachedNumberOfElements - 1;
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
    NSAssert( ( index_ >= firstIndex - 1 ) && ( index_ <= self.lastIndex + 1 ), @"invalid index" );

    self.firstIndex = fmin( firstIndex, index_ );
    if ( index_ <= prevLastIndex_ )
        [ self shiftRightElementsFromIndex: index_ toIndex: prevLastIndex_ ];

    [ self addViewForIndex: index_ ];

    [ self updateScrollViewContentSize ];

    [ self slideToIndex: activeIndex ];
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
    self.activeIndex = floor( scrollView.contentOffset.x / scrollView.bounds.size.width ) + firstIndex;

    [ self updateScrollViewContentSize ];
    CGPoint offset_ = [ self offsetForIndex: activeIndex ];
    [ scrollView setContentOffset: offset_ animated: NO ];

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
