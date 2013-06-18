#import "JFFGridView.h"

#import "JFFRemoveButton.h"

#import "JFFGridViewDelegate.h"
#import "JFFRemoveButtonDelegate.h"

#import "UIView+AddSubviewAndScale.h"

#import <JFFUI/UIView/UIView+AnimationWithBlocks.h>

#include <math.h>

static NSString *const JFFElementIndex = @"JFFElementIndex";
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

- (void)relayoutElementsAnimated:(BOOL)animated;

@end

@implementation JFFGridView

- (void)dealloc
{
    _scrollView.delegate = nil;
}

- (void)initialize
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    
    self.scrollView = scrollView;
    self.scrollView.delegate = self;
    
    [self addSubviewAndScale:self.scrollView];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self initialize];
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    [self initialize];
    
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
    if ([self isVerticalGrid]) {
        
        return self.colWidth * [ self.delegate widthHeightRelationInGridView: self ];
    }
    return fmax(1.f, self.frame.size.height - [self.delegate verticalOffsetInGridView:self]);
}

- (CGFloat)colWidth
{
    if ([self isVerticalGrid]) {
        
        return (self.frame.size.width - [self.delegate horizontalOffsetInGridView:self]) / self.colCount;
    }
    return self.rowHeight / [ self.delegate widthHeightRelationInGridView: self ];
}

- (NSUInteger)colCount
{
    return [self.delegate numberOfElementsInRowInGridView:self];
}

- (NSUInteger)firstVisibleIndex
{
    NSInteger fromIndex = 0;
    if ([self isVerticalGrid]) {
        
        fromIndex = floor(self.scrollView.contentOffset.y / self.rowHeight) * self.colCount;
    } else {
        fromIndex = floor( self.scrollView.contentOffset.x / self.colWidth );
    }
    
    NSUInteger numberOfElements = [self.delegate numberOfElementsInGridView:self];
    
    self.currentlyUsedIndex = fmin(numberOfElements, fmax( 0, fromIndex ) );
    
    return fmin( numberOfElements, fmax( 0, fromIndex ) );
}

- (NSUInteger)lastVisibleIndex
{
    NSInteger toIndex = 0;
    if ([self isVerticalGrid]) {
        
        CGFloat vericalOffset = [self.delegate verticalOffsetInGridView:self];
        CGFloat bottomScrollOffset = self.scrollView.contentOffset.y - vericalOffset + self.frame.size.height;
        toIndex = ceil((bottomScrollOffset) / self.rowHeight) * self.colCount;
    } else {
        
        CGFloat horizontalOffset = [self.delegate horizontalOffsetInGridView:self];
        CGFloat rightScrollOffset = self.scrollView.contentOffset.x - horizontalOffset + self.frame.size.width;
        toIndex = ceil((rightScrollOffset) / self.colWidth);
    }
    
    NSUInteger numberOfElements = [self.delegate numberOfElementsInGridView:self];
    return fmin( numberOfElements, fmax(0, toIndex));
}

- (NSRange)visibleIndexesRange
{
    NSInteger fromIndex = [self firstVisibleIndex];
    NSInteger toIndex = [self lastVisibleIndex];
    
    return NSMakeRange(fromIndex, toIndex - fromIndex);
}

- (CGRect)rectForElementWithIndex:(NSUInteger)index
{
    NSUInteger col = [self isVerticalGrid] ? index % self.colCount : index;
    NSUInteger row = [self isVerticalGrid] ? index / self.colCount : 0;
    
    CGFloat horizontalOffset = [self.delegate horizontalOffsetInGridView:self];
    CGFloat vericalOffset    = [self.delegate verticalOffsetInGridView:self];
    
    return CGRectMake(col * self.colWidth  + horizontalOffset,
                      row * self.rowHeight + vericalOffset,
                      self.colWidth         - horizontalOffset,
                      self.rowHeight        - vericalOffset );
}

- (void)expandContentSize
{
    NSUInteger rowCount = [self isVerticalGrid] ? ceil([self.delegate numberOfElementsInGridView:self] / (CGFloat)self.colCount ) : 1;
    NSUInteger colCount = [self isVerticalGrid] ? self.colCount : [self.delegate numberOfElementsInGridView:self];
    
    self.scrollView.contentSize = CGSizeMake(self.colWidth * colCount + [self.delegate horizontalOffsetInGridView:self],
                                             self.rowHeight * rowCount + [self.delegate verticalOffsetInGridView:self]);
}

