//
//  GLOneGroupViewController.m
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-12.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import "GLPageCardViewController.h"

@interface GLPageCardViewController ()
{
    NSInteger _leftCount;
    NSInteger _rightCount;
    NSMutableArray *_colors;
    GLPageCardView *_pageCardView;
}
@end

@implementation GLPageCardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _colors = [[NSMutableArray alloc] init];
    for (int j=0; j<100; j++) {
        NSMutableArray *second = [[NSMutableArray alloc] init];
        for (int i=0; i< 4; i++) {
            CGFloat red  = arc4random()%255/255.0;
            CGFloat blue = arc4random()%255/255.0;
            CGFloat green = arc4random()%255/255.0;
            [second addObject:[UIColor colorWithRed:red green:green blue:blue alpha:1]];
        }
        [_colors addObject:second];
    }
    
    _pageCardView = [[GLPageCardView alloc] initWithFrame:self.view.bounds];
    _pageCardView.dataSource = self;
    _pageCardView.delegate  = self;
    [self.view addSubview:_pageCardView];
    [_pageCardView reloadData];
    
    
    
    UIButton *fbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    fbutton.frame= CGRectMake(0, self.view.frame.size.height - 80, 100, 40);
    [fbutton setTitle:@"First Day" forState:UIControlStateNormal];
    [fbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [fbutton addTarget:self action:@selector(goFirstDay) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:fbutton];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame= CGRectMake(200, self.view.frame.size.height - 80, 100, 40);
    [button setTitle:@"Today" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goToday) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
}
-(void)goFirstDay
{
    [_pageCardView scrollToPage:0];
}
-(void)goToday
{
    [_pageCardView scrollToPage:([_colors count] - 1)];
}

#pragma mark data source
-(NSInteger)numberOfPageCard:(GLPageCardView *)pageCardView
{
    return [_colors count];
}

-(NSInteger)pageCardView:(GLPageCardView *)pageCardView numberOfCardInPage:(NSInteger)page
{
    return  [[_colors objectAtIndex:page] count];
}

-(GLCardView*)pageCardView:(GLPageCardView *)pageCardView cardOfIndex:(NSIndexPath *)index
{
    GLCardView *nextCard = [pageCardView dequeueReuableCard];
    if(nextCard == nil){
        nextCard= [[GLCardView alloc] init];
        nextCard.layer.cornerRadius = 10.0;
    }
    UIColor *color = [[_colors objectAtIndex:index.page] objectAtIndex:index.card];
    nextCard.backgroundColor = color;
    [nextCard setThisIndex:[NSString stringWithFormat:@"page:%ld,card:%ld",(long)index.page,(long)index.card]];
    return nextCard;
}

-(NSString*)pageCardView:(GLPageCardView *)pageCardView titleOfPage:(NSInteger)page
{
    return [NSString stringWithFormat:@"title:%ld",(long)page];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark scroll view delegate
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
