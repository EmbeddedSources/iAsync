#import "JFFStripeView.h"

#import "JFFStripeViewDelegate.h"

#import "UIView+AnimationWithBlocks.h"

@interface JFFStripeView () <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) CGRect previousFrame;

@property (nonatomic, readonly) CGFloat elementWidth;

@property (nonatomic) NSUInteger activeElement;

@property (nonatomic) NSMutableDictionary *elementsByIndex;
@property (nonatomic) NSMutableArray *reusableElements;

- (void)removeElementWithIndex:(NSUInteger)index;

- (void)initialize;

@end

@implementation JFFStripeView
{
    CGFloat _rightInset;
    CGFloat _leftInset;
    NSUInteger _activeElement;
}

- (void)dealloc
{
    _scrollView.delegate = nil;
}

+ (Class)scrollViewClass
{
    return [UIScrollView class];
}

- (NSUInteger)pageCount
{
   NSUInteger totalCount = [_delegate numberOfElementsInStripeView:self];
    
   return ceil((CGFloat)totalCount / [_delegate elementsPerPageInStripeView:self]);
}

- (void)setActiveElement:(NSUInteger)activeElement
{
    NSUInteger previousActiveElement = _activeElement;
    _activeElement = activeElement;
    
    //TODO remove active element at all
    [_delegate stripeView:self
didChangeActiveElementFrom:previousActiveElement
                       to:_activeElement];
    
    [_delegate stripeView:self
      didChangeActivePage:_activeElement / [_delegate elementsPerPageInStripeView:self]
            numberOfPages:[self pageCount]];
}

- (void)layoutSubviews
{
    if (!CGRectEqualToRect(self.frame, self.previousFrame)) {
        
        [self relayoutElements];
    }
    
    self.previousFrame = self.frame;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
       
        _scrollView = [[[[self class] scrollViewClass] alloc] initWithFrame:CGRectZero];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.clipsToBounds = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = YES;
    }
    
    return _scrollView;
}

- (CGFloat)elementWidth
{
    NSUInteger elementsPerPage = [_delegate elementsPerPageInStripeView:self];
    
    CGFloat offset = [_delegate elementOffsetInStripeView:self];
    
    return self.scrollView.frame.size.width / elementsPerPage - offset;
}

- (instancetype)initWithFrame:(CGRect)frame
                     delegate:(id<JFFStripeViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _delegate = delegate;
        [self initialize];
    }
    
    return self;
}

- (instancetype)init:(CGRect)frame
{
    NSAssert(NO, @"Unsupported initializer. Use 'initWithFrame:delegate:' instead" );
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    NSAssert( NO, @"Unsupported initializer. Use 'initWithFrame:delegate:' instead" );
    return nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
}

- (void)initialize
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    UIView *backgroundView = [_delegate backgroundViewForStripeView:self];
    if (backgroundView) {
        
        backgroundView.frame = self.bounds;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:backgroundView];
    }
    
    CGFloat elementOffset = [_delegate elementOffsetInStripeView:self];
    
    _rightInset = [_delegate rightFractionInsetInStripeView:self] * self.bounds.size.width - elementOffset;
    _leftInset  = [_delegate leftFractionInsetInStripeView:self ] * self.bounds.size.width;
    
    self.scrollView.frame = UIEdgeInsetsInsetRect( self.bounds, UIEdgeInsetsMake( 0.f, -_leftInset, 0.f, -_rightInset ) );
    [self addSubview:self.scrollView];
    
    UIView *overlayView = [_delegate overlayViewForStripeView:self];
    overlayView.frame = self.bounds;
    [self addSubview:overlayView];
}

- (NSInteger)minInternalIndex
{
   return [_delegate isCyclicStripeView:self]?- 1:0;
}

- (NSInteger)maxInternalIndex
{
    NSInteger maxIndex = [_delegate numberOfElementsInStripeView:self];
    maxIndex = maxIndex == 0 ? 0 : maxIndex - 1;
    
    if ([_delegate isCyclicStripeView:self]) {
        
        return maxIndex + [_delegate elementsPerPageInStripeView:self];
    }
    
    return maxIndex;
}

- (NSUInteger)convertInternalIndex:(NSInteger)index
{
    if ([_delegate isCyclicStripeView:self]) {
        
        NSUInteger count = [_delegate numberOfElementsInStripeView:self];
        return ( NSUInteger )(index + count) % count;
    }
    
    return index;
}

