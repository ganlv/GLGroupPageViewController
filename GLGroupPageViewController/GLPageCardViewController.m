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
    for (int j=0; j<10; j++) {
        NSMutableArray *second = [[NSMutableArray alloc] init];
        for (int i=0; i< 4; i++) {
            CGFloat red  = arc4random()%255/255.0;
            CGFloat blue = arc4random()%255/255.0;
            CGFloat green = arc4random()%255/255.0;
            [second addObject:[UIColor colorWithRed:red green:green blue:blue alpha:1]];
        }
        [_colors addObject:second];
    }
    
    GLPageCardView *pageCardView = [[GLPageCardView alloc] initWithFrame:self.view.bounds];
    pageCardView.dataSource = self;
    pageCardView.delegate  = self;
    [self.view addSubview:pageCardView];
    [pageCardView reloadData];
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
    [nextCard setThisIndex:[NSString stringWithFormat:@"page:%ld,card:%ld",index.page,index.card]];
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
