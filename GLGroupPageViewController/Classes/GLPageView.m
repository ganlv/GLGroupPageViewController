//
//  GLPageView.h
//  GLPageView
//
//  Created by Gerardo Blanco García on 01/10/13.
//  Copyright (c) 2013 Gerardo Blanco García. All rights reserved.
//

#import "GLPageView.h"

@interface GLPageView ()

// Number of pages.
@property (nonatomic) NSUInteger numberOfPages;

// The current page index.
@property (nonatomic, readwrite) NSUInteger currentPageIndex;

// Array of visible indices.
@property (nonatomic, strong) NSMutableArray *visibleIndices;

// Visible pages.
@property (nonatomic, strong) NSMutableArray *visiblePages;

// Reusable pages.
@property (nonatomic, strong) NSMutableArray *reusablePages;

//Reusable cards
@property (nonatomic, strong) NSMutableArray *reusableCards;

// A boolean value that determines whether automatic scroll is enabled.
@property (nonatomic) BOOL autoScroll;

// Automatic scrolling timer.
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation GLPageView

#pragma mark - Initialization

- (id)init
{
    return [self initWithFrame:[UIScreen mainScreen].applicationFrame];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

#pragma mark - Lazy instantiation

- (NSMutableArray *)visibleIndices
{
    if (!_visibleIndices) {
        _visibleIndices = [[NSMutableArray alloc] init];
    }
    
    return _visibleIndices;
}

- (NSMutableArray *)visiblePages
{
    if (!_visiblePages) {
        _visiblePages = [[NSMutableArray alloc] init];
    }
    
    return _visiblePages;
}

- (NSMutableArray *)reusablePages
{
    if (!_reusablePages) {
        _reusablePages = [[NSMutableArray alloc] init];
    }
    
    return _reusablePages;
}

- (NSMutableArray *)reusableCards
{
    if (!_reusableCards) {
        _reusableCards = [[NSMutableArray alloc] init];
    }
    
    return _reusableCards;
}

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.bounces = YES;
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.alwaysBounceHorizontal = YES;
    self.userInteractionEnabled = YES;
    self.exclusiveTouch = YES;

    [self setupDefautValues];
}

- (void)setupDefautValues
{
    self.autoScroll = NO;
    self.shouldScrollingWrapDataSource = NO;
    self.pageIndex = [self firstPageIndex];
    self.currentPageIndex = [self firstPageIndex];
}

#pragma mark - Convenient methods

- (BOOL)isEmpty
{
    return ([self numberOfPages] == 0);
}

- (BOOL)isNotEmpty
{
    return (self.isEmpty ? NO : YES);
}

- (BOOL)singlePage
{
    return ([self numberOfPages] == 1);
}

- (BOOL)isScrollNecessary
{
    return (self.isScrollNotNecessary ? NO : YES);
}

- (BOOL)isScrollNotNecessary
{
    return ([self isEmpty] || [self singlePage]);
}

- (BOOL)isLastPage {
    return (self.currentPageIndex==[self lastPageIndex]?YES:NO);
}

- (BOOL)isFirstPage {
    return (self.currentPageIndex==[self firstPageIndex]?YES:NO);
}
//second page
-(BOOL)isSecondPage{
    return (self.currentPageIndex == [self firstPageIndex] + 1);
}
//last second
-(BOOL)isLastSecondPage{
    return  (self.currentPageIndex == [self lastPageIndex] - 1);
}

#pragma mark - Pages

- (void)updateNumberOfPages
{
    if (self.pageViewDataSource &&
        [self.pageViewDataSource respondsToSelector:@selector(numberOfPagesInPageView:)]) {
        self.numberOfPages = [self.pageViewDataSource numberOfPagesInPageView:self];
    }
}

- (CGFloat)pageWidth
{
    return self.frame.size.width;
}

- (NSUInteger)firstPageIndex
{
    return 0;
}

- (NSUInteger)lastPageIndex
{
    return fmax([self firstPageIndex], [self numberOfPages] - 1);
}