- (CGRect)rectForElementWithIndex:(NSInteger)index
{
    CGFloat elementWidth = self.elementWidth;
    CGFloat elementOffset = [_delegate elementOffsetInStripeView: self ];
    
    CGFloat x = elementOffset * (index + 1) + index * elementWidth;
    CGFloat vericalOffset = [_delegate elementVericalOffsetInStripeView:self];
    return CGRectMake(x, vericalOffset,
                      ceil(elementWidth), self.scrollView.frame.size.height - 2 * vericalOffset);
}

- (NSInteger)firstVisibleIndex
{
    CGFloat x = self.scrollView.contentOffset.x + _leftInset;
    
    /*if ( self.superview.clipsToBounds && self.frame.origin.x < 0 )
     {
     x_ -= self.frame.origin.x;
     }*/
    
    NSInteger minIndex = [self minInternalIndex];
    NSInteger positionBasedIndex = floorf(x / ([_delegate elementOffsetInStripeView:self] + self.elementWidth));
    
    NSInteger result = fmax(minIndex, positionBasedIndex);
    return result;
}

- (NSInteger)lastVisibleIndexWithFirstVisibleIndex:(NSInteger)firstVisibleIndex
{
    CGFloat x = self.scrollView.contentOffset.x + self.scrollView.frame.size.width - _rightInset - [_delegate elementOffsetInStripeView:self];
    
    /*if ( self.superview.clipsToBounds
     && CGRectGetMaxX( self.frame ) > CGRectGetMaxX( self.superview.bounds ) )
     {
     x_ -= ( CGRectGetMaxX( self.frame ) - CGRectGetMaxX( self.superview.bounds ) );
     }*/
    
    NSInteger maxIndex = [self maxInternalIndex];
    NSInteger positionBasedIndex = ceilf(x / ( [_delegate elementOffsetInStripeView:self] + self.elementWidth)) - 1;
    
    NSInteger result = std::min(maxIndex, positionBasedIndex);
    result = fmax(result, firstVisibleIndex);
    return result;
}

- (JSignedRange)visibleIndexesRange
{
    if ([_delegate numberOfElementsInStripeView:self] == 0)
        return JSignedRangeMake(0, 0);
    
    NSUInteger firstVisibleIndex = [self firstVisibleIndex];
    NSUInteger lastVisibleIndex  = [self lastVisibleIndexWithFirstVisibleIndex:firstVisibleIndex];
    
    NSInteger castedRangeStart = static_cast<NSInteger>(firstVisibleIndex);
    NSInteger castedRangeCount = static_cast<NSInteger>(lastVisibleIndex - firstVisibleIndex + 1);
    
    return JSignedRangeMake( castedRangeStart, castedRangeCount );
}

- (NSMutableOrderedSet *)mutableVisibleIndexes
{
    JSignedRange signedRange = [self visibleIndexesRange];
    
    JFFProducerBlock block = ^id(NSInteger index) {
        
        return @(signedRange.location + index);
    };
    
    NSMutableOrderedSet *result = [NSMutableOrderedSet setWithSize:signedRange.length
                                                          producer:block];
    
    return result;
}

- (NSOrderedSet *)visibleIndexes
{
    return [[self mutableVisibleIndexes] copy];
}

- (NSOrderedSet *)indexesToUpdate
{
    NSOrderedSet *controllersIndexes = [[NSOrderedSet alloc] initWithArray:[_elementsByIndex allKeys]?:@[]];
    NSMutableOrderedSet *result = [self mutableVisibleIndexes];
    [result minusOrderedSet:controllersIndexes];
    return result;
}

- (NSOrderedSet *)unvisibleControllersIndexes
{
    NSMutableOrderedSet *result = [[NSMutableOrderedSet alloc] initWithArray:[_elementsByIndex allKeys]?:@[]];
    
    NSOrderedSet *visibleIndexes = [self visibleIndexes];
    [result minusOrderedSet:visibleIndexes];
    return [result copy];
}

- (void)removeUnvisibleControllers
{
    NSOrderedSet *unvisibleControllersIndexes = [self unvisibleControllersIndexes];
    
    for (NSNumber *index in unvisibleControllersIndexes ) {
        
        UIView *element = _elementsByIndex[index];
        [self.reusableElements addObject:element];
        [_elementsByIndex removeObjectForKey:index];
        
        [element removeFromSuperview];
    }
}

