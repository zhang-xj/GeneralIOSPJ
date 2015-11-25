//
//  QHCMoreViewController.m
//  QHC
//
//  Created by qhc2015 on 15/6/4.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//  更多

#import "QHCMoreViewController.h"


@interface QHCMoreViewController ()

@end

@implementation QHCMoreViewController

@synthesize moreView;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor viewBackgroundColor];
    UIView *titleView = [self getTopTitleView];
    [self.view addSubview:titleView];
    
    self.moreView = [[QHCMoreView alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height - 49)];
    moreView.delegate = self;
    [self.view addSubview:moreView];
    // Do any additional setup after loading the view.
}

//添加顶部标题视图
-(UIView*)getTopTitleView {
    UIView *titleView = [AppDelegate createTopTitleView];
    UITextView *titleText = (UITextView*)[titleView viewWithTag:TITLE];
    titleText.font = [UIFont systemFontOfSize:15];
    titleText.text = @"更多";
    return titleView;
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

-(void)closeLoginView:(id)sender {
    [[self.view viewWithTag:LOGIN_VIEW_TAG] removeFromSuperview];
    [[self.view viewWithTag:123] removeFromSuperview];
}

#pragma ShowLoginviewDelegate 
-(void)showLoginView {
    LoginView *loginView = [[LoginView alloc ]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    loginView.delegate = self;
    [self.view addSubview:loginView];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 20.0, CONTENT_OFFSET, CONTENT_OFFSET)];
    [closeBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeLoginView:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setTag:123];
    [self.view addSubview:closeBtn];
}


#pragma LoginSuccess delegate
-(void)loginSuccess:(UIView*)view{
    //进入用户反馈界面
    [self closeLoginView:nil];
    [moreView.changeAccountBtn setTitle:@"切换其他账号" forState:UIControlStateNormal];
    //    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    //    UserFeedbackController *fbController = [[UserFeedbackController alloc] init];
    //    [appDelegate.myRootController pushViewController:fbController animated:YES];
}
@end
