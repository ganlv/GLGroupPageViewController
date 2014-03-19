//
//  GBInfiniteScrollView.h
//  GBInfiniteScrollView
//
//  Created by Gerardo Blanco García on 01/10/13.
//  Copyright (c) 2013 Gerardo Blanco García. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense,  and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//  modified from GBInifiniteScrollView

#import <UIKit/UIKit.h>

#import "GLOnePageView.h"

@protocol GLPageViewDelegate;
@protocol GLPageViewDataSource;

@interface GLPageView : UIScrollView <UIScrollViewDelegate,GLOnePageDataSource,GLOnePageDelegate>

// page scroll view data source.
@property (nonatomic, assign) id <GLPageViewDataSource> pageViewDataSource;

// page scroll view delegate.
@property (nonatomic, assign) id <GLPageViewDelegate> pageViewDelegate;

// Initial page index.
@property (nonatomic) NSUInteger pageIndex;

// The current page index.
@property (nonatomic, readonly) NSUInteger currentPageIndex;

// Should scrolling wrap the data source's ends
@property (nonatomic) BOOL shouldScrollingWrapDataSource;

// Gets the current view.
- (GLOnePageView *)currentPage;


-(void)scrollToPage:(NSInteger)index;

// Reloads everything from scratch.
- (void)reloadData;

// Updates current page's data source
- (void)updateData;

// Returns a reusable infinite scroll view page object.
- (GLOnePageView *)dequeueReusablePage;

-(GLCardView*)dequeueReuableCard;

@end

//  This protocol represents the data model object.
@protocol GLPageViewDataSource<NSObject>

@required

// Tells the data source to return the number of pages. (required)
- (NSInteger)numberOfPagesInPageView:(GLPageView *)pageView;

// Asks the data source for a view to display in a particular page index. (required)
- (GLOnePageView *)pageView:(GLPageView *)pageView pageAtIndex:(NSUInteger)index;

//for transfer card page
-(GLCardView*)pageView:(GLPageView*)pageView cardAtIndex:(NSIndexPath*)index;
-(NSInteger)pageView:(GLPageView*)pageView numberOfCardsForPage:(NSInteger)pageIndex;

@end

//  This protocol allows the adopting delegate to respond to scrolling operations.
@protocol GLPageViewDelegate<NSObject>

@optional

// Called when the GBInfiniteScrollView has scrolled to next page.
- (void)pageViewDidScrollToPage:(GLPageView *)pageView;

//show this card
-(void)pageView:(GLPageView*)pageView didShowCard:(NSIndexPath*)index;
//will this card
-(void)pageView:(GLPageView *)pageView willLeftShowCard:(NSIndexPath*)index progress:(CGFloat)progress;
//will this right card
-(void)pageView:(GLPageView *)pageView willRightShowCard:(NSIndexPath*)index progress:(CGFloat)progress;

//will show page
-(void)pageView:(GLPageView *)pageView willShowLeftPage:(NSInteger)page progress:(CGFloat)progress;
//will show page
-(void)pageView:(GLPageView *)pageView willShowRightPage:(NSInteger)page progress:(CGFloat)progress;

@end