- (id)dequeueReusableElement
{
    if ([_reusableElements count] == 0) {
        return nil;
    }
    
    UIView *reusableController = [_reusableElements lastObject];
    [_reusableElements removeLastObject];
    return reusableController;
}

- (void)addElement:(UIView *)element
        toPosition:(NSInteger)position
{
    CGAffineTransform scaleTransform = CGAffineTransformIdentity;
    element.transform = scaleTransform;
    element.frame = [self rectForElementWithIndex:position];
    element.autoresizingMask = UIViewAutoresizingNone;
    [self.scrollView addSubview:element];
    [_scrollView sendSubviewToBack:element];
}

- (void)addElementAtIndex:(NSNumber *)index
               toPosition:(NSInteger)position
{
    UIView *element = [_delegate stripeView:self
                             elementAtIndex:[self convertInternalIndex:[index intValue]]];
    
    if (!element)
        return;
    
    [self addElement:element toPosition:position];
    
    self.elementsByIndex[index] = element;
}

- (void)updateElements
{
    NSArray *indexesToUpdate = [[self indexesToUpdate] array];
    
    [self removeUnvisibleControllers];
    
    for (NSNumber *index in indexesToUpdate) {
        
        [self addElementAtIndex:index toPosition:[index intValue]];
    }
}

- (void)adjustContentSizeAndSetElementIndex:(NSUInteger)elementIndex
{
    NSUInteger pageIndex = elementIndex / [_delegate elementsPerPageInStripeView:self];
    
    UIScrollView *scrollView = self.scrollView;
    
    CGFloat stripeWidth = scrollView.frame.size.width;
    
    NSUInteger pageCount = [self pageCount];
    
    CGFloat contentWidth   = pageCount * stripeWidth;
    CGFloat contentOffsetX = pageIndex * stripeWidth;
    
    scrollView.contentSize   = CGSizeMake(contentWidth, self.scrollView.frame.size.height);
    scrollView.contentOffset = CGPointMake(contentOffsetX, 0.f);
    
    if ([_delegate isCyclicStripeView:self]) {
        
        scrollView.contentInset = UIEdgeInsetsMake(0.f, stripeWidth, 0.f, stripeWidth);
    } else {
        
        scrollView.contentInset = UIEdgeInsetsZero;
    }
    
    [_delegate stripeView:self
      didChangeActivePage:pageIndex
            numberOfPages:[self pageCount]];
}

- (void)removeElementWithIndex:(NSUInteger)index
{
    UIView *element = [self elementAtIndex:index];
    [element removeFromSuperview];
    [_elementsByIndex removeObjectForKey:@(index)];
}

- (void)removeElements
{
    NSArray *views = [_elementsByIndex allValues];
    _elementsByIndex = nil;
    
    for (UIView *view in views) {
        
        [view removeFromSuperview];
        [self.reusableElements addObject:view];
    }
}

- (void)reloadData
{
    [self removeElements];
    
    //TODO35 do not notify delegate when reload, because get and set at the same time
    self.activeElement = [_delegate activeElementForStripeView:self];
    
    [self adjustContentSizeAndSetElementIndex:self.activeElement];
    
    [self updateElements];
}

- (NSUInteger)activeElement
{
    return std::min(_activeElement, [_delegate numberOfElementsInStripeView:self] - 1);
}

-(UIView *)activeElementView
{
    NSUInteger activeElementIndex = self.activeElement;
    return [self elementAtIndex:activeElementIndex];
}

- (void)relayoutElementsAnimated:(BOOL)animated
                  updateElements:(BOOL)updateElements
{
    if (animated) {
        
        [UIView beginAnimations:@"StripeViewRelayout" context:nil];
        
        CGFloat animationDuration = [_delegate animationDurationOnStripeViewRelayout:self];
        if (animationDuration >= 0.f) {
            
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        } else {
            
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationBeginsFromCurrentState:YES];
        }
    }
    
    [_elementsByIndex enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, UIView *element, BOOL *stop) {
        
        element.frame = [self rectForElementWithIndex:[index intValue]];
    }];
    
    //self.activeElement = [_delegate activeElementForStripeView: self ];
    
    [self adjustContentSizeAndSetElementIndex:self.activeElement];
    
    if (updateElements) {
        
        [ self updateElements ];
    }
    
    if (animated) {
        
        [UIView commitAnimations];
    }
}

