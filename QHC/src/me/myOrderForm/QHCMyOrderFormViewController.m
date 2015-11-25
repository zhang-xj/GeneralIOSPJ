//
//  QHCMyOrderFormViewController.m
//  QHC
//
//  Created by qhc2015 on 15/6/30.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCMyOrderFormViewController.h"
#import "QHCMyOrderFormView.h"
#import "AppDelegate.h"

@interface QHCMyOrderFormViewController ()

@end

@implementation QHCMyOrderFormViewController

- (id)initWithTitle:(NSString*)pageTitle pType:(NSInteger)type {
    self = [super init];
    if (self) {
        self.title = pageTitle;
        orderType = type;
        self.view.backgroundColor = [UIColor viewBackgroundColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor viewBackgroundColor];
    UIView *titleView = [self getTopTitleView];
    [self.view addSubview:titleView];
    
    QHCMyOrderFormView *orderFormView = [[QHCMyOrderFormView alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height) andTitle:self.title type:orderType];
    [orderFormView setTag:3000];
    [self.view addSubview:orderFormView];
}

-(void)viewWillAppear:(BOOL)animated {
    //刷新列表
    [((QHCMyOrderFormView*)[self.view viewWithTag:3000]) getContentTableViewInitData:10];
}

//添加顶部标题视图
-(UIView*)getTopTitleView {
    UIView *titleView = [AppDelegate createTopTitleView];
    UITextView *titleText = (UITextView*)[titleView viewWithTag:TITLE];
    titleText.font = [UIFont systemFontOfSize:15];
    titleText.text = @"我的订单";
    
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
