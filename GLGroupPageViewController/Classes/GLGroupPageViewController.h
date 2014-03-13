//
//  GLGroupPageViewController.h
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-12.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPageView.h"
#import "GLOneGroupViewController.h"

@class GLGroupPageViewController;

@protocol  GLGroupPageDatasource <NSObject>

@required
-(NSInteger)numberOfPage:(GLGroupPageViewController *)groupPageViewController groudIndex:(NSInteger)groupIndex;
-(GLPageView*)viewOfPage:(GLGroupPageViewController*)groupViewController indexPath:(NSIndexPath*)indexPath;

@end

@interface GLGroupPageViewController : UIViewController

@end
