//
//  GLPageCardView.h
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-15.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLCardView.h"
#import "GLPageView.h"
#import "GLTitleBar.h"

@protocol GLPageCardViewDelegate;
@protocol GLPageCardViewDataSource;

@interface GLPageCardView : UIView<GLPageViewDataSource,GLPageViewDelegate>

@property (nonatomic,assign) id<GLPageCardViewDelegate> delegate;
@property (nonatomic,assign) id<GLPageCardViewDataSource> dataSource;

-(void)reloadData;

-(void)scrollToPage:(NSInteger)page;

-(GLCardView*)dequeueReuableCard;

@end



@protocol GLPageCardViewDataSource <NSObject>
@required
//number of page
-(NSInteger)numberOfPageCard:(GLPageCardView*)pageCardView;
//number of card in one page
-(NSInteger)pageCardView:(GLPageCardView*)pageCardView numberOfCardInPage:(NSInteger)page;
//for view of index
-(GLCardView*)pageCardView:(GLPageCardView*)pageCardView cardOfIndex:(NSIndexPath*)index;
//title for page
-(NSString*)pageCardView:(GLPageCardView*)pageCardView titleOfPage:(NSInteger)page;

@end

@protocol GLPageCardViewDelegate <NSObject>
@required

@end

