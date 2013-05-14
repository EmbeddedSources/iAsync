#import "JFFGridView.h"

#import "JFFRemoveButton.h"

#import "JFFGridViewDelegate.h"
#import "JFFRemoveButtonDelegate.h"

#import "UIView+AddSubviewAndScale.h"

#import <JFFUI/UIView/UIView+AnimationWithBlocks.h>

#include <math.h>

static NSString* const ESElementIndex = @"ESElementIndex";
static NSInteger const MinColumnCount = 2;

@implementation UIView (ReuseIdentifier)

+ (NSString *)jffGridViewReuseIdentifierBase
{
    return NSStringFromClass([self class]);
}

- (NSString *)jffGridViewReuseIdentifier
{
    return [[self class] jffGridViewReuseIdentifierBase];
}

@end

@implementation JFFGridViewContext
@end

@interface JFFGridView () < UIScrollViewDelegate, JFFRemoveButtonDelegate >

@property (nonatomic) UIScrollView* scrollView;
@property (nonatomic) CGRect previousFrame;
@property (nonatomic) BOOL forceRelayout;
@property (nonatomic) NSUInteger currentlyUsedIndex;
@property (nonatomic) JFFGridOrientation prevOrientation;

@property (nonatomic) NSMutableDictionary* reusableElementsByIdentifier;
@property (nonatomic) NSMutableDictionary* elementContextByIndex;

@property (nonatomic, readonly) CGFloat rowHeight;
@property (nonatomic, readonly) CGFloat colWidth;
@property (nonatomic, readonly) NSUInteger colCount;

-(void)relayoutElementsAnimated:( BOOL )animated_;

@end

@implementation JFFGridView

- (void)dealloc
{
    _scrollView.delegate = nil;
}

-(void)initialize
{
    UIScrollView *scrollView = [ [ UIScrollView alloc ] initWithFrame: self.bounds ];
    
    self.scrollView = scrollView;
    self.scrollView.delegate = self;
    
    [self addSubviewAndScale: self.scrollView ];
}

-(id)initWithFrame:( CGRect )frame_
{
    self = [ super initWithFrame: frame_ ];
    
    [ self initialize ];
    
    return self;
}

-(id)init
{
    self = [ super init ];
    
    [ self initialize ];
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
}

- (NSMutableDictionary *)elementContextByIndex
{
    if (!_elementContextByIndex) {
        
        _elementContextByIndex = [NSMutableDictionary new];
    }
    
    return _elementContextByIndex;
}

- (void)setNeedsLayout
{
    self.forceRelayout = YES;
    [super setNeedsLayout];
}

#pragma mark internal methods

- (BOOL)isVerticalGrid
{
    return [self.delegate verticalGridView:self];
}

- (CGFloat)rowHeight
{
    if ( [ self isVerticalGrid ] )
    {
        return self.colWidth * [ self.delegate widthHeightRelationInGridView: self ];
    }
    return fmax( 1.f, self.frame.size.height - [ self.delegate verticalOffsetInGridView: self ] );
}

-(CGFloat)colWidth
{
    if ( [ self isVerticalGrid ] )
    {
        return ( self.frame.size.width - [ self.delegate horizontalOffsetInGridView: self ] ) / self.colCount;
    }
    return self.rowHeight / [ self.delegate widthHeightRelationInGridView: self ];
}

-(NSUInteger)colCount
{
    return [ self.delegate numberOfElementsInRowInGridView: self ];
}

-(NSUInteger)firstVisibleIndex
{
    NSInteger from_index_ = 0;
    if ( [ self isVerticalGrid ] )
    {
        from_index_ = floor( self.scrollView.contentOffset.y / self.rowHeight ) * self.colCount;
    }
    else
    {
        from_index_ = floor( self.scrollView.contentOffset.x / self.colWidth );
    }
    
    NSUInteger number_of_elements_ = [ self.delegate numberOfElementsInGridView: self ];
    
    self.currentlyUsedIndex = fmin( number_of_elements_, fmax( 0, from_index_ ) );
    
    return fmin( number_of_elements_, fmax( 0, from_index_ ) );
}