- (void)setFrame:(CGRect)newFrame
{
   self.scrollView.delegate = nil;
   [super setFrame: newFrame];
   self.scrollView.delegate = self;
}

- (void)relayoutElements
{
    [_delegate willRelayoutStripeView:self];
    
    BOOL animationEnabled = [_delegate animationEnabledOnStripeViewRelayout:self];
    
    [self relayoutElementsAnimated:animationEnabled
                    updateElements:YES];
    
    [_delegate didRelayoutStripeView:self];
}

- (NSMutableDictionary *)elementsByIndex
{
    if (!_elementsByIndex) {
        
        _elementsByIndex = [NSMutableDictionary new];
    }
    
    return _elementsByIndex;
}

- (NSMutableArray *)reusableElements
{
    if (!_reusableElements) {
        
        _reusableElements = [NSMutableArray new];
    }
    
    return _reusableElements;
}

- (UIView *)elementAtIndex:(NSUInteger)index
{
    return _elementsByIndex[@(index)];
}

#pragma mark Remove element methods

- (void)reindexElementsFromIndex:(NSUInteger)index
                    insertAction:(BOOL)yes
{
    BOOL shouldInsert = yes;
    NSUInteger currentIndex = index;

    if (shouldInsert) {
        NSInteger actualLastIndex = [self lastVisibleIndexWithFirstVisibleIndex:[self firstVisibleIndex]];
        NSUInteger delegateLastIndex = [_delegate numberOfElementsInStripeView:self] - 1;

        currentIndex = std::min( static_cast<NSUInteger>(actualLastIndex), static_cast<NSUInteger>(delegateLastIndex) );
    }
    
    UIView *element = [self elementAtIndex:yes?--currentIndex:++currentIndex];
    BOOL removeLastElement = yes;
    while (element && currentIndex >= index) {
        NSNumber *newIndex = @(currentIndex + (yes?1:-1));
        
        //local TODO move for insert action
        if (removeLastElement) {
            
            [self removeElementWithIndex:[newIndex intValue]];
            removeLastElement = NO;
        }
        self.elementsByIndex[newIndex] = element;
        
        [_elementsByIndex removeObjectForKey:@(currentIndex)];
        
        element = _elementsByIndex[@( yes ? --currentIndex : ++currentIndex)];
    }
}

- (void)prepareNewVisibleElementAtInsertAction:(BOOL)yes
                                   actionIndex:(NSUInteger)actIndex
{
    NSUInteger firstVisibleIndex = [self firstVisibleIndex];
    
    if (yes) {
        
        UIView* elementView = _elementsByIndex[@(firstVisibleIndex)];
        if ( !elementView
            && firstVisibleIndex >= 1
            && actIndex <= firstVisibleIndex
            && firstVisibleIndex < [_delegate numberOfElementsInStripeView: self ] )
        {
            [self addElementAtIndex:@(firstVisibleIndex - 1)
                         toPosition:firstVisibleIndex];
        }
        return;
    }
    
    NSUInteger lastVisibleIndex = [self lastVisibleIndexWithFirstVisibleIndex:firstVisibleIndex];
    UIView *elementView = _elementsByIndex[@(lastVisibleIndex)];
    if ( !elementView
        && lastVisibleIndex < [_delegate numberOfElementsInStripeView:self]
        && actIndex <= lastVisibleIndex )
    {
        [self addElementAtIndex:@(lastVisibleIndex)
                     toPosition:lastVisibleIndex + 1];
    }
}

- (void)removeElementWithIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self removeElementWithIndex:index];
    
    [self reindexElementsFromIndex:index insertAction:NO];
    
    [self prepareNewVisibleElementAtInsertAction:NO actionIndex:index];
    
    [self relayoutElementsAnimated:animated updateElements:YES];
}

#pragma mark Insert element methods

- (void)addElementWithIndex:(NSUInteger)index animated:(BOOL)animated
{
    JFFSimpleBlock animations = ^() {
        
        NSOrderedSet *visibleIndexes = [self visibleIndexes];
        
        NSNumber *numIndex_ = @(index);
        if ([visibleIndexes containsObject:numIndex_]) {
            
            [self addElementAtIndex:numIndex_ toPosition:index];
        }
    };
    
    if (animated) {
        
        [UIView animateWithOptions:(UIViewAnimationOptionCurveEaseIn)
                        animations:animations];
    } else {
        
        animations();
    }
}

