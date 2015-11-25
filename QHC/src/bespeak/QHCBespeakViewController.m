//
//  QHCBespeakViewController.m
//  QHC
//
//  Created by qhc2015 on 15/6/4.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//  预约

#import "QHCBespeakViewController.h"
#import "AppDelegate.h"

@interface QHCBespeakViewController () {
    float content_y;
}

@end

@implementation QHCBespeakViewController

@synthesize bespeakView;
@synthesize loginView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor viewBackgroundColor];
    UIView *titleView = [self getTopTitleView];
    [self.view addSubview:titleView];
    
    content_y = titleView.frame.size.height;
    
}

//添加顶部标题视图
-(UIView*)getTopTitleView {
    UIView *titleView = [AppDelegate createTopTitleView];
    UITextView *titleText = (UITextView*)[titleView viewWithTag:TITLE];
    titleText.font = [UIFont systemFontOfSize:15];
    titleText.text = @"我的预约";
    return titleView;
}

-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:@"userId"];
    if (!userId || [userId length] <= 0) {//还没登陆
        if (nil == loginView) {
            self.loginView = [[LoginView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
            loginView.delegate = self;
            [self.view addSubview:loginView];
        }
        loginView.hidden = NO;
        bespeakView.hidden = YES;
    } else {//已经登陆
        if (nil == bespeakView) {
            self.bespeakView = [[QHCBespeakView alloc] initWithFrame:CGRectMake(0.0, content_y, self.view.frame.size.width, self.view.frame.size.height - content_y - 49)];
            [self.view addSubview:bespeakView];
        } else {
            [self.bespeakView getContentTableViewInitData:10];
        }
        loginView.hidden = YES;
        bespeakView.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma LoginSuccess delegate
-(void)loginSuccess:(UIView*)view{
    //初始化预约项目列表视图
    self.bespeakView = [[QHCBespeakView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [self.view addSubview:bespeakView];
    
    loginView.hidden = YES;
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
