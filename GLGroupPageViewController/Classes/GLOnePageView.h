//
//  GLOneGroupView.h
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-13.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLCardView.h"

@class  GLOnePageView;

@protocol GLOnePageDataSource <NSObject>

@required
-(NSInteger)numberOfCards:(GLOnePageView*)groupView;
-(GLCardView*)onePageView:(GLOnePageView*)groupView cardIndex:(NSInteger)index;

@end

@protocol GLOnePageDelegate <NSObject>
@required
-(void)onePageView:(GLOnePageView*)onePageView recycleCardView:(GLCardView*)cardView;
-(void)onePageView:(GLOnePageView *)onePageView recycleCardViews:(NSArray*)cardViews;

@optional
//already show view
-(void)onePageView:(GLOnePageView *)onePageView didShowCard:(NSInteger)card;
//will show view and get progress,this is need for,tranlation left
-(void)onePageView:(GLOnePageView *)onePageView willLeftShowCard:(NSInteger)card progress:(CGFloat)progress;
//will show view and get progress ,translation right
-(void)onePageView:(GLOnePageView *)onePageView willRightShowCard:(NSInteger)card progress:(CGFloat)progress;

@end


@interface GLOnePageView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic,assign) id<GLOnePageDataSource> dataSource;
@property (nonatomic,assign) id<GLOnePageDelegate> delegate;
@property (nonatomic,assign) NSInteger pageIndex; // for remenber current page index

-(void)showCard:(NSInteger)card;

-(void)reloadData;

-(void)prepareForReuse;
@end


//index path view
@interface NSIndexPath(GLPageCardView)

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,assign) NSInteger card;

+(NSIndexPath*)indexPathForCard:(NSInteger)card inPage:(NSInteger)page;


@end