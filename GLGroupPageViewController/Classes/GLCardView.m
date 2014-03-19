//
//  GLPageView.m
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-12.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import "GLCardView.h"

@interface GLCardView ()
{
    UILabel *label;
}
@end

@implementation GLCardView
@synthesize  index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 200, 200)];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.font = [UIFont systemFontOfSize:20];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        
        UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"按钮" forState:UIControlStateNormal];
        [button setFrame:CGRectMake(20, 80, 200, 200)];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:button];
    }
    return self;
}

-(void)buttonClick:(UIButton*)button
{
    NSLog(@"buttonClick");
}

-(void)setThisIndex:(NSString*)aindex
{
    [label setText:aindex];
}




@end