- (NSUInteger)nextIndex:(NSUInteger)index
{
    return (index == [self lastPageIndex]) ? [self firstPageIndex] : (index + 1);
}

- (NSUInteger)previousIndex:(NSUInteger)index
{
    return (index == [self firstPageIndex]) ? [self lastPageIndex] : (index - 1);
}

- (void)updateCurrentPageIndex
{
    self.currentPageIndex = (self.pageIndex > [self lastPageIndex]) ? [self lastPageIndex] : fmaxf(self.pageIndex, 0.0f);
}

- (NSUInteger)nextPageIndex
{
    if (!self.shouldScrollingWrapDataSource && [self isLastPage]) return self.currentPageIndex;
    return [self nextIndex:[self currentPageIndex]];
}

- (NSUInteger)previousPageIndex
{
    if (!self.shouldScrollingWrapDataSource && [self isFirstPage]) return self.currentPageIndex;
    return [self previousIndex:[self currentPageIndex]];
}

- (void)next
{
    self.currentPageIndex = [self nextPageIndex];
}

- (void)previous
{
    self.currentPageIndex = [self previousPageIndex];
}

- (GLOnePageView *)pageAtIndex:(NSUInteger)index
{
    GLOnePageView *page = nil;
    
    NSUInteger visibleIndex = [self.visibleIndices indexOfObject:[NSNumber numberWithUnsignedInteger:index]];
    
    if (visibleIndex != NSNotFound) {
        page = [self.visiblePages objectAtIndex:visibleIndex];
    } else if (self.pageViewDataSource &&
               [self.pageViewDataSource respondsToSelector:@selector(pageView:pageAtIndex:)]) {
        page = [self.pageViewDataSource pageView:self pageAtIndex:index];
    }
    
    return page;
}

-(GLOnePageView*)nextLastPage
{
    NSInteger nextLastPageIndex =[ self lastVisiblePageIndex] + 1;
    return [self pageAtIndex:nextLastPageIndex];
}

-(GLOnePageView*)previousFirstPage
{
    NSInteger previousPageIndex = [self firstVisiblePageIndex]  - 1;
    return [self pageAtIndex:previousPageIndex];
}

- (GLOnePageView *)nextPage
{
    return [self pageAtIndex:[self nextPageIndex]];
}

- (GLOnePageView *)currentPage
{
    return [self pageAtIndex:[self currentPageIndex]];
}

- (GLOnePageView *)previousPage
{
    NSInteger preIdex = [self previousPageIndex];
    return [self pageAtIndex:preIdex];
}

#pragma mark - Visible pages

- (NSUInteger)numberOfVisiblePages
{
    return self.visibleIndices.count;
}

- (NSUInteger)firstVisiblePageIndex
{
    NSNumber *firstVisibleIndex = [self.visibleIndices firstObject];
    return [firstVisibleIndex integerValue];
}

- (NSUInteger)lastVisiblePageIndex
{
    NSNumber *lastVisibleIndex = [self.visibleIndices lastObject];
    return [lastVisibleIndex integerValue];
}

- (NSUInteger)nextVisiblePageIndex
{
    return [self nextIndex:[self lastVisiblePageIndex]];
}

- (NSUInteger)previousVisiblePageIndex
{
    return [self previousIndex:[self firstVisiblePageIndex]];
}

- (GLOnePageView *)lastVisiblePage
{
    return [self pageAtIndex:[self lastVisiblePageIndex]];
}

- (GLOnePageView *)firstVisiblePage
{
    return [self pageAtIndex:[self firstVisiblePageIndex]];
}

- (void)addNextVisiblePage:(GLOnePageView *)page
{
    [self.visibleIndices addObject:[NSNumber numberWithUnsignedInteger:[self nextVisiblePageIndex]]];
    [self.visiblePages addObject:page];
}

- (void)addPreviousVisiblePage:(GLOnePageView *)page
{
    [self.visibleIndices insertObject:[NSNumber numberWithUnsignedInteger:[self previousVisiblePageIndex]] atIndex:0];
    [self.visiblePages insertObject:page atIndex:0];
}

