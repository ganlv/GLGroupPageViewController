//
//  GLOneGroupView.h
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-13.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPageView.h"

@class  GLOneGroupView;

@protocol GLOneGroupDataSource <NSObject>

@required
-(GLPageView*)oneGroupView:(GLOneGroupView*)groupView preView:(GLPageView*)pageView;
-(GLPageView*)oneGroupView:(GLOneGroupView *)groupView nextView:(GLPageView *)pageView;

@end

@interface GLOneGroupView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic,assign) id<GLOneGroupDataSource> dataSource;


@end