- (void)insertElementAtIndex:(NSUInteger)index
                    animated:(BOOL)animated
{
    [self reindexElementsFromIndex:index insertAction:YES];
    
    [self addElementWithIndex:index animated:NO];
    
    [self prepareNewVisibleElementAtInsertAction:YES actionIndex:index];
    
    [self relayoutElementsAnimated:animated updateElements:YES];
}

#pragma mark Move element methods

- (void)prepareNewVisibleElementAtIndex:(NSUInteger)index
                               position:(NSUInteger)position
{
   UIView *controller = _elementsByIndex[@(position)];
   if (!controller) {
       
      UIView *element = [_delegate stripeView:self
                               elementAtIndex:[self convertInternalIndex:index]];
       
      [self addElement:element toPosition:position];
       
      self.elementsByIndex[@(position)] = element;
   }
}

- (void)exchangeElementAtIndex:(NSUInteger)firstIndex
            withElementAtIndex:(NSUInteger)secondIndex
{
    [self prepareNewVisibleElementAtIndex:firstIndex  position:secondIndex];
    [self prepareNewVisibleElementAtIndex:secondIndex position:firstIndex ];
    
    NSNumber *fromIndexNum = @(firstIndex );
    NSNumber *toIndexNum   = @(secondIndex);
    
    UIView *firstView  = _elementsByIndex[fromIndexNum];
    UIView *secondView = _elementsByIndex[toIndexNum  ];
    
    self.elementsByIndex[fromIndexNum] = secondView;
    self.elementsByIndex[toIndexNum  ] = firstView ;
    
    [self relayoutElementsAnimated:YES updateElements:NO];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateElements];
    
    if ([_delegate respondsToSelector:@selector(stripeViewDidScroll:)])
        [_delegate stripeViewDidScroll:self];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_delegate stripeViewWasDragged:self];
}

- (void)syncContentOffsetWithActiveElement
{
    if ([_delegate numberOfElementsInStripeView:self] == 0)
        return;
    
    NSInteger activeElement = self.scrollView.contentOffset.x / self.scrollView.frame.size.width * [_delegate elementsPerPageInStripeView:self];
    
    NSUInteger elementsCount = [_delegate numberOfElementsInStripeView:self];
    if ([_delegate isCyclicStripeView:self] && (activeElement < 0 || activeElement >= elementsCount))
    {
        activeElement = ( activeElement + elementsCount ) % elementsCount;
        
        [self adjustContentSizeAndSetElementIndex:activeElement];
    }
    
    self.activeElement = activeElement;
    
    //local TODO remove this
    [_delegate didStopScrollingStripeView:self];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self syncContentOffsetWithActiveElement];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self syncContentOffsetWithActiveElement];
}

//local TODO remove this method
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(didStartScrollingStripeView:)])
        [_delegate didStartScrollingStripeView:self];
    
    [_delegate stripeView:self willChangeActiveElementFrom:self.activeElement];
}

- (void)slideForward
{
    if ([_delegate numberOfElementsInStripeView:self] <= 1)
        return;
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    
    if ([_delegate isCyclicStripeView:self]
        || ( contentOffset.x + self.scrollView.frame.size.width <= self.scrollView.contentSize.width))
    {
        [_delegate didStartScrollingStripeView:self];
        
        contentOffset.x += self.scrollView.frame.size.width;
        [self.scrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)slideToIndex:(NSInteger)index animated:(BOOL)animated
{
    if ((index < 0) || (index >= [_delegate numberOfElementsInStripeView:self]))
        return;
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    
    if ([_delegate respondsToSelector:@selector(didStartScrollingStripeView:)])
        [_delegate didStartScrollingStripeView:self];
    
    contentOffset.x = self.scrollView.frame.size.width * ( index / [_delegate elementsPerPageInStripeView:self]);
    [self.scrollView setContentOffset:contentOffset animated:animated];
    
    self.activeElement = index;
    
    if (!animated) {
        
        [_delegate didStopScrollingStripeView:self];
    }
}

- (void)slideToIndex:(NSInteger)index
{
    [self slideToIndex:index animated:YES];
}

@end