- (void)removeFirstVisiblePage
{
    GLOnePageView *firstVisiblePage = [self firstVisiblePage];
    [firstVisiblePage removeFromSuperview];
    [self.reusablePages addObject:firstVisiblePage];
    [self.visibleIndices removeObjectAtIndex:0];
    [self.visiblePages removeObjectAtIndex:0];
}

- (void)removeLastVisiblePage
{
    GLOnePageView *lastVisiblePage = [self lastVisiblePage];
    [[self lastVisiblePage] removeFromSuperview];
    [self.reusablePages addObject:lastVisiblePage];
    [self.visibleIndices removeLastObject];
    [self.visiblePages removeLastObject];
}

#pragma mark - Reusable pages

- (GLOnePageView *)dequeueReusablePage
{
    GLOnePageView *page = nil;
    page = [self.reusablePages lastObject];
    if (page) {
        [self.reusablePages removeLastObject];
        [page prepareForReuse];
    }
    return page;
}
-(GLCardView*)dequeueReuableCard
{
    GLCardView *card =[self.reusableCards firstObject];
    if(card){
        [self.reusableCards removeObjectAtIndex:0];
    }
    return card;
}

#pragma mark - Content offset

- (CGFloat)minContentOffsetX
{
    return [self centerContentOffsetX] - [self distanceFromCenterOffsetX];
}

- (CGFloat)centerContentOffsetX
{
    if (![self shouldScrollingWrapDataSource] && [self isFirstPage]) {
        return 0;
    }
    if(![self shouldScrollingWrapDataSource] && [self isSecondPage]){
        return [self pageWidth];
    }
    if(![self shouldScrollingWrapDataSource] && [self isLastSecondPage]){
        return [self pageWidth]*3;
    }
    if(![self shouldScrollingWrapDataSource] && [self isLastPage]){
        return [self pageWidth]*4;
    }
    return [self pageWidth]*2;
}

- (CGFloat)maxContentOffsetX
{
    return [self centerContentOffsetX] + [self distanceFromCenterOffsetX];
}

- (CGFloat)distanceFromCenterOffsetX
{
    return [self pageWidth];
}

- (CGFloat)contentSizeWidth
{
    if([self numberOfPages] > 5){
        return [self pageWidth] * 5.0f;
    }else{
        return [self pageWidth] * [self numberOfPages];
    }
}

#pragma mark - Layout

- (void)reloadData
{
    [self updateNumberOfPages];
    [self updateCurrentPageIndex];
    [self resetVisiblePages];
    [self layoutCurrentView];
}

- (void)updateData
{
    [self updateNumberOfPages];
    [self resetVisiblePages];
    [self layoutCurrentView];
}

- (void)resetReusablePages
{
    [self.reusablePages removeAllObjects];
}

- (void)resetVisiblePages
{
    NSUInteger currentPageIndex = [self currentPageIndex];
    GLOnePageView *currentpage =  [self currentPage];
    
    for (int i = 0; i < self.visibleIndices.count; i++) {
        NSNumber *visibleIndex = [self.visibleIndices objectAtIndex:i];
        GLOnePageView *visiblePage = [self.visiblePages objectAtIndex:i];
        
        if ([self currentPageIndex] != visibleIndex.integerValue) {
            [self.reusablePages addObject:visiblePage];
            [visiblePage removeFromSuperview];
        }
    }
    
    [self.visibleIndices removeAllObjects];
    [self.visibleIndices addObject:[NSNumber numberWithUnsignedInteger:currentPageIndex]];
    
    [self.visiblePages removeAllObjects];
    [self.visiblePages addObject:currentpage];
}

- (void)layoutCurrentView
{
    [self resetContentSize];
    [self centerContentOffset];
    [self placePage:[self currentPage] atPoint:[self centerContentOffsetX]];
}

- (void)resetContentSize
{
    self.contentSize = CGSizeMake([self contentSizeWidth], self.frame.size.height);
}
- (void)centerContentOffset
{
    self.contentOffset = CGPointMake([self centerContentOffsetX], self.contentOffset.y);
}

