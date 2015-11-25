//
//  LoginView.m
//  QHC
//
//  Created by qhc2015 on 15/6/10.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "LoginView.h"
#import "LoadingView.h"
#import "MyAlerView.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "StatementViewController.h"

@implementation LoginView

@synthesize httpRequest;
@synthesize accountField;
@synthesize passwordField;
@synthesize checkCodeField;

@synthesize getCheckCodeBtn;
@synthesize timer;

+ (LoginView*)sharedLoginView:(CGRect)frame {
    static LoginView *sharedLoginView;
    @synchronized(self){
        if(nil == sharedLoginView){
            sharedLoginView = [[LoginView alloc] initWithFrame:frame];
        }
    }
    return sharedLoginView;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTag:LOGIN_VIEW_TAG];
        self.backgroundColor = [UIColor viewBackgroundColor];
        [self addTopTitleView];
        [self createLoginView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        [self addGestureRecognizer:tapGestureRecognizer];
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)hideKeyboard
{
    [self endEditing:YES];//关闭键盘
}

-(void)showStatementInfo {
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    StatementViewController *statementViewCtr = [[StatementViewController alloc] init];
    [appDelegate.myRootController pushViewController:statementViewCtr animated:YES];
}

//添加顶部标题视图
-(void)addTopTitleView {
    UIView *titleView = [AppDelegate createTopTitleView];
    ((UITextView*)[titleView viewWithTag:TITLE]).text = @"登  录";
    [self addSubview:titleView];
}

//设置输入框边框
-(void) setTextFieldBorder:(UITextField*)textField{
    textField.layer.cornerRadius = 6.0f;
    textField.layer.masksToBounds = YES;
    textField.layer.borderColor = [[UIColor grayColor] CGColor];
    textField.layer.borderWidth = 1.0f;
}
//创建登陆界面
-(void)createLoginView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, TOP_VIEW_H + 10, self.frame.size.width, self.frame.size.height - (TOP_VIEW_H+10))];
    [self addSubview:contentView];
    
    UILabel *labelNotice = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, self.frame.size.width - 30, 15)];
    labelNotice.font = [UIFont systemFontOfSize:12];
    labelNotice.text = @"免注册，验证手机，马上进入";
    labelNotice.textColor = [UIColor grayColor];
    labelNotice.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:labelNotice];
    
    float textFieldHeight = 36;
    
    self.accountField = [[UITextField alloc] initWithFrame:CGRectMake(15, labelNotice.frame.origin.y + labelNotice.frame.size.height + 20, self.frame.size.width - 30, textFieldHeight)];
    accountField.placeholder = @"手机号";
    accountField.backgroundColor = [UIColor whiteColor];
    accountField.delegate = self;
    accountField.layer.cornerRadius = 4;
    [contentView addSubview:accountField];
    
    
