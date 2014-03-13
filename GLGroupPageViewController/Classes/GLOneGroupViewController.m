//
//  GLOneGroupViewController.m
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-12.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import "GLOneGroupViewController.h"



@interface GLOneGroupViewController ()
{
    NSInteger _leftCount;
    NSInteger _rightCount;
}
@end

@implementation GLOneGroupViewController

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
    GLOneGroupView *oneGroupView =[[GLOneGroupView alloc] initWithFrame:self.view.bounds];
    oneGroupView.dataSource = self;
    [self.view addSubview:oneGroupView];
}

#pragma mark data source 
-(GLPageView*)oneGroupView:(GLOneGroupView *)groupView nextView:(GLPageView *)pageView
{
    GLPageView *nextPageView = [[GLPageView alloc] init];
    nextPageView.layer.cornerRadius = 10.0;
    CGFloat red  = arc4random()%255/255.0;
    CGFloat blue = arc4random()%255/255.0;
    CGFloat green = arc4random()%255/255.0;
    nextPageView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    return nextPageView;
}

-(GLPageView*)oneGroupView:(GLOneGroupView *)groupView preView:(GLPageView *)pageView
{
    GLPageView *prePageView = [[GLPageView alloc] init];
    prePageView.layer.cornerRadius = 10.0;
    CGFloat red  = arc4random()%255/255.0;
    CGFloat blue = arc4random()%255/255.0;
    CGFloat green = arc4random()%255/255.0;
    prePageView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    return prePageView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
