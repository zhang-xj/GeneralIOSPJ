//
//  UserFeedbackView.m
//  QHC
//
//  Created by qhc2015 on 15/7/2.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "UserFeedbackView.h"
#import "AppDelegate.h"
#import "LoadingView.h"
#import "MyAlerView.h"
#import "JSONKit.h"

@implementation UserFeedbackView

@synthesize feedback;
@synthesize httpRequest;
@synthesize feedbackType;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createContentView];
    }
    return self;
}

-(void)hideKeyboard
{
    [self endEditing:YES];//关闭键盘
}

-(void)createContentView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:contentView];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [contentView addGestureRecognizer:tapGestureRecognizer];
    
    UILabel *note = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, contentView.frame.size.width - 20.0, 20.0)];
    note.font = [UIFont systemFontOfSize:14];
    note.text = @"您的意见是我们最珍贵的财富！";
    [contentView addSubview:note];
    
    self.feedback = [[UITextView alloc] initWithFrame:CGRectMake(10.0, note.frame.origin.y + note.frame.size.height + 10.0, contentView.frame.size.width - 20.0, 120)];
    feedback.backgroundColor = [UIColor textFieldBackgroundColor];
    feedback.layer.cornerRadius = 8;
//    feedback.delegate = self;
    [contentView addSubview:feedback];
    
    UIButton *feedbackType1 = [[UIButton alloc] initWithFrame:CGRectMake(60.0, feedback.frame.origin.y + feedback.frame.size.height + 10.0, 80, 38)];
    [feedbackType1 setTitle:@"  投诉" forState:UIControlStateNormal];
    [feedbackType1 setImage:[UIImage imageNamed:@"unCheck.png"] forState:UIControlStateNormal];
    [feedbackType1 setTag:10086];
    [feedbackType1 addTarget:self action:@selector(feedbackTyepAction:) forControlEvents:UIControlEventTouchUpInside];
//    feedbackType1.titleLabel.font = [UIFont systemFontOfSize:13];
    [feedbackType1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [contentView addSubview:feedbackType1];
    
    UIButton *feedbackType2 = [[UIButton alloc] initWithFrame:CGRectMake(190.0, feedback.frame.origin.y + feedback.frame.size.height + 10.0, 80, 38)];
    [feedbackType2 setTitle:@"  反馈" forState:UIControlStateNormal];
    [feedbackType2 setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
    self.feedbackType = @"2";
//    feedbackType2.titleLabel.font = [UIFont systemFontOfSize:13];
    [feedbackType2 setTag:100861];
    [feedbackType2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [feedbackType2 addTarget:self action:@selector(feedbackTyepAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:feedbackType2];
    
    UIButton *feedbackBtn = [[UIButton alloc] initWithFrame:CGRectMake(10.0, feedbackType1.frame.origin.y + feedbackType1.frame.size.height + 10.0, contentView.frame.size.width - 20.0, 38)];
    [feedbackBtn setTitle:@"发送" forState:UIControlStateNormal];
    [feedbackBtn setTitleColor:[UIColor buttonTitleColor_1] forState:UIControlStateNormal];
    [feedbackBtn setBackgroundColor:[UIColor buttonBackgroundColor_1]];
    feedbackBtn.layer.cornerRadius = 6;
    [feedbackBtn addTarget:self action:@selector(feedbackAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:feedbackBtn];
}

//
-(void)feedbackTyepAction:(id)sender {
    UIButton *btn = (UIButton*)sender;
    [btn setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
    if (btn.tag == 10086) {//投诉
        self.feedbackType = @"1";
        btn = (UIButton*)[self viewWithTag:100861];
        [btn setImage:[UIImage imageNamed:@"unCheck.png"] forState:UIControlStateNormal];
    } else if (btn.tag == 100861) {//意见反馈
        self.feedbackType = @"2";
        btn = (UIButton*)[self viewWithTag:10086];
        [btn setImage:[UIImage imageNamed:@"unCheck.png"] forState:UIControlStateNormal];
    }
}

//提交意见反馈信息
-(void)feedbackAction:(id)sender {
    [[LoadingView sharedLoadingView] show];
    
    //创建异步请求
    NSString *urlStr = @"UserAccount/AppendFeedback.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[userdf objectForKey:@"userId"] forKey:@"userid"];
    [param setObject:self.feedback.text forKey:@"content"];
    [param setObject:feedbackType forKey:@"type"];//1:投诉 2:意见反馈
    
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
    [[LoadingView sharedLoadingView] hidden];
    if (resultCode == 1) {//成功
        if (((NSString*)[responseInfo objectForKey:@"status"]).integerValue == 1) {
            [[MyAlerView sharedAler] ViewShow:@"谢谢您的宝贵意见"];
            self.feedback.text = @"";
        } else {

        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }

}

#pragma  mark textField Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];//这句代码可以隐藏 键盘
        return NO;
    }
    
    return YES;
}
@end
