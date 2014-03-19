//
//  GLTitleBar.m
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-17.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import "GLTitleBar.h"

@interface GLTitleBar()
{
    BOOL _showingMain;
}
@end

@implementation GLTitleBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _showingMain = YES;
        
        _mainTitle = [[UILabel alloc] initWithFrame:CGRectMake([self pageWidth]/4, 0, [self pageWidth]/2,[self pageHeight])];
        _mainTitle.backgroundColor = [UIColor clearColor];
        [_mainTitle setFont: [UIFont systemFontOfSize:20]];
        [_mainTitle setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_mainTitle];
        
        _backTitle = [[UILabel alloc] initWithFrame:CGRectMake([self pageWidth]/4, 0, [self pageWidth]/2,[self pageHeight])];
        _backTitle.backgroundColor = [UIColor clearColor];
        [_backTitle setFont:[UIFont systemFontOfSize:20]];
        [_backTitle setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_backTitle];
        
        _backTitle.transform  = CGAffineTransformMakeTranslation(-[self pageWidth]*2/3,0);
    }
    return self;
}
-(void)setTitle:(NSString *)title
{
    if(_showingMain){
        _mainTitle.text = title;
    }else{
        _backTitle.text = title;
    }
}
-(void)didChangeTitle:(NSString*)title
{
    _showingMain = !_showingMain;
    [self setTitle:title];
}

-(CGFloat)pageWidth
{
    return self.frame.size.width;
}
-(CGFloat)pageHeight
{
    return self.frame.size.height;
}
-(CGFloat)totalTranslationDistance
{
    return self.frame.size.width * 2/3;
}

-(void)fromLeftTransferTitle:(NSString*)title progress:(CGFloat)progress
{
    UILabel *outView;
    UILabel *innerView;
    if(_showingMain){
        outView = _backTitle;
        innerView = _mainTitle;
    }else{
        outView = _mainTitle;
        innerView = _backTitle;
    }
    [UIView animateWithDuration:0.1 animations:^{
        outView.transform =CGAffineTransformMakeTranslation(-[self totalTranslationDistance]*(1-progress), 0);
        outView.alpha = progress;
        outView.text = title;
        
        innerView.transform = CGAffineTransformMakeTranslation([self totalTranslationDistance]*progress, 0);
        innerView.alpha = 1 - progress;
    }];
}

-(void)fromRightTransferTitle:(NSString*)title progress:(CGFloat)progress
{
    UILabel *outView;
    UILabel *innerView;
    if(_showingMain){
        outView = _backTitle;
        innerView = _mainTitle;
    }else{
        outView = _mainTitle;
        innerView = _backTitle;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        outView.transform =CGAffineTransformMakeTranslation([self totalTranslationDistance]*(1-progress), 0);
        outView.alpha = progress;
        outView.text = title;
        
        innerView.transform = CGAffineTransformMakeTranslation(-[self totalTranslationDistance]*progress, 0);
        innerView.alpha = 1-progress;
    }];
}
@end
