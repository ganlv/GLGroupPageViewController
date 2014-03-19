//
//  GLOneGroupView.m
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-13.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import "GLOnePageView.h"
#import <objc/runtime.h>

typedef NS_OPTIONS(NSUInteger,GLPanDirection){
    GLPanDirectionUp = 1<<0,
    GLPanDirectionDown = 1 <<1,
    GLPanDirectionLeft  = 1 <<2,
    GLPanDirectionRight = 1<<3,
};
#define  TOP_OFFSET 96
#define  BOTTOM_OFFSET 126
#define  MAX_SHOW_COUNT 5
#define  CARD_OFFSET 4
#define  ANIMATION_DURATION 0.3

@interface GLOnePageView()
{
    NSMutableArray *_visibleIndexs;
    NSMutableArray *_cardArray;
    NSMutableArray *_outOfBoundsCards;
    
    NSInteger _totalCount;
    NSInteger _currentIndex;
    
    GLPanDirection _direction;
    CGRect _cardRawFrame;
    
    CGPoint _startPoint;//make for touch
    CGPoint _prePoint;
    BOOL _isBegan;
    
    UIView *_contentView;
}

@end

@implementation GLOnePageView
@synthesize dataSource;
@synthesize delegate;
@synthesize pageIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor  = [UIColor whiteColor];
        [self setUserInteractionEnabled:YES];
        _isBegan = NO;
        _cardArray  = [[NSMutableArray alloc] initWithCapacity:5];
        _outOfBoundsCards = [[NSMutableArray alloc] initWithCapacity:5]; //for out of bounds
        _visibleIndexs = [[NSMutableArray alloc] initWithCapacity:5];
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_contentView];
        self.clipsToBounds = YES;
        #pragma  warning  out set
        _cardRawFrame = CGRectMake(28, TOP_OFFSET, self.frame.size.width - 32*2, self.frame.size.height - BOTTOM_OFFSET-TOP_OFFSET);
        _currentIndex = NSIntegerMax;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollThis:)];
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
    }
    return self;
}
-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [self showData];
}

-(void)showCard:(NSInteger)card
{
    _currentIndex  = card;
}

-(void)reloadData
{
    [self prepareForReuse];
    [self showData];
}

-(void)showData
{
    _totalCount = [dataSource numberOfCards:self];
    
    if (_currentIndex == NSIntegerMax) {
        NSInteger  index = _totalCount - 1;
        _currentIndex = index;
    }
    [self insertPreCard:_currentIndex];
    [self insertNextCard];
}

#pragma mark for data insert  and remove
-(void)insertNextCard
{
    //for add next resuable page view
    NSInteger nextIndex = _currentIndex + [_outOfBoundsCards count] + 1;
    while([_outOfBoundsCards count]  <= 2 && nextIndex< _totalCount) {
        GLCardView *pageView  = [dataSource onePageView:self cardIndex:nextIndex];
        pageView.transform = CGAffineTransformIdentity;
        pageView.frame = _cardRawFrame;
        pageView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.frame), 0);
        [_contentView addSubview:pageView];
        [_outOfBoundsCards addObject:pageView];
        nextIndex++;
    }
}
-(void)insertPreCard:(NSInteger)preIndex
{
    //for previouse value
    while (preIndex >= 0 && [_cardArray count] < MAX_SHOW_COUNT ) {
        GLCardView *pageView = [dataSource onePageView:self  cardIndex:preIndex];
        pageView.transform = CGAffineTransformIdentity;
        pageView.frame = _cardRawFrame;
        [_contentView addSubview:pageView];
        [_contentView sendSubviewToBack:pageView];
        [_cardArray insertObject:pageView atIndex:0];
        [_visibleIndexs insertObject:[NSNumber numberWithInteger:preIndex] atIndex:0];
        preIndex--;
    }
    [self transformCardViews];
}

-(void)deletePreFirstCard
{
    if( [_cardArray count] >= MAX_SHOW_COUNT){
        GLCardView *firstView = [_cardArray firstObject];
        [firstView removeFromSuperview];
        [_cardArray removeObject:firstView];
        [_visibleIndexs removeObjectAtIndex:0];
        if([delegate respondsToSelector:@selector(onePageView:recycleCardView:)]){
            [delegate onePageView:self recycleCardView:firstView];
        }
    }
    [self transformCardViews];
}

