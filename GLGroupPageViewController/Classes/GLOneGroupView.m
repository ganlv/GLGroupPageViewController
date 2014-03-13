//
//  GLOneGroupView.m
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-13.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import "GLOneGroupView.h"
typedef NS_OPTIONS(NSUInteger,GLPanDirection){
    GLPanDirectionUp = 1<<0,
    GLPanDirectionDown = 1 <<1,
    GLPanDirectionLeft  = 1 <<2,
    GLPanDirectionRight = 1<<3,
};
#define  TOP_OFFSET 64
#define  BOTTOM_OFFSET 128
#define  MAX_SHOW_COUNT 5
#define  CARD_OFFSET 4
#define  ANIMATION_DURATION 0.3

static  dispatch_queue_t scrollQueue;

@interface GLOneGroupView()
{
    NSMutableArray *_pageArray;
    NSMutableArray *_outOfBoundsPage;
    
    GLPanDirection _direction;
    CGRect _cardRawFrame;
    
    CGPoint _startPoint;//make for touch
    CGPoint _prePoint;
    BOOL _isBegan;
}

@end

@implementation GLOneGroupView
@synthesize dataSource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isBegan = NO;
         scrollQueue =  dispatch_queue_create("FastScroll", NULL);
        _pageArray  = [[NSMutableArray alloc] initWithCapacity:5];
        _outOfBoundsPage = [[NSMutableArray alloc] initWithCapacity:5]; //for out of bounds
        
    }
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    _cardRawFrame = CGRectMake(28, TOP_OFFSET, self.frame.size.width - 32*2, self.frame.size.height - BOTTOM_OFFSET-TOP_OFFSET);
    
    GLPageView *view1 = [[GLPageView alloc] initWithFrame:_cardRawFrame];
    view1.backgroundColor = [UIColor blueColor];
    view1.layer.cornerRadius = 10;
    [self addSubview:view1];
    
    
    GLPageView *view2 = [[GLPageView alloc] initWithFrame:_cardRawFrame];
    view2.backgroundColor = [UIColor greenColor];
    view2.layer.cornerRadius = 10;
    [self addSubview:view2];
    
    
    GLPageView *view3 = [[GLPageView alloc] initWithFrame:_cardRawFrame];
    view3.backgroundColor = [UIColor redColor];
    view3.layer.cornerRadius = 10;
    [self addSubview:view3];
    
    GLPageView *view4 = [[GLPageView alloc] initWithFrame:_cardRawFrame];
    view4.backgroundColor = [UIColor yellowColor];
    view4.layer.cornerRadius = 10;
    [self addSubview:view4];
    
    GLPageView *view5 = [[GLPageView alloc] initWithFrame:_cardRawFrame];
    view5.backgroundColor = [UIColor brownColor];
    view5.layer.cornerRadius = 10;
    [self addSubview:view5];
    
    [_pageArray addObject:view1];
    [_pageArray addObject:view2];
    [_pageArray addObject:view3];
    [_pageArray addObject:view4];
    [_pageArray addObject:view5];
    
//    UIPanGestureRecognizer *panGesuture =  [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollThis:)];
//    panGesuture.delegate = self;
//    [self addGestureRecognizer:panGesuture];
    [self transformCardViews];
}
-(void)swipeRight:(UISwipeGestureRecognizer*)swipe
{
    [self endPanRight:CGPointMake(200, 0) velocity:CGPointMake(0, 0)];
}
#pragma mark touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch began");
    UITouch *touch = [touches anyObject];
    _startPoint = [touch locationInView:self];
    _prePoint = [touch locationInView:self];
    _isBegan = YES;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint  currentPoint = [touch locationInView:self];
    CGPoint  translation = CGPointMake(currentPoint.x - _startPoint.x, currentPoint.y - _startPoint.y);
    _prePoint = currentPoint;
    
    if(_isBegan){
        [self forBeganGesture:translation];
        _isBegan = NO;
    }

    if (abs(translation.x ) > abs(translation.y)) {
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
    if(_direction == GLPanDirectionDown || _direction == GLPanDirectionUp){
        return;
    }
    
    if (_direction == GLPanDirectionRight) {
        [self panRight:translation];
    }else{
        [self panLeft:translation];
    }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint  currentPoint = [touch locationInView:self];
    CGPoint  translation = CGPointMake(currentPoint.x - _startPoint.x, currentPoint.x - _startPoint.y);
    
    if(_isBegan){
        [self forBeganGesture:translation];
        _isBegan = NO;
    }
    
    CGPoint  velocity =CGPointMake(currentPoint.x - _prePoint.x, currentPoint.x - _prePoint.y);
    
    if (abs(translation.x ) > abs(translation.y)) {
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
    dispatch_async(scrollQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_direction == GLPanDirectionRight) {
                [self endPanRight:translation velocity:velocity];
            }else{
                [self endPanLeft:translation velocity:velocity];
            }
        });
    });
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesCancelled:touches withEvent:event];
}




