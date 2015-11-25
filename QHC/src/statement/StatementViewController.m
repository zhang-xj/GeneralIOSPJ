//
//  StatementViewController.m
//  QHC
//
//  Created by qhc2015 on 15/8/8.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "StatementViewController.h"
#import "AppDelegate.h"
#import "LoadingView.h"
#import "MyAlerView.h"
#import "JSONKit.h"

@interface StatementViewController ()
    
@end

@implementation StatementViewController

@synthesize contentScrollView;

@synthesize httpRequest;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor viewBackgroundColor];
    [self.view addSubview:[AppDelegate createStatusBackground]];
    
    UIView *contentView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [self.view addSubview:contentView];
    [self addTopTitleView:contentView];
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, CONTENT_OFFSET, contentView.frame.size.width, contentView.frame.size.height - CONTENT_OFFSET)];
    [contentView addSubview:contentScrollView];
    
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, contentScrollView.frame.size.width - 20, 20)];
    self.infoLabel.font = LABEL_DEFAULT_TEXT_FONT;
    self.infoLabel.textColor = LABEL_DEFAULT_TEXT_COLOR;
    self.infoLabel.numberOfLines = 0;
    [self.contentScrollView addSubview:self.infoLabel];
    
    [self getStatementData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backAction:(id)sender {
    [((AppDelegate*)([UIApplication sharedApplication].delegate)).myRootController popViewControllerAnimated:YES];
}

//添加顶部标题视图
-(void)addTopTitleView:(UIView*)superView{
    UIView *titleView = [AppDelegate createTopTitleView];
    ((UITextView*)[titleView viewWithTag:TITLE]).text = @"免责声明";
    UIButton *leftButton = (UIButton*)[titleView viewWithTag:LEFT_BUTTON];
    leftButton.hidden = NO;
    [leftButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [superView addSubview:titleView];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getStatementData {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSString *urlStr = @"UserAccount/Disclaimer.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

#pragma mark ASIHTTPRequestDelegate
//请求失败代理方法
-(void) requestFail:(NSString*) responseStr
{
    [[LoadingView sharedLoadingView] hidden];
    NSLog(@"login request fail error = %@", responseStr);
    [[MyAlerView sharedAler] ViewShow:@"网络异常，请稍后重试"];
}

-(void) requestFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        NSString *statementStr = [responseInfo objectForKey:@"disclaimer"];
        CGSize size = [AppDelegate getStringInLabelSize:statementStr andFont:self.infoLabel.font andLabelWidth:self.infoLabel.frame.size.width];
        self.infoLabel.frame = CGRectMake(self.infoLabel.frame.origin.x, self.infoLabel.frame.origin.y, self.infoLabel.frame.size.width, size.height);
        self.infoLabel.text = statementStr;
        [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, self.infoLabel.frame.size.height + 20)];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    
    [[LoadingView sharedLoadingView] hidden];
}

@end
