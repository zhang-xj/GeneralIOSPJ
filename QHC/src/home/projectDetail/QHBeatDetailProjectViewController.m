//
//  QHBeatDetailProjectViewController.m
//  QHC
//
//  Created by qhc2015 on 15/7/27.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHBeatDetailProjectViewController.h"
#import "PHBeatProjectDetailView.h"
#import "AppDelegate.h"

@interface QHBeatDetailProjectViewController ()

@end

@implementation QHBeatDetailProjectViewController

@synthesize bundleDataDic;

- (id)initWithData:(NSDictionary*)dataDic {
    self = [super init];
    if (self) {
        self.bundleDataDic = dataDic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor viewBackgroundColor];
    UIView *titleView = [self getTopTitleView];
    [self.view addSubview:titleView];
    
    PHBeatProjectDetailView *beatProjectDetailView = [[PHBeatProjectDetailView alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height) withData:bundleDataDic];
    [beatProjectDetailView setTag:999];
    [self.view addSubview:beatProjectDetailView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PHBeatProjectDetailView *beatProjectDetailView = (PHBeatProjectDetailView *)[self.view viewWithTag:999];
    [beatProjectDetailView refreshFirstBuyBtnStatus];
}

//添加顶部标题视图
-(UIView*)getTopTitleView {
    UIView *titleView = [AppDelegate createTopTitleView];
    UITextView *titleText = (UITextView*)[titleView viewWithTag:TITLE];
    titleText.font = [UIFont systemFontOfSize:15];
    titleText.text = @"青花敲术";
    
    UIButton *leftButton = (UIButton*)[titleView viewWithTag:LEFT_BUTTON];
    leftButton.hidden = NO;
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return titleView;
}

-(void)backAction:(id)sender {
    [((AppDelegate*)([UIApplication sharedApplication].delegate)).myRootController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
