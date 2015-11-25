//
//  BodyCareViewController.m
//  QHC
//
//  Created by qhc2015 on 15/6/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCProjectListViewController.h"
#import "QHCProjectListView.h"
#import "AppDelegate.h"

@interface QHCProjectListViewController ()

@end

@implementation QHCProjectListViewController

@synthesize bundleDataDic;
@synthesize contentScrollView;

- (id)initWithData:(NSDictionary*)initDic {
    self = [super init];
    if (self) {
        self.bundleDataDic = initDic;
        self.title = [bundleDataDic objectForKey:@"title"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor viewBackgroundColor];
    UIView *titleView = [self getTopTitleView];
    [self.view addSubview:titleView];
    
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height)];
    [self.view addSubview:contentScrollView];
    
    QHCProjectListView *projectListView = [[QHCProjectListView alloc] initWithFrame:CGRectMake(0.0, 0.0, contentScrollView.frame.size.width, contentScrollView.frame.size.height) withData:bundleDataDic];
    projectListView.delegate = self;
    [contentScrollView addSubview:projectListView];
}

//添加顶部标题视图
-(UIView*)getTopTitleView {
    UIView *titleView = [AppDelegate createTopTitleView];
    UITextView *titleText = (UITextView*)[titleView viewWithTag:TITLE];
    titleText.font = [UIFont systemFontOfSize:15];
    titleText.text = self.title;
    
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


#pragma QHCProjectListViewDelegate
-(void)viewRealFrame:(CGRect)frame{
    [self.contentScrollView setContentSize:CGSizeMake(contentScrollView.frame.size.width, frame.size.height)];
}

//进入登录页
-(void)showLoginView {
    LoginView *loginView = [[LoginView alloc ]initWithFrame:[UIScreen mainScreen].applicationFrame];
    loginView.delegate = self;
    [self.view addSubview:loginView];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, loginView.frame.origin.y, CONTENT_OFFSET, CONTENT_OFFSET)];
    [closeBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeLoginView:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setTag:123];
    [self.view addSubview:closeBtn];
}
-(void)closeLoginView:(id)sender {
    [[self.view viewWithTag:LOGIN_VIEW_TAG] removeFromSuperview];
    [[self.view viewWithTag:123] removeFromSuperview];
}

#pragma LoginSuccess delegate
-(void)loginSuccess:(UIView*)view{
    [self closeLoginView:nil];
    
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