-(void)deletePostLastCard
{
    if([_outOfBoundsCards count] > 2)
    {
        GLCardView *firstView = [_outOfBoundsCards lastObject];
        [_outOfBoundsCards removeLastObject];
        if([delegate respondsToSelector:@selector(onePageView:recycleCardView:)]){
            [delegate onePageView:self recycleCardView:firstView];
        }
    }
}
#pragma mark gesture recognizor
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if( [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ){
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint location = [panGesture locationInView:self];
        //看看点在不在Card里面，不在这里就不要动了，去动这个模块
        if( !CGRectContainsPoint(_cardRawFrame, location) ){
            return NO;
        }
    }
    return YES;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if( [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ){
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [panGesture translationInView:self];
        CGPoint location = [panGesture locationInView:self];
        
        //if not touch in car do not
        if( !CGRectContainsPoint(_cardRawFrame, location) ){
            return NO;
        }
        return [self forBeganGesture:translation];
    }else{
        return [self forBeganGesture:CGPointMake(2, 0)];
    }
}

-(BOOL)forBeganGesture:(CGPoint)translation
{
    if (abs(translation.x ) > abs(translation.y)*0.8 ) {
        //horizontal
        if (translation.x > 0 ) {
            _direction = GLPanDirectionRight;
        }else{
            _direction = GLPanDirectionLeft;
        }
    }else{
        //vertical
        if(translation.y > 0){
            _direction = GLPanDirectionDown;
        }else{
            _direction = GLPanDirectionUp;
        }
    }
    
    if(_direction == GLPanDirectionLeft){
        //check if need more
        if(_currentIndex == _totalCount -1){
            return NO;
        }
    }
    if(_direction == GLPanDirectionRight){
        if(_currentIndex == 0){
            return NO;
        }
    }
    return YES;
}


-(void)detectDirection:(UIPanGestureRecognizer*)panGesture
{
    CGPoint translation = [panGesture translationInView:self];
    UIGestureRecognizerState state = panGesture.state;
    if(state == UIGestureRecognizerStateBegan){
        if (abs(translation.x ) > abs(translation.y) * 0.8) {
            //horizontal
            if (translation.x > 0 ) {
                _direction = GLPanDirectionRight;
            }else{
                _direction = GLPanDirectionLeft;
            }
        }else{
            //vertical
            if(translation.y > 0){
                _direction = GLPanDirectionDown;
            }else{
                _direction = GLPanDirectionUp;
            }
        }
    }
    if (state == UIGestureRecognizerStateBegan  || state == UIGestureRecognizerStateChanged) {
        if (abs(translation.x ) > abs(translation.y)*0.8) {
            //horizontal
            if (_direction == GLPanDirectionRight || _direction == GLPanDirectionLeft) {
                if (translation.x > 0 ) {
                    _direction = GLPanDirectionRight;
                }else{
                    _direction = GLPanDirectionLeft;
                }
            }
        }else{
            //vertical
            if(_direction == GLPanDirectionDown || _direction == GLPanDirectionUp){
                if(translation.y > 0){
                    _direction = GLPanDirectionDown;
                }else{
                    _direction = GLPanDirectionUp;
                }
            }
        }
    }
}


-(void)transformCardViews
{
    for (NSInteger i = 0 ; i < [_cardArray count]; i++) {
        UIView *view = [_cardArray objectAtIndex:i];
        NSInteger offset = i;
        if([_cardArray count] >= MAX_SHOW_COUNT){
            if (i >  [_cardArray count] - MAX_SHOW_COUNT ){
                offset = i- ( [_cardArray count] - MAX_SHOW_COUNT+1 );
            }else{
                offset = 0;
            }
        }
        CGAffineTransform transform  = CGAffineTransformMakeTranslation(offset*CARD_OFFSET, 0);
        view.transform = transform;
    }
}

-(void)scrollThis:(UIPanGestureRecognizer*)panGesture
{
    CGPoint translation = [panGesture translationInView:self];
    CGPoint velocity = [panGesture velocityInView:self];
    
    UIGestureRecognizerState state = panGesture.state;
    
    [self detectDirection:panGesture];
    
    if (_direction == GLPanDirectionDown || _direction == GLPanDirectionUp) {
        return;
    }
    
    if(state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged){
        if (_direction == GLPanDirectionRight) {
            [self panRight:translation];
        }else{
            [self panLeft:translation];
        }
    }else if(state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled || state == UIGestureRecognizerStateFailed){
        if (_direction == GLPanDirectionRight) {
            [self endPanRight:translation velocity:velocity];
        }else{
            [self endPanLeft:translation velocity:velocity];
        }
    }
}

-(void)endPanRight:(CGPoint)translation velocity:(CGPoint)velocity
{
    //this for have more
    if ([_cardArray count] > 1) {
        CGFloat xTranslation =  translation.x + velocity.x*0.25;
        if(xTranslation >CGRectGetWidth(self.frame)/3)
        {
            UIView *backedView = [_cardArray lastObject];
            [_cardArray removeObject:backedView];
            [_visibleIndexs removeLastObject];
            _currentIndex = _currentIndex -1;
            if([delegate respondsToSelector:@selector(onePageView:didShowCard:)]){
                [delegate onePageView:self didShowCard:_currentIndex];
            }
            
            [_outOfBoundsCards insertObject:backedView atIndex:0]; //insert back view here
            [UIView animateWithDuration:0.3 animations:^{
                backedView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.frame), 0);
            } completion:^(BOOL finished) {
                //remove this view form over view
                [self deletePostLastCard];
                [self insertPreCard:([[_visibleIndexs firstObject] intValue] -1)];
            }];
        }
        [self transformCardViews];
    }else{
        //this for go pre group
        [self transformCardViews];
    }
}

