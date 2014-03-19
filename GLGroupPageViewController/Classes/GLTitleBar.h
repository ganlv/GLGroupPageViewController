//
//  GLTitleBar.h
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-17.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLTitleBar : UIView
{
    UILabel *_mainTitle;
    UILabel *_backTitle;
}

-(void)setTitle:(NSString*)title;

-(void)didChangeTitle:(NSString*)title;

//from left to title
-(void)fromLeftTransferTitle:(NSString*)title progress:(CGFloat)progress;

//from right to title
-(void)fromRightTransferTitle:(NSString*)title progress:(CGFloat)progress;;

@end