//    self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(10, 55, self.frame.size.width - 125, textFieldHeight)];
//    [self setTextFieldBorder:passwordField];
//    passwordField.secureTextEntry = YES;
//    passwordField.delegate = self;
//    [contentView addSubview:passwordField];
    
    
    self.checkCodeField = [[UITextField alloc] initWithFrame:CGRectMake(15, accountField.frame.origin.y + accountField.frame.size.height + 15, self.frame.size.width - 160, textFieldHeight)];
    checkCodeField.delegate = self;
    checkCodeField.placeholder = @"验证码";
    checkCodeField.backgroundColor = [UIColor whiteColor];
    checkCodeField.layer.cornerRadius = 4;
    [contentView addSubview:checkCodeField];
    
    float codebtn_x = checkCodeField.frame.origin.x + checkCodeField.frame.size.width + 5;
    self.getCheckCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(codebtn_x, checkCodeField.frame.origin.y, self.frame.size.width - codebtn_x - 15, textFieldHeight)];
    [getCheckCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    getCheckCodeBtn.titleLabel.font = BUTTON_TEXT_FONT;
    getCheckCodeBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [getCheckCodeBtn.titleLabel setNumberOfLines:0];
    getCheckCodeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    getCheckCodeBtn.backgroundColor = [UIColor titleBarBackgroundColor];
    getCheckCodeBtn.layer.cornerRadius = 4;
    [getCheckCodeBtn addTarget:self action:@selector(getCheckCode:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:getCheckCodeBtn];
    
    UIButton *loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, getCheckCodeBtn.frame.origin.y + getCheckCodeBtn.frame.size.height + 30, self.frame.size.width - 30, 35)];
    [loginBtn setTitle:@"登    录" forState:UIControlStateNormal];
    loginBtn.backgroundColor = [UIColor titleBarBackgroundColor];
    [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.layer.cornerRadius = 4;
    [contentView addSubview:loginBtn];
    
    UILabel *notice = [[UILabel alloc] initWithFrame:CGRectMake(10, loginBtn.frame.origin.y + loginBtn.frame.size.height + 18, self.frame.size.width - 20, 20)];
    notice.textColor = [UIColor redColor];
    notice.font = [UIFont systemFontOfSize:12];
    notice.textAlignment = NSTextAlignmentCenter;
    notice.text = @"点击“登录”，表示您同意《青花瓷免责声明》";
    //设置自动行数与字符换行
    [notice setNumberOfLines:0];
    notice.lineBreakMode = NSLineBreakByWordWrapping;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showStatementInfo)];
    [notice addGestureRecognizer:tapGestureRecognizer];
    notice.userInteractionEnabled = YES;
    [contentView addSubview:notice];
}

-(void) startCountDown:(NSTimer*)timer
{
    int time = [self.getCheckCodeBtn.titleLabel.text intValue];
    time -= 1;
    if (time > 0) {
        [self.getCheckCodeBtn setTitle:[NSString stringWithFormat:@"%d", time] forState:UIControlStateNormal];
    } else {
        [self.timer invalidate];
        self.timer = nil;
        [self.getCheckCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.getCheckCodeBtn.userInteractionEnabled = YES;
        self.getCheckCodeBtn.backgroundColor = [UIColor titleBarBackgroundColor];
    }
}

-(void)getCheckCode:(id)sender{
    NSString *accountStr = self.accountField.text;
    if (!accountStr || [accountStr isEqualToString:@""]) {
        [[MyAlerView sharedAler] ViewShow:@"手机号不能为空，请重新输入！"];
        return;
    }
    if (![self checkPhoneNum:accountStr]) {
        [[MyAlerView sharedAler] ViewShow:@"您输入的手机号不合法，请输入正确有效的手机号，它将是您找回密码的唯一途径！"];
        return;
    }
    
    self.getCheckCodeBtn.userInteractionEnabled = NO;
    [self.getCheckCodeBtn setTitle:@"120" forState:UIControlStateNormal];
    self.getCheckCodeBtn.backgroundColor = RGBA(180, 180, 180, 255);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startCountDown:) userInfo:nil repeats:YES];
    
    //创建异步请求
    NSString *urlStr = @"SendSMS/VerificationCode.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:accountStr forKey:@"userid"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestCheckCode:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//登陆接口 也是注册接口，如果该用户没有注册过，那么就直接注册好并登陆