- (void)recenterCurrentView
{
    [self centerContentOffset];
    [self movePage:[self currentPage] toPositionX:[self centerContentOffsetX]];
}

- (void)movePage:(GLOnePageView *)page toPositionX:(CGFloat)positionX
{
    CGRect frame = page.frame;
    frame.origin.x =  positionX;
    page.frame = frame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self isScrollNecessary]) {
        [self recenterContent];
        [self tileViews];//add or remove views
    } else {
        [self recenterCurrentView];
        [self updateNumberOfPages];
    }
}

- (void)recenterContent
{
    CGPoint currentContentOffset = [self contentOffset];
    CGFloat tranlation = currentContentOffset.x - [self centerContentOffsetX];
    [self translation:tranlation]; //translation delegate
    
    CGFloat distanceFromCenterOffsetX = fabs(currentContentOffset.x - [self centerContentOffsetX]);
    
    if (distanceFromCenterOffsetX  >= [self distanceFromCenterOffsetX]) {
        if (currentContentOffset.x <= [self minContentOffsetX]) {
            [self previous];
            [self didScrollToPreviousPage];
        } else if (currentContentOffset.x >= [self maxContentOffsetX]) {
            [self next];
            [self didScrollToNextPage];
        }
        
        [self updateNumberOfPages];
        [self resetVisiblePages];
        [self recenterCurrentView];
    }
}

#pragma mark - Pages tiling

- (void)placePage:(GLOnePageView *)page atPoint:(CGFloat)point
{
    CGRect frame = [page frame];
    frame.origin.x = point;
    page.frame = frame;
    
    [self addSubview:page];
}

- (CGFloat)placePage:(GLOnePageView *)page onRight:(CGFloat)rightEdge
{
    CGRect frame = [page frame];
    frame.origin.x = rightEdge;
    page.frame = frame;
    
    [self addSubview:page];
    [self addNextVisiblePage:page];
    
    return CGRectGetMaxX(frame);
}

- (CGFloat)placePage:(GLOnePageView *)page onLeft:(CGFloat)leftEdge
{
    CGRect frame = [page frame];
    frame.origin.x = leftEdge - [self pageWidth];
    page.frame = frame;
    NSLog(@"point left:%@",[NSValue valueWithCGRect:frame]);

    [self addSubview:page];
    [self addPreviousVisiblePage:page];
    
    return CGRectGetMinX(frame);
}

- (void)tileViews
{
    NSInteger pageSize = 2;
    while ([self lastVisiblePageIndex] < [self lastPageIndex] && ( [self lastVisiblePageIndex]<[self currentPageIndex]+pageSize || [self currentPageIndex] >= [self lastVisiblePageIndex]-pageSize) ) {
        CGFloat rightEdge = CGRectGetMaxX([self lastVisiblePage].frame);
        [self placePage:[self nextLastPage] onRight:rightEdge];
        if([_visiblePages count] > 2*pageSize + 1){
            [self removeFirstVisiblePage];
        }
    }
 
    while ([self firstVisiblePageIndex] > [self firstPageIndex] &&( [self firstVisiblePageIndex] > [self currentPageIndex]-pageSize || [self currentPageIndex] <= pageSize ) ) {
        CGFloat leftEdge = CGRectGetMinX([self firstVisiblePage].frame);
        [self placePage:[self previousFirstPage] onLeft:leftEdge];
        if([_visiblePages count] > 2*pageSize + 1){
            [self removeLastVisiblePage];
        }
    }
}

#pragma mark - Scroll

- (void)scrollToNextPage
{
    if ([self isScrollNecessary]) {
        CGRect frame = [self currentPage].frame;
        CGFloat x = CGRectGetMaxX(frame);
        CGFloat y = frame.origin.y;
        CGPoint point = CGPointMake(x, y);
        NSLog(@"point next page :%@",[NSValue valueWithCGPoint:point]);
        [self setContentOffset:point animated:YES];
    }
}