-(NSUInteger)lastVisibleIndex
{
    NSInteger to_index_ = 0;
    if ( [ self isVerticalGrid ] )
    {
        CGFloat verical_offset_ = [ self.delegate verticalOffsetInGridView: self ];
        CGFloat bottom_scroll_offset_ = self.scrollView.contentOffset.y - verical_offset_ + self.frame.size.height;
        to_index_ = ceil( ( bottom_scroll_offset_ ) / self.rowHeight ) * self.colCount;
    }
    else
    {
        CGFloat horizontal_offset_ = [ self.delegate horizontalOffsetInGridView: self ];
        CGFloat right_scroll_offset_ = self.scrollView.contentOffset.x - horizontal_offset_ + self.frame.size.width;
        to_index_ = ceil( ( right_scroll_offset_ ) / self.colWidth );
    }
    
    NSUInteger number_of_elements_ = [ self.delegate numberOfElementsInGridView: self ];
    return fmin( number_of_elements_, fmax( 0, to_index_ ) );
}

-(NSRange)visibleIndexesRange
{
    NSInteger from_index_ = [ self firstVisibleIndex ];
    NSInteger to_index_ = [ self lastVisibleIndex ];
    
    return NSMakeRange( from_index_, to_index_ - from_index_ );
}

-(CGRect)rectForElementWithIndex:( NSUInteger )index_
{
    NSUInteger col_ = [ self isVerticalGrid ] ? index_ % self.colCount : index_;
    NSUInteger row_ = [ self isVerticalGrid ] ? index_ / self.colCount : 0;
    
    CGFloat horizontal_offset_ = [ self.delegate horizontalOffsetInGridView: self ];
    CGFloat verical_offset_ = [ self.delegate verticalOffsetInGridView: self ];
    
    return CGRectMake(col_ * self.colWidth    + horizontal_offset_
                      , row_ * self.rowHeight + verical_offset_
                      , self.colWidth         - horizontal_offset_
                      , self.rowHeight        - verical_offset_ );
}

-(void)expandContentSize
{
    NSUInteger row_count_ = [ self isVerticalGrid ] ? ceil( [ self.delegate numberOfElementsInGridView: self ] / ( CGFloat )self.colCount ) : 1;
    NSUInteger col_count_ = [ self isVerticalGrid ] ? self.colCount : [ self.delegate numberOfElementsInGridView: self ];
    
    self.scrollView.contentSize = CGSizeMake( self.colWidth * col_count_ + [ self.delegate horizontalOffsetInGridView: self ]
                                             , self.rowHeight * row_count_ + [ self.delegate verticalOffsetInGridView: self ] );
}

-(NSMutableSet*)visibleIndexes
{
    NSRange range_ = [ self visibleIndexesRange ];
    NSMutableSet* result_ = [ NSMutableSet setWithCapacity: range_.length ];
    for ( NSUInteger index_ = range_.location; index_ < range_.location + range_.length; ++index_ )
    {
        [ result_ addObject: [ NSNumber numberWithUnsignedInt: index_ ] ];
    }
    return result_;
}

-(NSSet*)indexesToUpdate
{
    NSMutableSet* elements_indexes_ = [ NSMutableSet setWithArray: [ self.elementContextByIndex allKeys ] ];
    NSMutableSet* result_ = [ self visibleIndexes ];
    [ result_ minusSet: elements_indexes_ ];
    return result_;
}

-(NSMutableSet*)unvisibleElementsIndexes
{
    NSMutableSet* result_ = [ NSMutableSet setWithArray: [ self.elementContextByIndex allKeys ] ];
    NSMutableSet* visible_indexes_ = [ self visibleIndexes ];
    [ result_ minusSet: visible_indexes_ ];
    return result_;
}

- (UIView *)elementByIndex:( NSUInteger )index_
{
    JFFGridViewContext *context_ = [ self.elementContextByIndex objectForKey: [ NSNumber numberWithUnsignedInt: index_ ] ];
    return context_.view;
}

- (void)makeReusableElement:(UIView *)view
{
    NSMutableArray *reusableElements = self.reusableElementsByIdentifier[[view jffGridViewReuseIdentifier]];
    if ([reusableElements count] == 0) {
        
        reusableElements = [NSMutableArray arrayWithObject:view];
        self.reusableElementsByIdentifier[[view jffGridViewReuseIdentifier]] = reusableElements;
    }
    else
    {
        [reusableElements addObject:view];
    }
}

- (void)removeUnvisibleElements
{
    NSMutableSet* unvisible_elements_indexes_ = [ self unvisibleElementsIndexes ];
    
    for ( NSNumber* index_ in unvisible_elements_indexes_ )
    {
        UIView *view_ = [ self elementByIndex: [ index_ unsignedIntValue ] ];
        [ self makeReusableElement: view_ ];
        [ self.elementContextByIndex removeObjectForKey: index_ ];
        
        [ view_ removeFromSuperview ];
    }
}