#pragma mark gesture recognizor

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if( [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ){
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [panGesture translationInView:self];
        NSLog(@"%@",[NSValue valueWithCGPoint:translation]);
        return [self forBeganGesture:translation];
    }else{
        return [self forBeganGesture:CGPointMake(2, 0)];
    }
}
-(BOOL)forBeganGesture:(CGPoint)translation
{
    if (abs(translation.x ) > abs(translation.y)) {
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
        if ([_outOfBoundsPage count]  == 0) {
            GLPageView *pageView  = [dataSource oneGroupView:self nextView:[_pageArray lastObject]];
            if(pageView != nil){
                pageView.frame = _cardRawFrame;
                pageView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.frame), 0);
                [self addSubview:pageView];
                [_outOfBoundsPage addObject:pageView];
            }else{
                return NO;
            }
        }
    }
    if(_direction == GLPanDirectionRight){
        //if need need pre array
        if ([_pageArray count] < MAX_SHOW_COUNT) {
            GLPageView *pageView = [dataSource oneGroupView:self preView:[_pageArray firstObject]];
            if (pageView != nil) {
                pageView.frame = _cardRawFrame;
                [self addSubview:pageView];
                [self sendSubviewToBack:pageView];
                [_pageArray insertObject:pageView atIndex:0];
            }else{
                return NO;
            }
        }
        
    }
    return YES;
}


-(void)detectDirection:(UIPanGestureRecognizer*)panGesture
{
    CGPoint translation = [panGesture translationInView:self];
    UIGestureRecognizerState state = panGesture.state;
    if(state == UIGestureRecognizerStateBegan){
        if (abs(translation.x ) > abs(translation.y)) {
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
        if (abs(translation.x ) > abs(translation.y)) {
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
    for (NSInteger i = 0 ; i < [_pageArray count]; i++) {
        UIView *view = [_pageArray objectAtIndex:i];
        NSInteger offset = i;
        if([_pageArray count] >= MAX_SHOW_COUNT){
            if (i >  [_pageArray count] - MAX_SHOW_COUNT ){
                offset = i- ( [_pageArray count] - MAX_SHOW_COUNT+1 );
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
    
    if(state == UIGestureRecognizerStateBegan)
    {
            NSLog(@"scrollThis");
    }
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
        
        dispatch_async(scrollQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_direction == GLPanDirectionRight) {
                    [self endPanRight:translation velocity:velocity];
                }else{
                    [self endPanLeft:translation velocity:velocity];
                }
            });
        });
    }
}

-(void)endPanRight:(CGPoint)translation velocity:(CGPoint)velocity
{
    //this for have more
    if ([_pageArray count] > 1) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            CGFloat xTranslation =  translation.x + velocity.x*0.25;
            if(xTranslation >CGRectGetWidth(self.frame)/3)
            {
                UIView *backedView = [_pageArray lastObject];
                [_pageArray removeObject:backedView];
                [_outOfBoundsPage addObject:backedView];
                backedView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.frame), 0);
            }
            
            [self transformCardViews];
        } completion:^(BOOL finished) {
            //remove this view form over view
            if([_outOfBoundsPage count] > 2)
            {
                UIView *firstView = [_outOfBoundsPage firstObject];
                [firstView removeFromSuperview];
                [_outOfBoundsPage removeObject:firstView];
            }
        }];
    }else{
        //this for go pre group
        [self transformCardViews];
    }
}

-(void)panRight:(CGPoint)translation
{
    CGFloat xPoint =  translation.x ;
    if ([_pageArray count] > 1 ) {//remove pages
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            for (NSInteger i = [_pageArray count]-1; i>=0; i--) {
                UIView *view = [_pageArray objectAtIndex:i];
                // y = -(0.03x-10)^2+10^2
                CGFloat xTranslate = 0;
                if(i <[_pageArray count]-1){
                    CGFloat scaleFactor = pow((((CGFloat)i)/([_pageArray count]-1)),1.5);
                    NSInteger offset = i;
                    if([_pageArray count] >= MAX_SHOW_COUNT){
                        if (i != 0){
                            offset = i-1;
                        }
                    }
                    xTranslate = -pow(0.01*scaleFactor*xPoint - 12.0*scaleFactor,2) + pow(12.0*scaleFactor,2) + offset*CARD_OFFSET;
                }else{
                    xTranslate = xPoint + ([_pageArray count]-1)*CARD_OFFSET;
                }
                
                CGAffineTransform transform = CGAffineTransformMakeTranslation(xTranslate, 0);
                view.transform = transform;
            }
        }];
    }else{
        
    }
}


-(void)endPanLeft:(CGPoint)translation  velocity:(CGPoint)velocity
{
    //this is anther card
    if( [_outOfBoundsPage count]  >  0){
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            CGFloat xTranslation =  fabs(translation.x)+fabs(velocity.x*0.25);
            UIView *thisView = [_outOfBoundsPage lastObject];
            if(abs(xTranslation) >CGRectGetWidth(self.frame)/3)
            {
                [_outOfBoundsPage removeObject:thisView];
                [_pageArray addObject:thisView];
            }else{
                thisView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.frame), 0);
            }
            [self transformCardViews];
        } completion:^(BOOL finished) {
            if( [_pageArray count] >= MAX_SHOW_COUNT){
                UIView *firstView = [_pageArray firstObject];
                [firstView removeFromSuperview];
                [_pageArray removeObject:firstView];
            }
        }];
    }else{
#pragma warning TODO this need to next group,here do nothing
        [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self transformCardViews];
        } completion:^(BOOL finished) {
        }];
    }
    
}

-(void)panLeft:(CGPoint)translation
{
    CGFloat xPoint =  translation.x ;
    
    if([_outOfBoundsPage count]  > 0){
        UIView *view  = [_outOfBoundsPage lastObject];
        CGFloat xTranslate = xPoint + [_pageArray count]*CARD_OFFSET;
        CGAffineTransform transform  = CGAffineTransformMakeTranslation(CGRectGetWidth(self.frame) + xTranslate, 0);
        view.transform = transform;
    }
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