-(void)panRight:(CGPoint)translation
{
    CGFloat xPoint =  translation.x ;
    if ([_cardArray count] > 1 ) {//remove pages
        for (NSInteger i = [_cardArray count]-1; i>=0; i--) {
            UIView *view = [_cardArray objectAtIndex:i];
            // y = -(0.03x-10)^2+10^2,tensile force sence
            CGFloat xTranslate = 0;
            if(i <[_cardArray count]-1){
                CGFloat scaleFactor = pow((((CGFloat)i)/([_cardArray count]-1)),1.2);
                NSInteger offset = i;
                if([_cardArray count] >= MAX_SHOW_COUNT){
                    if (i != 0){
                        offset = i-1;
                    }
                }
                xTranslate = -pow(0.01*scaleFactor*xPoint - 12.0*scaleFactor,2) + pow(12.0*scaleFactor,2) + offset*CARD_OFFSET;
            }else{
                xTranslate = xPoint + ([_cardArray count]-1)*CARD_OFFSET;
                if([delegate respondsToSelector:@selector(onePageView:willLeftShowCard:progress:)]){
                    [delegate onePageView:self willLeftShowCard:(_currentIndex - 1) progress:[self progress:fabs(xPoint)] ];
                }
            }
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(xTranslate, 0);
            view.transform = transform;
        }
    }
}


-(void)endPanLeft:(CGPoint)translation  velocity:(CGPoint)velocity
{
    //this is anther card
    if( [_outOfBoundsCards count]  >  0){
        CGFloat xTranslation =  fabs(translation.x)+fabs(velocity.x*0.25);
        UIView *thisView = [_outOfBoundsCards firstObject];
        
        if(abs(xTranslation) >CGRectGetWidth(self.frame)/3)
        {
            [_outOfBoundsCards removeObjectAtIndex:0];
            
            [_cardArray addObject:thisView];
            
            _currentIndex = _currentIndex +1;
            [_visibleIndexs addObject:[NSNumber numberWithInteger:_currentIndex]];
            
            if([delegate respondsToSelector:@selector(onePageView:didShowCard:)])
            {
                [delegate onePageView:self didShowCard:_currentIndex];
            }
            
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                thisView.transform = CGAffineTransformMakeTranslation(  ([_cardArray count] -1 )*CARD_OFFSET, 0);
            } completion:^(BOOL finished) {
                [self deletePreFirstCard];
                [self insertNextCard];
            }];
        }else{
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                thisView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.frame), 0);
            }];
        }
        [self transformCardViews];
    }
}

-(void)panLeft:(CGPoint)translation
{
    CGFloat xPoint =  translation.x ;
    
    if([_outOfBoundsCards count]  > 0){
        UIView *view  = [_outOfBoundsCards firstObject];
        CGFloat xTranslate = xPoint + [_cardArray count]*CARD_OFFSET;
        if([delegate respondsToSelector:@selector(onePageView:willRightShowCard:progress:)]){
            [delegate onePageView:self willRightShowCard:(_currentIndex - 1) progress:[self progress:fabs(xPoint)]];
        }
        
        CGAffineTransform transform  = CGAffineTransformMakeTranslation(CGRectGetWidth(self.frame) + xTranslate, 0);
        view.transform = transform;
    }
}
-(CGFloat)progress:(CGFloat)translation
{
    return translation/(CGRectGetWidth(self.frame)*0.8);
}
#pragma mark setup value
-(void)prepareForReuse
{
    for (UIView *subview in _cardArray ) {
        subview.transform = CGAffineTransformIdentity;
        [subview removeFromSuperview];
    }
    for (UIView *subview in _outOfBoundsCards) {
        subview.transform = CGAffineTransformIdentity;
        [subview removeFromSuperview];
    }
    _totalCount = 0;
    _currentIndex = 0;
    [_visibleIndexs removeAllObjects];
    if([delegate respondsToSelector:@selector(onePageView:recycleCardViews:)]){
        [delegate onePageView:self recycleCardViews:_cardArray];
        [delegate onePageView:self recycleCardViews:_outOfBoundsCards];
    }
    [_cardArray removeAllObjects];
    [_outOfBoundsCards removeAllObjects];
    _currentIndex = NSIntegerMax;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end



static const void *Page = &Page;
static const void *Card = &Card;

@implementation NSIndexPath(GLPageCardView)
@dynamic   page;
@dynamic  card;

-(NSInteger)page
{
    return [objc_getAssociatedObject(self, Page) intValue];
}
-(void)setPage:(NSInteger)page
{
    NSNumber *number= [[NSNumber alloc] initWithInteger:page];
    objc_setAssociatedObject(self, Page, number, OBJC_ASSOCIATION_COPY);
}
-(NSInteger)card
{
    return [objc_getAssociatedObject(self, Card) intValue];
}
-(void)setCard:(NSInteger)card
{
    NSNumber *number = [[NSNumber alloc] initWithInteger:card];
    objc_setAssociatedObject(self, Card, number, OBJC_ASSOCIATION_COPY);
}

+(NSIndexPath*)indexPathForCard:(NSInteger)card inPage:(NSInteger)page
{
    NSIndexPath *index =[[NSIndexPath alloc ] init];
    [index setCard:card];
    [index setPage:page];
    return  index;
}
@end