- (NSMutableSet *)visibleIndexes
{
    NSRange range = [self visibleIndexesRange];
    NSMutableSet *result = [NSMutableSet setWithCapacity:range.length];
    for (NSUInteger index = range.location; index < range.location + range.length; ++index) {
        
        [result addObject:@(index)];
    }
    return result;
}

- (NSSet *)indexesToUpdate
{
    NSMutableSet *elementsIndexes = [NSMutableSet setWithArray:[self.elementContextByIndex allKeys]];
    NSMutableSet *result = [self visibleIndexes];
    [result minusSet:elementsIndexes];
    return result;
}

- (NSMutableSet *)unvisibleElementsIndexes
{
    NSMutableSet *result = [NSMutableSet setWithArray:[self.elementContextByIndex allKeys]];
    NSMutableSet *visibleIndexes = [self visibleIndexes];
    [result minusSet:visibleIndexes];
    return result;
}

- (id)elementByIndex:(NSUInteger)index
{
    JFFGridViewContext *result = self.elementContextByIndex[@(index)];
    return result.view;
}

- (void)makeReusableElement:(UIView *)view
{
    NSMutableArray *reusableElements = self.reusableElementsByIdentifier[[view jffGridViewReuseIdentifier]];
    if ([reusableElements count] == 0) {
        
        reusableElements = [NSMutableArray arrayWithObject:view];
        self.reusableElementsByIdentifier[[view jffGridViewReuseIdentifier]] = reusableElements;
    } else {
        
        [reusableElements addObject:view];
    }
}

- (void)removeUnvisibleElements
{
    NSMutableSet *unvisibleElementsIndexes = [self unvisibleElementsIndexes];
    
    for (NSNumber *index in unvisibleElementsIndexes) {
        
        UIView *view = [self elementByIndex:[index unsignedIntValue]];
        [self makeReusableElement:view];
        [self.elementContextByIndex removeObjectForKey:index];
        
        [view removeFromSuperview];
    }
}

- (void)updateElementAtIndex:(NSNumber *)index
                    position:(NSUInteger)position
{
    JFFGridViewContext *context = [JFFGridViewContext new];
    context.view = [self.delegate gridView:self
                            elementAtIndex:[index unsignedIntValue]];
    
    NSAssert(context.view, @"View cannot be nil ");
    if ([self.delegate gridView: self canRemoveElementAtIndex:[index unsignedIntValue]]) {
        
        NSDictionary *removeInfo = @{ JFFElementIndex : index };
        context.removeButton = [JFFRemoveButton removeButtonWithUserInfo:removeInfo];
        context.removeButton.delegate = self;
        
        [context.view addSubview:context.removeButton];
    }
    
    context.view.frame = [self rectForElementWithIndex:position];
    context.view.autoresizingMask = UIViewAutoresizingNone;
    
    [self.scrollView addSubview:context.view];
    [self.scrollView sendSubviewToBack:context.view];
    
    self.elementContextByIndex[index] = context;
}

- (void)updateElementAtIndex:(NSNumber *)index
{
    [self updateElementAtIndex:index position:[index unsignedIntValue]];
}

#pragma mark reloading / relayout / scroll

- (void)removeElementAtIndex:(NSUInteger)index
{
    NSNumber *indexKey = @(index);
    JFFGridViewContext *context = self.elementContextByIndex[indexKey];
    [context.view removeFromSuperview];
    
    [self.elementContextByIndex removeObjectForKey:indexKey];
}

- (void)reindexElementsFromIndex:(NSUInteger)index_
{
    JFFGridViewContext *context = self.elementContextByIndex[@(++index_)];
    while (context) {
        
        NSNumber *newIndex = @(index_ - 1);
        context.removeButton.userInfo = @{ JFFElementIndex : newIndex };
        
        self.elementContextByIndex[newIndex] = context;
        [self.elementContextByIndex removeObjectForKey:@(index_)];
        
        [self.delegate gridView:self
                 didMoveElement:context.view
                        toIndex:index_ - 1];
        
        context = self.elementContextByIndex[@(++index_)];
    }
}

- (void)prepareNewVisibleElementAtIndex:( NSUInteger )actIndex
{
    NSUInteger lastVisibleIndex = [self lastVisibleIndex] - 1;
    JFFGridViewContext *context_ = self.elementContextByIndex[@(lastVisibleIndex)];
    UIView *elementView = context_.view;
    if ( !elementView
        && lastVisibleIndex < [ self.delegate numberOfElementsInGridView: self ]
        && actIndex <= lastVisibleIndex ) {
        
        [self updateElementAtIndex:@(lastVisibleIndex)
                          position:lastVisibleIndex + 1];
    }
}