-(void)login {
    NSString *accountStr = self.accountField.text;
    NSString *checkCode = self.checkCodeField.text;
    if (!accountStr || [accountStr isEqualToString:@""]) {
        [[MyAlerView sharedAler] ViewShow:@"账号不能为空，请重新输入！"];
        return;
    }
    if (![self checkPhoneNum:accountStr]) {
        [[MyAlerView sharedAler] ViewShow:@"您输入的账号不合法，请输入正确有效的手机号，它将是您找回密码的唯一途径！"];
        return;
    }
//    if (!passwordStr || [passwordStr isEqualToString:@""]) {
//        [[MyAlerView sharedAler] ViewShow:@"密码不能为空，请重新输入！"];
//        return;
//    }
//    if (passwordStr.length < 6 || passwordStr.length > 16) {
//        [[MyAlerView sharedAler] ViewShow:@"密码长度应该在 6至16 个字符之间！"];
//        return;
//    }
    if (!checkCode || [checkCode isEqualToString:@""]) {
        [[MyAlerView sharedAler] ViewShow:@"请输入验证码！如果未收到验证码，请重新获取。"];
        return;
    }
    if (checkCode.length < 4) {
        [[MyAlerView sharedAler] ViewShow:@"请输入正确的验证码！"];
        return;
    }
    [self hideKeyboard];
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"UserAccount/Login.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:accountStr forKey:@"userid"];
    [param setObject:checkCode forKey:@"verifycode"];
//    [param setObject:@"testtest" forKey:@"username"];
    
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
        NSInteger status = [[responseInfo objectForKey:@"status"] integerValue];
        if (status == 1) {
            //清空用户本地缓存信息
            AppDelegate *appDelegate = APPDELEGATE;
            [appDelegate clearUserInfoCache];
            
            //存储用户信息
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:self.accountField.text forKey:@"account"];
            //            [userDefaults setObject:self.passwordField.text forKey:@"password"];
            [userDefaults setObject:[responseInfo objectForKey:@"username"] forKey:@"nickname"];
            [userDefaults setObject:[responseInfo objectForKey:@"userid"] forKey:@"userId"];
            [userDefaults setObject:[responseInfo objectForKey:@"img"] forKey:@"headImgUrl"];
            
            //预留服务器配置字段（是否显示退出登录按钮）
            NSString *logout = [responseInfo objectForKey:@"logout"];
            if (logout && (id)logout != [NSNull null]) {
                [userDefaults setObject:logout forKey:@"canLogout"];
            } else if([userDefaults objectForKey:@"canLogout"]) {
                [userDefaults removeObjectForKey:@"canLogout"];
            }
            
            
            NSMutableArray *userCacheKeys = [[NSMutableArray alloc] init];
            
            if ([responseInfo objectForKey:@"projectList"]) {
                NSArray *projectIdArray = [responseInfo objectForKey:@"projectList"];
                if (projectIdArray && projectIdArray.count > 0) {
                    for (NSDictionary *projectId in projectIdArray) {
                        [userDefaults setObject:[projectId objectForKey:@"orderid"] forKey:[projectId objectForKey:@"projectid"]];
                        [userCacheKeys addObject:[projectId objectForKey:@"projectid"]];
                    }
                }
            }
            if ([responseInfo objectForKey:NOT_RESERVATION]) {
                NSString *str = [responseInfo objectForKey:NOT_RESERVATION];
                if (str && (id)str != [NSNull null]) {
                    [userDefaults setObject:[responseInfo objectForKey:NOT_RESERVATION] forKey:NOT_RESERVATION];
                    [userCacheKeys addObject:NOT_RESERVATION];
                }
            }
            
            //缓存所有缓存的用户信息key
            if (userCacheKeys.count > 0) {
                [userDefaults setObject:userCacheKeys forKey:USER_CACHE_KEYS];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess:)]) {
                [self.delegate loginSuccess:self];
            }
        } else {
            NSString *errorMsg = [responseInfo objectForKey:@"error"];
            [[MyAlerView sharedAler] ViewShow:errorMsg];
        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}

-(void) requestCheckCode:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if ([responseInfo objectForKey:@"status"]) {
            NSInteger status = [[responseInfo objectForKey:@"status"] integerValue];
            if (status != 1) {
                NSString *errorMsg = [responseInfo objectForKey:@"error"];
                [[MyAlerView sharedAler] ViewShow:errorMsg];
            } else {
                [[MyAlerView sharedAler] ViewShow:@"验证码已发送，请注意查收"];
            }
        } else {
            NSString *errorMsg = [responseInfo objectForKey:@"error"];
            [[MyAlerView sharedAler] ViewShow:errorMsg];
        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
}

#pragma  mark textField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];//这句代码可以隐藏 键盘
    return NO;
}

#pragma my
-(BOOL) checkPhoneNum:(NSString*)phoneNumStr
{
    BOOL isPhoneNum = NO;
    if (phoneNumStr.length == 11 && [phoneNumStr characterAtIndex:0] == '1') {
        NSString *str = [phoneNumStr copy];
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        if (str.length <= 0) {
            isPhoneNum = YES;
        }
    }
    return isPhoneNum;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