-(void)updateElementAtIndex:( NSNumber* )index_
                   position:( NSUInteger )position_
{
    JFFGridViewContext *context = [JFFGridViewContext new];
    context.view = [self.delegate gridView:self
                            elementAtIndex:[index_ unsignedIntValue]];
    
    NSAssert( context.view, @"View cannot be nil " );
    if ( [ self.delegate gridView: self canRemoveElementAtIndex: [ index_ unsignedIntValue ] ] )
    {
        NSDictionary* remove_info_ = [ NSDictionary dictionaryWithObject: index_ forKey: ESElementIndex ];
        context.removeButton = [JFFRemoveButton removeButtonWithUserInfo:remove_info_];
        context.removeButton.delegate = self;
        
        [ context.view addSubview: context.removeButton ];
    }
    
    context.view.frame = [ self rectForElementWithIndex: position_ ];
    context.view.autoresizingMask = UIViewAutoresizingNone;
    
    [ self.scrollView addSubview: context.view ];
    [ self.scrollView sendSubviewToBack: context.view ];
    
    [ self.elementContextByIndex setObject: context forKey: index_ ];
}

-(void)updateElementAtIndex:( NSNumber* )index_
{
    [ self updateElementAtIndex: index_ position: [ index_ unsignedIntValue ] ];
}

#pragma mark reloading / relayout / scroll

-(void)removeElementAtIndex:( NSUInteger )index_
{
    NSNumber* index_key_ = [ NSNumber numberWithUnsignedInt: index_ ];
    JFFGridViewContext *context_ = [ self.elementContextByIndex objectForKey: index_key_ ];
    [ context_.view removeFromSuperview ];
    
    [ self.elementContextByIndex removeObjectForKey: index_key_ ];
}

-(void)reindexElementsFromIndex:( NSUInteger )index_
{
    JFFGridViewContext *context_ = [ self.elementContextByIndex objectForKey: [ NSNumber numberWithUnsignedInt: ++index_ ] ];
    while( context_ )
    {
        NSNumber* new_index_ = [ NSNumber numberWithUnsignedInt: index_ - 1 ];
        context_.removeButton.userInfo = [ NSDictionary dictionaryWithObject: new_index_ forKey: ESElementIndex ];
        
        [ self.elementContextByIndex setObject: context_ forKey: new_index_ ];
        [ self.elementContextByIndex removeObjectForKey: [ NSNumber numberWithUnsignedInt: index_ ] ];
        
        [ self.delegate gridView: self
                  didMoveElement: context_.view
                         toIndex: index_ - 1 ];
        
        context_ = [ self.elementContextByIndex objectForKey: [ NSNumber numberWithUnsignedInt: ++index_ ] ];
    }
}

-(void)prepareNewVisibleElementAtIndex:( NSUInteger )act_index_
{
    NSUInteger last_visible_index_ = [ self lastVisibleIndex ] - 1;
    JFFGridViewContext *context_ = [ self.elementContextByIndex objectForKey: [ NSNumber numberWithUnsignedInt: last_visible_index_ ] ];
    UIView* element_view_ = context_.view;
    if ( !element_view_
        && last_visible_index_ < [ self.delegate numberOfElementsInGridView: self ]
        && act_index_ <= last_visible_index_ )
    {
        [ self updateElementAtIndex: [ NSNumber numberWithUnsignedInt: last_visible_index_ ]
                           position: last_visible_index_ + 1 ];
    }
}

-(void)removeElementWithIndex:( NSUInteger )index_ animated:( BOOL )animated_
{
    [ self removeElementAtIndex: index_ ];
    
    [ self reindexElementsFromIndex: index_ ];
    
    [ self prepareNewVisibleElementAtIndex: index_ ];
    
    [ self relayoutElementsAnimated: animated_ ];
}

-(void)removeElementsWithRange:( NSRange )range_
{
    for ( NSUInteger index_ = range_.location; index_ < range_.location + range_.length; ++index_ )
    {
        [ self removeElementAtIndex: index_ ];
    }
    
    [ self relayoutElementsAnimated: NO ];
}

-(void)updateElements
{
    NSArray* indexes_to_update_ = [ [ self indexesToUpdate ] allObjects ];
    
    [ self removeUnvisibleElements ];
    
    for ( NSNumber* index_ in indexes_to_update_ )
    {
        [ self updateElementAtIndex: index_ ];
    }
}

