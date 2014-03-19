//
//  GLOneGroupViewController.h
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-12.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPageCardView.h"

@interface GLOneGroupViewController : UIViewController<GLPageCardViewDataSource,GLPageCardViewDelegate>

@property (nonatomic,retain) GLPageCardView *pageCardView;

@end