- (void)scrollToPreviousPage
{
    if ([self isScrollNecessary]) {
        CGRect frame = [self currentPage].frame;
        CGFloat x = CGRectGetMinX(frame) - [self pageWidth];
        CGFloat y = frame.origin.y;
        CGPoint point = CGPointMake(x, y);
        NSLog(@"point pre page:%@",[NSValue valueWithCGPoint:point]);
        [self setContentOffset:point animated:YES];
    }
}

- (void)didScrollToNextPage
{
    if (self.pageViewDelegate &&
        [self.pageViewDelegate respondsToSelector:@selector(pageViewDidScrollNextPage:)]) {
        [self.pageViewDelegate pageViewDidScrollNextPage:self];
    }
}

- (void)didScrollToPreviousPage
{
    if (self.pageViewDelegate &&
        [self.pageViewDelegate respondsToSelector:@selector(pageViewDidScrollPreviousPage:)]) {
        [self.pageViewDelegate pageViewDidScrollPreviousPage:self];
    }
}

-(void)translation:(CGFloat)translation
{
    if(translation < 0){
        if (self.pageViewDelegate &&
            [self.pageViewDelegate respondsToSelector:@selector(pageView:willShowLeftPage:progress:)]) {
            CGFloat progress = fabsf(translation)/[self pageWidth];
            [self.pageViewDelegate pageView:self willShowLeftPage:[self previousPageIndex] progress:progress];
        }
    }
    if(translation >= 0){
        if (self.pageViewDelegate &&
            [self.pageViewDelegate respondsToSelector:@selector(pageView:willShowRightPage:progress:)]) {
            CGFloat progress = fabsf(translation)/[self pageWidth];
            [self.pageViewDelegate pageView:self willShowRightPage:[self nextPageIndex] progress:progress];
        }
    }
}

#pragma mark one page view delegate and datasource
-(NSInteger)numberOfCards:(GLOnePageView*)onePageView
{
    return [self.pageViewDataSource pageView:self numberOfCardsForPage:onePageView.pageIndex];
}
-(GLCardView*)onePageView:(GLOnePageView*)onePageView cardIndex:(NSInteger)index
{
    NSIndexPath *indexPath =[NSIndexPath indexPathForCard:index inPage:onePageView.pageIndex];
    return  [self.pageViewDataSource pageView:self cardAtIndex:indexPath];
}
//delegate for reuseable
-(void)onePageView:(GLOnePageView *)onePageView recycleCardView:(GLCardView *)cardView
{
    [_reusableCards addObject:cardView];
}
-(void)onePageView:(GLOnePageView *)onePageView recycleCardViews:(NSArray *)cardViews
{
    [_reusableCards addObjectsFromArray:cardViews];
}

-(void)onePageView:(GLOnePageView *)onePageView willLeftShowCard:(NSInteger)card progress:(CGFloat)progress
{
    NSIndexPath *indexPath =[NSIndexPath indexPathForCard:card inPage:onePageView.pageIndex];
    if([self.pageViewDelegate respondsToSelector:@selector(pageView:willLeftShowCard:progress:)]){
        [self.pageViewDelegate pageView:self willLeftShowCard:indexPath progress:progress];
    }
}
-(void)onePageView:(GLOnePageView *)onePageView willRightShowCard:(NSInteger)card progress:(CGFloat)progress
{
    NSIndexPath *indexPath =[NSIndexPath indexPathForCard:card inPage:onePageView.pageIndex];
    if([self.pageViewDelegate respondsToSelector:@selector(pageView:willRightShowCard:progress:)]){
        [self.pageViewDelegate pageView:self willRightShowCard:indexPath progress:progress];
    }
}

-(void)onePageView:(GLOnePageView *)onePageView didShowCard:(NSInteger)card
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForCard:card inPage:onePageView.pageIndex] ;
    if([self.pageViewDelegate respondsToSelector:@selector(pageView:didShowCard:)]){
        [self.pageViewDelegate pageView:self didShowCard:indexPath];
    }
}

@end