-(void)reloadDataWithRange:( NSRange )range_
{
    [ self removeElementsWithRange: range_ ];
    
    [ self updateElements ];
    
    [ self expandContentSize ];
}

-(NSRange)activeIndexesRange
{
    NSArray* active_indexes_ = [_elementContextByIndex allKeys];
    if ( [ _elementContextByIndex count ] == 0 )
        return NSMakeRange( 0, 0 );
    
    active_indexes_ = [ active_indexes_ sortedArrayUsingComparator: ^NSComparisonResult( id obj1_, id obj2_ ) {
        return [ obj1_ compare: obj2_ ];
    } ];
    
    NSInteger from_index_ = [ [ active_indexes_ objectAtIndex: 0 ] integerValue ];
    NSInteger to_index_   = [ [ active_indexes_ lastObject ] integerValue ] + 1;
    
    return NSMakeRange( from_index_, to_index_ - from_index_ );
}

-(void)reloadData
{
    [ self reloadDataWithRange: [ self activeIndexesRange ] ];
}

-(void)scrollToIndex:( NSInteger )index_
{
    if ( self.colCount < MinColumnCount )
        return;
    
    if ( [ self isVerticalGrid ] )
    {
        self.scrollView.contentOffset = CGPointMake( self.scrollView.contentOffset.x, index_ * self.rowHeight / self.colCount ) ;
    }
    else
    {
        self.scrollView.contentOffset = CGPointMake( index_ * self.colWidth, self.scrollView.contentOffset.y );
        
    }
}

-(void)reloadScrollView
{
    if ( self.colCount < 2 ) /// Temp solution to avoid core during Teasers View Init
        return;
    
    if ([self isVerticalGrid] && (self.prevOrientation != JFFGridOrientationVertical))
    {
        self.scrollView.contentOffset = CGPointMake( self.scrollView.contentOffset.x, self.currentlyUsedIndex * self.rowHeight / self.colCount ) ;
        
        self.prevOrientation = JFFGridOrientationVertical;
    }
    else if ( ![ self isVerticalGrid ] && ( self.prevOrientation != JFFGridOrientationGorizontal ) )
    {
        self.scrollView.contentOffset = CGPointMake( self.currentlyUsedIndex * self.colWidth, self.scrollView.contentOffset.y );
        
        self.prevOrientation = JFFGridOrientationGorizontal;
    }
}

-(void)relayoutElementsAnimated:( BOOL )animated_
{
    void (^animations_)( void ) = ^
    {
        for ( NSNumber* index_ in [ self.elementContextByIndex allKeys ] )
        {
            UIView* view_ = [ self elementByIndex: [ index_ unsignedIntValue ] ];
            view_.frame = [ self rectForElementWithIndex: [ index_ unsignedIntValue ] ];
        }
        
        [ self updateElements ];
        [ self expandContentSize ];
    };
    
    if ( animated_ )
        [ UIView animateWithOptions: UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState
                         animations: animations_ ];
    else
        animations_();
}

-(void)relayoutElements
{
    [ self relayoutElementsAnimated: NO ];
}

-(void)layoutSubviews
{
    if ( self.forceRelayout || !CGRectEqualToRect( self.frame, self.previousFrame ) )
    {
        [ self reloadScrollView ];
        [ self relayoutElements ];
    }
    
    self.previousFrame = self.frame;
    self.forceRelayout = NO;
}

-(NSMutableDictionary*)reusableElementsByIdentifier
{
    if (!_reusableElementsByIdentifier) {
        
        _reusableElementsByIdentifier = [NSMutableDictionary new];
    }
    
    return _reusableElementsByIdentifier;
}

- (id)dequeueReusableElementWithIdentifier:(NSString *)identifier
{
    NSMutableArray *reusable_elements_ = self.reusableElementsByIdentifier[identifier];
    if ( [ reusable_elements_ count ] == 0 )
        return nil;
    
    UIView *reusableElement = [reusable_elements_ lastObject];
    [reusable_elements_ removeLastObject];
    return reusableElement;
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewDidScroll:( UIScrollView* )scroll_view_
{
    [ self updateElements ];
}

#pragma mark JFFRemoveButtonDelegate

- (void)didTapRemoveButton:(JFFRemoveButton *)button_
              withUserInfo:( NSDictionary* )user_info_
{
    NSUInteger index_ = [ [ user_info_ objectForKey: ESElementIndex ] unsignedIntValue ];
    [ self.delegate gridView: self removeElementAtIndex: index_ ];
}

@end
