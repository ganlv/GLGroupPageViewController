//
//  GLOnePageViewController.m
//  GLGroupPageViewController
//
//  Created by 周 华平 on 14-3-12.
//  Copyright (c) 2014年 ganlvji. All rights reserved.
//

#import "GLOnePageViewController.h"

@interface GLOnePageViewController ()

@end

@implementation GLOnePageViewController

@synthesize number;

-(id)initWithNumber:(NSInteger)anumber
{
    self = [super init];
    if(self){
        self.number = anumber;
    }
    return  self;
}

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
    
    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(64,128,CGRectGetWidth(self.view.frame) - 128 , CGRectGetHeight(self.view.frame) - 192)];
    cardView.backgroundColor = [UIColor redColor];
    cardView.layer.cornerRadius = 10;
    [self.view addSubview:cardView];
    
    
    UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    label.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame)/2);
    label.text = [NSString stringWithFormat:@"%ld",(long)self.number];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
