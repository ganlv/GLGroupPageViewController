//
//  GLPageCardView.m
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-15.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import "GLPageCardView.h"

@interface GLPageCardView ()
{
    GLPageView *_pageView;
    GLTitleBar *_titleBar;
    NSInteger _currentPage;
    NSInteger _currentCard;
    NSInteger _totalPage;
}
//for remenber
@property (nonatomic,strong) NSMutableDictionary *cardCurrentIndexs;

@end

@implementation GLPageCardView
@synthesize delegate;
@synthesize dataSource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pageView  = [[GLPageView alloc] initWithFrame:self.bounds];
        _pageView.pageViewDataSource = self;
        _pageView.pageViewDelegate = self;
        [self addSubview:_pageView];
        
        _titleBar = [[GLTitleBar  alloc] initWithFrame:CGRectMake(0, 28, [self pageWidth], 44)];
        [_titleBar setTitle:@"title:"];
        [self addSubview:_titleBar];
    }
    return self;
}
-(CGFloat)pageWidth
{
    return self.frame.size.width;
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    NSInteger totalCount = [dataSource numberOfPageCard:self];
    NSString *firstViewTitle = [dataSource pageCardView:self titleOfPage:totalCount-1];
    [_titleBar setTitle:firstViewTitle];
}

-(void)scrollToPage:(NSInteger)page
{
    [_pageView scrollToPage:page];
}
#pragma mark for page current index
-(NSMutableDictionary*)cardCurrentIndexs
{
    if(!_cardCurrentIndexs){
        _cardCurrentIndexs = [[NSMutableDictionary alloc] init];
    }
    return _cardCurrentIndexs;
}

-(void)setCardCurrentIndex:(NSInteger)page card:(NSInteger)card
{
    NSString *pageStr =  [[NSNumber numberWithInteger:page] stringValue];
    NSString *cardStr = [[NSNumber numberWithInteger:card] stringValue];
    [self.cardCurrentIndexs setObject:cardStr forKey:pageStr];
}

-(NSInteger)getCardCurrentIndex:(NSInteger)page
{
    NSString *pageStr =  [[NSNumber numberWithInteger:page] stringValue];
    id value =  [self.cardCurrentIndexs objectForKey:pageStr];
    if(value == nil  || value == (id)[NSNull null]){
        return NSIntegerMax;
    }else{
        return [value integerValue];
    }
}

#pragma mark pageView datasource
// Tells the data source to return the number of pages. (required)
- (NSInteger)numberOfPagesInPageView:(GLPageView *)pageView
{
    NSInteger totalCount = [dataSource numberOfPageCard:self];
    [_pageView setPageIndex:(totalCount - 1)];
    _totalPage = totalCount;
    return totalCount;
}

// Asks the data source for a view to display in a particular page index. (required),this not need transfer out
- (GLOnePageView *)pageView:(GLPageView *)pageView pageAtIndex:(NSUInteger)index
{
    GLOnePageView *onePageView  = [pageView dequeueReusablePage];
    if(onePageView == nil)
    {
        onePageView  = [[GLOnePageView alloc] initWithFrame:pageView.bounds];
        onePageView.delegate =_pageView;
        onePageView.dataSource =_pageView;
    }
    onePageView.pageIndex = index;
    [onePageView showCard:[self getCardCurrentIndex:index] ];
    return onePageView;
}

-(GLCardView*)pageView:(GLPageView *)pageView cardAtIndex:(NSIndexPath*)index
{
    return [dataSource pageCardView:self cardOfIndex:index];
}

-(NSInteger)pageView:(GLPageView *)pageView numberOfCardsForPage:(NSInteger)page
{
    return [dataSource pageCardView:self numberOfCardInPage:page];
}

#pragma mark pageView delegate
-(void)pageView:(GLPageView*)pageView didShowCard:(NSIndexPath*)index;
{
    //store and remenber card position
    [self setCardCurrentIndex:index.page card:index.card];
    //modify title
}

-(void)pageView:(GLPageView *)pageView willLeftShowCard:(NSIndexPath *)index progress:(CGFloat)progress
{
    
}
-(void)pageView:(GLPageView *)pageView willRightShowCard:(NSIndexPath *)index progress:(CGFloat)progress
{
    
}


-(void)pageView:(GLPageView *)pageView willShowLeftPage:(NSInteger)page progress:(CGFloat)progress
{
    
    NSString *title =@"";
    if (pageView.currentPageIndex != 0){
        title =    [self.dataSource pageCardView:self titleOfPage:page];
        if(title == nil){
            return;
        }
    }
    [_titleBar fromLeftTransferTitle:title progress:progress];
}
-(void)pageView:(GLPageView *)pageView willShowRightPage:(NSInteger)page progress:(CGFloat)progress
{
    NSString *title  = @"";
    if (pageView.currentPageIndex != (_totalPage-1) ){
        title =   [self.dataSource pageCardView:self titleOfPage:page];
        if(title == nil){
            return;
        }
    }
    [_titleBar fromRightTransferTitle:title progress:progress];
}

-(void)pageViewDidScrollToPage:(GLPageView*)pageView
{
    NSInteger pageIndex = [pageView currentPageIndex];
    _currentPage = pageIndex;
    NSString *title = [self.dataSource pageCardView:self titleOfPage:pageIndex];
    if(title != nil){
        [_titleBar didChangeTitle:title];
    }
}

#pragma mark public method

-(GLCardView*)dequeueReuableCard
{
    return [_pageView dequeueReuableCard];
}
-(void)reloadData
{
    return [_pageView reloadData];
}


@end

