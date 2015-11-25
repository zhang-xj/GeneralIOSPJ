//
//  MasterDetailViewController.m
//  QHC
//
//  Created by qhc2015 on 15/7/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "MasterDetailViewController.h"
#import "MasterDetail.h"
#import "AppDelegate.h"
#import "MyAlerView.h"
#import "JSONKit.h"

@interface MasterDetailViewController ()

@end

@implementation MasterDetailViewController

@synthesize masterInfoDic;
@synthesize httpRequest;

-(id)initWithData:(NSDictionary*)masterDic {
    self = [super init];
    if (self) {
        self.masterInfoDic = masterDic;
        self.title = [masterDic objectForKey:@"name"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor viewBackgroundColor];
    UIView *titleView = [self getTopTitleView];
    [self.view addSubview:titleView];
    
    MasterDetail *masterDetailView = [[MasterDetail alloc] initWithFrame:CGRectMake(0.0, titleView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - titleView.frame.size.height) andData:masterInfoDic];
    [self.view addSubview:masterDetailView];

    // Do any additional setup after loading the view.
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


-(void)collectAction:(id)sender {
    [self collectThisMaster];
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
//关闭登录页面
-(void)closeLoginView:(id)sender {
    [[self.view viewWithTag:LOGIN_VIEW_TAG] removeFromSuperview];
    [[self.view viewWithTag:123] removeFromSuperview];
}

//收藏这个养生顾问
-(void)collectThisMaster {
    //    [[LoadingView sharedLoadingView] show];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    if (userId && userId.length > 0) {
        //创建异步请求
        NSString *urlStr = @"Favorites/Append.aspx";
        self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:userId forKey:@"userid"];
        [param setObject:@"2" forKey:@"type"];
        [param setObject:[self.masterInfoDic objectForKey:@"salerid"] forKey:@"id"];
        
        [httpRequest setDelegate:self];
        //设置请求完成的回调方法
        [httpRequest setRequestFinishCallBack:@selector(collectFinish:)];
        //设置请求失败的回调方法
        [httpRequest setRequestFailCallBack:@selector(requestFail:)];
        
        [httpRequest sendHttpRequestByPost:urlStr params:param];
    } else {//去登录界面
        [self showLoginView];
    }
}

#pragma mark ASIHTTPRequestDelegate
//请求失败代理方法
-(void) requestFail:(NSString*) responseStr
{
    NSLog(@"login request fail error = %@", responseStr);
    [[MyAlerView sharedAler] ViewShow:@"网络异常，请稍后重试"];
}

-(void) collectFinish:(NSData*)responseData {
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if (responseInfo && ((NSString*)[responseInfo objectForKey:@"status"]).integerValue == 1) {
            [[MyAlerView sharedAler] ViewShow:@"收藏成功"];
        } else {
            [[MyAlerView sharedAler] ViewShow:@"服务器忙，请稍后再试"];
        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    
}

#pragma LoginSuccess delegate
-(void)loginSuccess:(UIView*)view{
    //继续收藏动作
    [self collectThisMaster];
    [self closeLoginView:nil];
    
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
