//
//  ServicePurviewController.m
//  QHC
//
//  Created by qhc2015 on 15/7/2.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "ServicePurviewController.h"
#import "ServicePurview.h"
#import "AppDelegate.h"

@implementation ServicePurviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor viewBackgroundColor];
    UIView *titleView = [self getTopTitleView];
    [self.view addSubview:titleView];
    
    ServicePurview *servicePurview = [[ServicePurview alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [self.view addSubview:servicePurview];
    // Do any additional setup after loading the view.
}

//添加顶部标题视图
-(UIView*)getTopTitleView {
    UIView *titleView = [AppDelegate createTopTitleView];
    UITextView *titleText = (UITextView*)[titleView viewWithTag:TITLE];
    titleText.font = [UIFont systemFontOfSize:15];
    titleText.text = @"服务范围";
    
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

@end