- (void)removeElementWithIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self removeElementAtIndex:index];
    
    [self reindexElementsFromIndex:index];
    
    [self prepareNewVisibleElementAtIndex:index];
    
    [self relayoutElementsAnimated:animated];
}

- (void)removeElementsWithRange:(NSRange)range
{
    for (NSUInteger index = range.location; index < range.location + range.length; ++index) {
        
        [self removeElementAtIndex:index];
    }
    
    [self relayoutElementsAnimated:NO];
}

- (void)updateElements
{
    NSArray *indexesToUpdate = [[self indexesToUpdate] allObjects];
    
    [self removeUnvisibleElements];
    
    for (NSNumber *index in indexesToUpdate) {
        
        [self updateElementAtIndex:index];
    }
}

- (void)reloadDataWithRange:(NSRange)range
{
    [self removeElementsWithRange:range];
    
    [self updateElements];
    
    [self expandContentSize];
}

- (NSRange)activeIndexesRange
{
    NSArray *activeIndexes = [_elementContextByIndex allKeys];
    if ( [_elementContextByIndex count] == 0)
        return NSMakeRange(0, 0);
    
    activeIndexes = [activeIndexes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSInteger fromIndex = [activeIndexes[0] integerValue];
    NSInteger toIndex   = [[activeIndexes lastObject] integerValue] + 1;
    
    return NSMakeRange(fromIndex, toIndex - fromIndex);
}

- (void)reloadData
{
    [self reloadDataWithRange:[self activeIndexesRange]];
}

- (void)scrollToIndex:(NSInteger)index_
{
    if ( self.colCount < MinColumnCount )
        return;
    
    if ([self isVerticalGrid]) {
        
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, index_ * self.rowHeight / self.colCount) ;
    } else {
        
        self.scrollView.contentOffset = CGPointMake(index_ * self.colWidth, self.scrollView.contentOffset.y);
    }
}

- (void)reloadScrollView
{
    if (self.colCount < 2) /// Temp solution to avoid core during Teasers View Init
        return;
    
    if ([self isVerticalGrid] && (self.prevOrientation != JFFGridOrientationVertical)) {
        
        self.scrollView.contentOffset = CGPointMake( self.scrollView.contentOffset.x, self.currentlyUsedIndex * self.rowHeight / self.colCount ) ;
        
        self.prevOrientation = JFFGridOrientationVertical;
    } else if (![self isVerticalGrid] && (self.prevOrientation != JFFGridOrientationGorizontal)) {
        
        self.scrollView.contentOffset = CGPointMake( self.currentlyUsedIndex * self.colWidth, self.scrollView.contentOffset.y );
        self.prevOrientation = JFFGridOrientationGorizontal;
    }
}

- (void)relayoutElementsAnimated:( BOOL )animated
{
    void (^animations)( void ) = ^
    {
        for (NSNumber *index in [self.elementContextByIndex allKeys])
        {
            UIView *view = [self elementByIndex:[index unsignedIntValue]];
            view.frame = [self rectForElementWithIndex:[index unsignedIntValue]];
        }
        
        [self updateElements];
        [self expandContentSize];
    };
    
    if (animated)
        [UIView animateWithOptions:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState
                        animations:animations];
    else
        animations();
}

- (void)relayoutElements
{
    [self relayoutElementsAnimated:NO];
}

- (void)layoutSubviews
{
    if (self.forceRelayout || !CGRectEqualToRect(self.frame, self.previousFrame)) {
        [self reloadScrollView];
        [self relayoutElements];
    }
    
    self.previousFrame = self.frame;
    self.forceRelayout = NO;
}

- (NSMutableDictionary *)reusableElementsByIdentifier
{
    if (!_reusableElementsByIdentifier) {
        
        _reusableElementsByIdentifier = [NSMutableDictionary new];
    }
    
    return _reusableElementsByIdentifier;
}

- (id)dequeueReusableElementWithIdentifier:(NSString *)identifier
{
    NSMutableArray *reusableElements = self.reusableElementsByIdentifier[identifier];
    if ([reusableElements count] == 0)
        return nil;
    
    UIView *reusableElement = [reusableElements lastObject];
    [reusableElements removeLastObject];
    return reusableElement;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateElements];
}

#pragma mark JFFRemoveButtonDelegate

- (void)didTapRemoveButton:(JFFRemoveButton *)button
              withUserInfo:(NSDictionary *)userInfo
{
    NSUInteger index = [userInfo[JFFElementIndex] unsignedIntValue];
    [self.delegate gridView:self removeElementAtIndex:index];
}

@end
