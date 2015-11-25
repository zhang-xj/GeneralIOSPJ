//
//  QHCBespeakDetailView.m
//  QHC
//
//  Created by qhc2015 on 15/6/30.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCBespeakDetailView.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "MyAlerView.h"
#import "JSONKit.h"
#import "LoadingView.h"

@implementation QHCBespeakDetailView

@synthesize detailDataDic;
@synthesize reservationid;
@synthesize myTableView;
@synthesize httpRequest;
@synthesize pingjiaTextView;
@synthesize bespeakInfoMutdic;
@synthesize bespeakDTArray;

-(id)initWithFrame:(CGRect)frame withData:(NSDictionary*)dataDic {
    self = [super initWithFrame:frame];
    if (self) {
        self.reservationid = [dataDic objectForKey:@"reservationid"];
        reservationStatus = ((NSString*)[dataDic objectForKey:@"status"]).integerValue;
        self.bespeakInfoMutdic = [[NSMutableDictionary alloc] init];
        
        [self getTableData];
    }
    return self;
}

-(void)backAction {
    [((AppDelegate*)([UIApplication sharedApplication].delegate)).myRootController popViewControllerAnimated:YES];
}

//取消预约单
-(void)cannelYuYue:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          
                          initWithTitle:@"取消确认"
                          
                          message:@"亲，真的要删除这个预约单吗？"
                          
                          delegate: self
                          
                          cancelButtonTitle:@"不要"
                          
                          otherButtonTitles:@"是的",nil];
    
    [alert show]; //显示
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self changeYuYueStatus:@"0"];
    }
}

-(void) createFooterView {
    if (reservationStatus == CONFIRMED) {//等待进行的预约单
       UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, myTableView.frame.size.width, 50)];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 8, (footerView.frame.size.width-30)/2, 30)];
        button.backgroundColor = RGBA(167, 105, 159, 255);
        button.layer.cornerRadius = 4;
        button.titleLabel.font = BUTTON_TEXT_FONT;
        [button setTitle:@"删除该预约" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cannelYuYue:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:button];
        
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(button.frame.size.width +button.frame.origin.x + 10, 8, (footerView.frame.size.width-30)/2, 30)];
        button1.backgroundColor = RGBA(167, 105, 159, 255);
        button1.layer.cornerRadius = 4;
        [button1 setTitle:@"修改预约信息" forState:UIControlStateNormal];
        button1.titleLabel.font = BUTTON_TEXT_FONT;
        [button1 addTarget:self action:@selector(changeYuYueInfo:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:button1];
        
        self.myTableView.tableFooterView = footerView;
    } else {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, myTableView.frame.size.width, 200)];
        footerView.backgroundColor = [UIColor tableViewBackgroundColor];

        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 100)];
        [footerView addSubview:view];
            
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20, 65, 16)];
        label.text = @"服务评价";
        label.font = [UIFont systemFontOfSize:14];
        [view addSubview:label];
            
        UIView *startsView = [[UIView alloc]initWithFrame:CGRectMake(label.frame.size.width + label.frame.origin.x, 0.0, 200, 40)];
        [startsView setTag:666];
        [view addSubview:startsView];
        
        NSInteger commentlevel = ((NSString*)[self.detailDataDic objectForKey:@"commentlevel"]).integerValue;
        for (int j = 0; j < 5; j++) {
            UIImageView *starts = [[UIImageView alloc] initWithFrame:CGRectMake(j * 40, 16, 24, 24)];
            if (j == 0 || j < commentlevel) {
                [starts setImage:[UIImage imageNamed:@"stars.png"]];
            } else {
                [starts setImage:[UIImage imageNamed:@"starsGray.png"]];
            }
            [startsView addSubview:starts];
            NSString *str;
            if (j == 0) {
                str = @"很差";
            } else if (j == 1) {
                str = @"一般";
            } else if (j == 2) {
                str = @"满意";
            } else if (j == 3) {
                str = @"比较满意";
            } else if (j == 4) {
                str = @"非常满意";
            }
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(startsView.frame.origin.x +  starts.frame.origin.x, startsView.frame.origin.y + startsView.frame.size.height + 5, 35, 40)];
            label.font = [UIFont systemFontOfSize:13];
            label.numberOfLines = 0;
            label.text = str;
            [view addSubview:label];
        }
        
        UILabel *note = [[UILabel alloc] initWithFrame:CGRectMake(15, view.frame.origin.y + view.frame.size.height, view.frame.size.width - 30, 50)];
        note.backgroundColor = [UIColor viewBackgroundColor];
        note.numberOfLines = 0;
        if (reservationStatus == COMMENTED) {//已经评价了
            note.text = @"您已经完成评价，谢谢！";
        } else {
            note.text = @"您的评价是我们提升服务质量的最好动力，非常感谢您的点评，谢谢！";
        }
        
        note.font = [UIFont systemFontOfSize:13];
        [footerView addSubview:note];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, note.frame.origin.y + note.frame.size.height + 10, footerView.frame.size.width - 40, 28)];
        if (reservationStatus == COMMENTED) {//已经评价了
            button.backgroundColor = RGBA(180, 180, 180, 255);
            button.userInteractionEnabled = NO;
        } else {
            button.backgroundColor = RGBA(167, 105, 159, 255);
            [button addTarget:self action:@selector(commitPingJia:) forControlEvents:UIControlEventTouchUpInside];
            //添加单击响应事件
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
            [startsView addGestureRecognizer:tapGestureRecognizer];
            
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
            [startsView addGestureRecognizer:panGestureRecognizer];
        }
        button.layer.cornerRadius = 4;
        [button setTitle:@"确      定" forState:UIControlStateNormal];
        button.titleLabel.font = BUTTON_TEXT_FONT;
        
        [footerView addSubview:button];

        
        self.myTableView.tableFooterView = footerView;
    }
}
//单击事件响应方法
-(void)tapGestureRecognizerAction:(UITapGestureRecognizer*)topRecognizer {
    UIView *touchView = [self.myTableView.tableFooterView viewWithTag:666];
    CGPoint point = [topRecognizer locationInView:touchView];
    float x = point.x;
    NSInteger index = (NSInteger)(x / 40) + 1;
    NSLog(@"index = %lu", index);
    NSInteger allViewCount = [touchView subviews].count;
    for (int i = 0; i < allViewCount; i++) {
        UIImageView *imgView = (UIImageView*)[[touchView subviews] objectAtIndex:i];
        if (i < index) {
            [imgView setImage:[UIImage imageNamed:@"stars.png"]];
        } else {
            [imgView setImage:[UIImage imageNamed:@"starsGray.png"]];
        }
    }
    level = index;
}
//拖动手势事件响应方法
-(void)panGestureRecognizerAction:(UIPanGestureRecognizer *)panGestureRecognizer {
    UIView *touchView = [self.myTableView.tableFooterView viewWithTag:666];
    CGPoint point = [panGestureRecognizer locationInView:touchView];
    NSLog(@"x = %f, y= %f", point.x, point.y);
    float x = point.x;
    NSInteger index = (NSInteger)(x / 40) + 1;
    NSLog(@"index = %lu", index);
    NSInteger allViewCount = [touchView subviews].count;
    for (int i = 0; i < allViewCount; i++) {
        UIImageView *imgView = (UIImageView*)[[touchView subviews] objectAtIndex:i];
        if (i < index) {
            [imgView setImage:[UIImage imageNamed:@"stars.png"]];
        } else {
            [imgView setImage:[UIImage imageNamed:@"starsGray.png"]];
        }
    }
    level = index;
}

//提交评价
-(void)commitPingJia:(id)sender {
    //创建异步请求
    NSString *urlStr = @"Comment/Append.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:self.reservationid forKey:@"reservationid"];
    [param setObject:[NSString stringWithFormat:@"%ld", (long)level] forKey:@"level"];
    [param setObject:@"" forKey:@"content"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestPingjiaFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//创建内容视图
-(void) createContentView{
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0.0, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.backgroundColor = [UIColor clearColor];
    [self addSubview:myTableView];
    
    [self createFooterView];
}

//修改预约信息
-(void)changeYuYueInfo:(id)sender {
    if (![self.bespeakInfoMutdic objectForKey:@"store"]) {
        [[MyAlerView sharedAler] ViewShow:@"请选择门店"];
        return;
    } else if(![self.bespeakInfoMutdic objectForKey:@"master"]) {
        [[MyAlerView sharedAler] ViewShow:@"请选择养生顾问"];
        return;
    } else if(![self.bespeakInfoMutdic objectForKey:@"besTime"]) {
        [[MyAlerView sharedAler] ViewShow:@"请选择预约时间"];
        return;
    }
    
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Reservation/Update.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:[self.detailDataDic objectForKey:@"reservationid"] forKey:@"reservationid"];
    [param setObject:@"1" forKey:@"number"];
    NSDictionary *storeDic = [self.bespeakInfoMutdic objectForKey:@"store"];
    [param setObject:[storeDic objectForKey:@"shopid"] forKey:@"shopid"];
    NSDictionary *masterDic = [self.bespeakInfoMutdic objectForKey:@"master"];
    [param setObject:[masterDic objectForKey:@"salerid"] forKey:@"salerid"];
    NSString *dateTime = [((NSDictionary*)[self.bespeakInfoMutdic objectForKey:@"besTime"]) objectForKey:@"commitStr"];
    NSArray *array = [dateTime componentsSeparatedByString:@"&"];
    [param setObject:[array objectAtIndex:0] forKey:@"date"];
    [param setObject:[array objectAtIndex:1] forKey:@"time"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestChangeBesInfoFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//获取预约单详情
-(void)getTableData {
    
    //创建异步请求
    NSString *urlStr = @"Reservation/Details.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:@"userId"];
    [param setObject:userId forKey:@"userid"];
    [param setObject:self.reservationid forKey:@"reservationid"];

    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//修改预约单状态
-(void)changeYuYueStatus:(NSString*)status {
    //创建异步请求
    NSString *urlStr = @"Reservation/UpdateStatus.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:@"userId"];
    [param setObject:userId forKey:@"userid"];
    [param setObject:self.reservationid forKey:@"reservationid"];
    [param setObject:status forKey:@"status"];
    
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestchangeYuYueStatusFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//获取养生顾问可预约时间列表
-(void)getBespeakDayTimeData:(NSString*)mastId {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Saler/Freetime.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:mastId forKey:@"salerid"];
    [param setObject:[self.detailDataDic objectForKey:@"projectid"] forKey:@"projectid"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(bespeakDTRequestFinish:)];
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
//修改预约单信息结果
-(void)requestChangeBesInfoFinish:(NSData*)responseData {
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if (responseInfo && ((NSString*)[responseInfo objectForKey:@"status"]).integerValue == 1) {
            [[MyAlerView sharedAler] ViewShow:@"修改成功"];
        } else {
            [[MyAlerView sharedAler] ViewShow:@"服务器忙，请稍候再试"];
        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    
    [[LoadingView sharedLoadingView] hidden];
}
//修改预约单信息结果
-(void)requestPingjiaFinish:(NSData*)responseData {
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if (responseInfo && ((NSString*)[responseInfo objectForKey:@"status"]).integerValue == 1) {
            [[MyAlerView sharedAler] ViewShow:@"感谢您的评价"];
            [self backAction];
        } else {
            [[MyAlerView sharedAler] ViewShow:@"服务器忙，请稍候再试"];
        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    
    [[LoadingView sharedLoadingView] hidden];
}
//获取预约单详情结果
-(void) requestFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        self.detailDataDic = responseInfo;
        if ([self.detailDataDic objectForKey:@"shopid"]) {
            NSDictionary *storeDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[self.detailDataDic objectForKey:@"shopid"], [self.detailDataDic objectForKey:@"shopname"], nil] forKeys:[NSArray arrayWithObjects:@"shopid", @"name", nil]];
            [self.bespeakInfoMutdic setObject:storeDic forKey:@"store"];
        }
        if ([self.detailDataDic objectForKey:@"salerid"]) {
            NSDictionary *masterDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[self.detailDataDic objectForKey:@"salerid"], [self.detailDataDic objectForKey:@"salername"], nil] forKeys:[NSArray arrayWithObjects:@"salerid", @"name", nil]];
            [self.bespeakInfoMutdic setObject:masterDic forKey:@"master"];
        }
        if ([self.detailDataDic objectForKey:@"reservationday"] && [self.detailDataDic objectForKey:@"reservationtime"]) {
            NSString *dateStr = [self.detailDataDic objectForKey:@"reservationday"];
            NSArray *dateArray = [dateStr componentsSeparatedByString:@"-"];
            
            NSString *commitStr = [NSString stringWithFormat:@"%@&%@", dateStr, [self.detailDataDic objectForKey:@"reservationtime"]];
            
            NSDictionary *besDic = nil;
            if (dateArray.count >= 3) {
                NSString *showStr = [NSString stringWithFormat:@"%@年%@月%@日  %@", [dateArray objectAtIndex:0], [dateArray objectAtIndex:1], [dateArray objectAtIndex:2], [self.detailDataDic objectForKey:@"reservationtime"]];
                besDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:showStr, commitStr, nil] forKeys:[NSArray arrayWithObjects:@"showStr", @"commitStr", nil]];
            } else {
                NSString *showStr = [NSString stringWithFormat:@"%@  %@", dateStr, [self.detailDataDic objectForKey:@"reservationtime"]];
                besDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:showStr, commitStr, nil] forKeys:[NSArray arrayWithObjects:@"showStr", @"commitStr", nil]];
            }
            [self.bespeakInfoMutdic setObject:besDic forKey:@"besTime"];
        }
        [self createContentView];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}
//修改预约单状态结果
-(void) requestchangeYuYueStatusFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if (((NSString*)[responseInfo objectForKey:@"status"]).integerValue == 1) {//如果是1，说明修改成功
            [[MyAlerView sharedAler] ViewShow:@"取消成功"];
            [self backAction];
        } else {
            [[MyAlerView sharedAler] ViewShow:@"服务器忙，请稍后再试"];
        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    
    [[LoadingView sharedLoadingView] hidden];
}
//获取养生顾问可预约时间结果
-(void) bespeakDTRequestFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        self.bespeakDTArray = [responseInfo objectForKey:@"daylist"];
        BespeakTimeSelectView *selectView = [[BespeakTimeSelectView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height) andData:self.bespeakDTArray];
        [self addSubview:selectView];
        [self bringSubviewToFront:selectView];
        selectView.delegate = self;
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}

#pragma mark QHCStoreListViewControllerDelegate
-(void)selectedStoreInfo:(NSDictionary *)storeInfoDic {
    if (nil == self.bespeakInfoMutdic) {
        self.bespeakInfoMutdic = [[NSMutableDictionary alloc] init];
    } else {
        [self.bespeakInfoMutdic removeAllObjects];//重新选择门店后需要重新选择养生顾问和时间
    }
    [bespeakInfoMutdic setObject:storeInfoDic forKey:@"store"];
    [self.myTableView reloadData];
}

#pragma mark MasterListViewControllerDelegate
-(void)selectedMasterInfo:(NSDictionary*)masterInfoDic {
    [self.bespeakInfoMutdic removeObjectForKey:@"besTime"];//重新选择养生顾问后需要重新选择时间
    [self.bespeakInfoMutdic setObject:masterInfoDic forKey:@"master"];
    [self.myTableView reloadData];
}

#pragma mark BespeakTimeSelectViewDelegate
-(void)selected:(NSUInteger)dayIndex timeId:(NSUInteger)timeIndex {
    NSDictionary *dateTimeDic = [self.bespeakDTArray objectAtIndex:dayIndex];
    NSString *dateStr = [dateTimeDic objectForKey:@"date"];
    NSArray *timeArray =[dateTimeDic objectForKey:@"freelist"];
    NSArray *dateArray = [dateStr componentsSeparatedByString:@"-"];
    
    NSString *commitStr = [NSString stringWithFormat:@"%@&%@", dateStr, [timeArray objectAtIndex:timeIndex]];
    
    NSDictionary *besDic = nil;
    if (dateArray.count >= 3) {
        NSString *showStr = [NSString stringWithFormat:@"%@年%@月%@日  %@", [dateArray objectAtIndex:0], [dateArray objectAtIndex:1], [dateArray objectAtIndex:2], [timeArray objectAtIndex:timeIndex]];
        besDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:showStr, commitStr, nil] forKeys:[NSArray arrayWithObjects:@"showStr", @"commitStr", nil]];
    } else {
        NSString *showStr = [NSString stringWithFormat:@"%@  %@", dateStr, [timeArray objectAtIndex:timeIndex]];
        besDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:showStr, commitStr, nil] forKeys:[NSArray arrayWithObjects:@"showStr", @"commitStr", nil]];
    }
    [self.bespeakInfoMutdic setObject:besDic forKey:@"besTime"];
    [self.myTableView reloadData];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma table dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (reservationStatus == CONFIRMED) {//养生顾问已确认
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * showUserInfoCellIdentifier = [NSString stringWithFormat:@"besOrderDetail%ld%lu", indexPath.section, [indexPath indexAtPosition:1]];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];
    NSInteger baseViewTag = (100 + 10 * indexPath.section) + [indexPath indexAtPosition:1];
    float leftPading = 10;
    if (cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];
        if (indexPath.section == 0) {
            if ([indexPath indexAtPosition:1] == 0) {
                //养生顾问信息
                UILabel *label = [[UILabel  alloc] initWithFrame:CGRectMake(leftPading, 11, tableView.frame.size.width - 2*leftPading, 16)];
                [label setTag:baseViewTag];
                label.font = [UIFont systemFontOfSize:15];
                [cell addSubview:label];
            } else if ([indexPath indexAtPosition:1] == 1) {
                //预约单号
                UILabel *labelOrderNO = [[UILabel alloc] initWithFrame:CGRectMake(leftPading, 8, tableView.frame.size.width - 60, 15)];
                [labelOrderNO setTag:baseViewTag+6];
                labelOrderNO.textColor = [UIColor grayColor];
                labelOrderNO.font = LABEL_DEFAULT_TEXT_FONT;
                [cell addSubview:labelOrderNO];
                
                //项目头像
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(leftPading, labelOrderNO.frame.origin.y + labelOrderNO.frame.size.height + 12, 80, 80)];
                [imgView setTag:baseViewTag];
                [cell addSubview:imgView];
                //项目名称
                UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 6, imgView.frame.origin.y - 6, tableView.frame.size.width - (imgView.frame.origin.x + imgView.frame.size.width + 6 + leftPading), 16)];
                labelName.font = [UIFont boldSystemFontOfSize:15];
                [labelName setTag:baseViewTag+1];
                [cell addSubview:labelName];
                //分割线
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelName.frame.origin.y + labelName.frame.size.height + 5, labelName.frame.size.width, 1)];
                line.backgroundColor = RGBA(230, 230, 230, 255);
                [cell addSubview:line];
                //此预约状态
                UILabel *labelStatus = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, line.frame.origin.y + 5, labelName.frame.size.width, 15)];
                labelStatus.font = [UIFont systemFontOfSize:14];
                [labelStatus setTag:baseViewTag+2];
                labelStatus.textColor = [UIColor priceTextColor];
                [cell addSubview:labelStatus];
                //分割线
                line = [[UIView alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelStatus.frame.origin.y + labelStatus.frame.size.height + 5, labelName.frame.size.width, 1)];
                line.backgroundColor = RGBA(230, 230, 230, 255);
                [cell addSubview:line];
                //预约时间
                UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, line.frame.origin.y + 5, labelName.frame.size.width, 15)];
                labelTime.font = [UIFont systemFontOfSize:14];
                [labelTime setTag:baseViewTag+3];
                [cell addSubview:labelTime];
                //服务门店
                UILabel *labelStore = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelTime.frame.origin.y + labelTime.frame.size.height + 3, labelName.frame.size.width, 15)];
                labelStore.font = [UIFont systemFontOfSize:14];
                [labelStore setTag:baseViewTag+4];
                [cell addSubview:labelStore];
                //门店电话
                UILabel *labelPhone = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelStore.frame.origin.y + labelStore.frame.size.height + 3, labelName.frame.size.width, 15)];
                labelPhone.font = [UIFont systemFontOfSize:13];
                [labelPhone setTag:baseViewTag+5];
                [cell addSubview:labelPhone];
            } else if([indexPath indexAtPosition:1] == 2) {
                //门店地址
                UILabel *labelAddr = [[UILabel  alloc] initWithFrame:CGRectMake(leftPading, 11.5, tableView.frame.size.width - 2*leftPading, 15)];
                [labelAddr setTag:baseViewTag];
                labelAddr.numberOfLines = 0;
                labelAddr.font = [UIFont systemFontOfSize:14];
                [cell addSubview:labelAddr];
            }
        } else {//这个是预约信息项
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(leftPading, 9, 20.5, 19.5)];
            [imgView setTag:baseViewTag+1];
            [cell addSubview:imgView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 8, 10, tableView.frame.size.width - leftPading*2, 18)];
            [cell addSubview:label];
            [label setTag:baseViewTag];
            label.textColor = LABEL_TITLE_TEXT_COLOR;
            label.font = [UIFont systemFontOfSize:15];
        }

    }
    
    cell.backgroundColor = [UIColor tableViewBackgroundColor];
    cell.userInteractionEnabled = NO;
    
    if (self.detailDataDic) {
        if (indexPath.section == 0) {
            if ([indexPath indexAtPosition:1] == 0) {
                //养生顾问信息
                UILabel *label = (UILabel*)[cell viewWithTag:baseViewTag];
                label.text = [NSString stringWithFormat:@"养生顾问：青花瓷－%@-%@", [self.detailDataDic objectForKey:@"shopname"],[self.detailDataDic objectForKey:@"salername"]];
            } else if ([indexPath indexAtPosition:1] == 1) {
                //预约单号
                UILabel *labelOrderNO = (UILabel*)[cell viewWithTag:baseViewTag+6];
                labelOrderNO.text = [NSString stringWithFormat:@"预约单号：%@", [self.detailDataDic objectForKey:@"reservationid"]];
                
                //项目头像
                UIImageView *imgView = (UIImageView*)[cell viewWithTag:baseViewTag];
                [imgView sd_setImageWithURL:[NSURL URLWithString:[self.detailDataDic objectForKey:@"img"]] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
                //项目名称
                UILabel *labelName = (UILabel*)[cell viewWithTag:baseViewTag+1];
                labelName.text = [self.detailDataDic objectForKey:@"projectname"];
                //此预约状态
                UILabel *labelStatus = (UILabel*)[cell viewWithTag:baseViewTag+2];
                NSString *statusStr = @"";
                if(reservationStatus == CANCEL){//预约已取消
                    statusStr = @"您已取消了该预约";
                } else if (reservationStatus == WAIT_CONFIRM) {//等待养生顾问确认
                    statusStr = @"等待养生顾问确认";
                } else if (reservationStatus == CONFIRMED) {//养生顾问已确认
                    statusStr = @"敬请您的到来哦";
                } else if (reservationStatus == WAIT_COMMENT) {//已经使用了 但还没评价
                    statusStr = @"等待您的评价";
                } else if (reservationStatus == COMMENTED) {//已经评价了
                    statusStr = @"您已评价了该服务";
                }
                labelStatus.text = statusStr;
                //预约时间
                UILabel *labelTime = (UILabel*)[cell viewWithTag:baseViewTag+3];
                labelTime.text = [NSString stringWithFormat:@"预约时间：%@  %@", [self.detailDataDic objectForKey:@"reservationday"], [self.detailDataDic objectForKey:@"reservationtime"]];
                //服务门店
                UILabel *labelStore = (UILabel*)[cell viewWithTag:baseViewTag+4];
                labelStore.text = [NSString stringWithFormat:@"服务门店：%@", [self.detailDataDic objectForKey:@"shopname"]];
                //门店电话
                UILabel *labelPhone = (UILabel*)[cell viewWithTag:baseViewTag+5];
                labelPhone.text = [NSString stringWithFormat:@"电话：%@", [self.detailDataDic objectForKey:@"phone"]];
            } else if([indexPath indexAtPosition:1] == 2) {
                //门店地址
                UILabel *labelAddr = (UILabel*)[cell viewWithTag:baseViewTag];
                NSString *addr = [NSString stringWithFormat:@"地址：%@", [self.detailDataDic objectForKey:@"address"]];
                CGSize size = [AppDelegate getStringInLabelSize:addr andFont:labelAddr.font andLabelWidth:labelAddr.frame.size.width];
                labelAddr.frame = CGRectMake(labelAddr.frame.origin.x, labelAddr.frame.origin.y, labelAddr.frame.size.width, size.height);
                labelAddr.text = addr;
            }
        } else {//这个是预约信息项
            cell.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//添加剪头
            
            UIImageView *imgView = (UIImageView*)[cell viewWithTag:baseViewTag+1];
            UILabel *label = (UILabel*)[cell viewWithTag:baseViewTag];
            if([indexPath indexAtPosition:1] == 0){
                [imgView setImage:[UIImage imageNamed:@"addr.png"]];
                //门店
                NSString *text = @"选择门店";
                if (self.bespeakInfoMutdic && [self.bespeakInfoMutdic objectForKey:@"store"]) {
                    NSDictionary *store = [self.bespeakInfoMutdic objectForKey:@"store"];
                    text = [store objectForKey:@"name"];
                }
                label.text = text;
            } else if([indexPath indexAtPosition:1] == 1){
                [imgView setImage:[UIImage imageNamed:@"master.png"]];
                //养生顾问
                NSString *text = @"选择养生顾问";
                NSDictionary *masterDic = [self.bespeakInfoMutdic objectForKey:@"master"];
                if (masterDic) {
                    text = [masterDic objectForKey:@"name"];
                }
                label.text = text;
            } else if([indexPath indexAtPosition:1] == 2){
                [imgView setImage:[UIImage imageNamed:@"time.png"]];
                //日期 时间
                NSString *text = @"预约时间";
                NSDictionary *d_tDic = [self.bespeakInfoMutdic objectForKey:@"besTime"];
                if (d_tDic) {
                    text = [NSString stringWithFormat:@"%@", [d_tDic objectForKey:@"showStr"]];
                }
                label.text = text;
            }
        }
    }
    
    return cell;
}

#pragma table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{//修改group之间的间距
    if (section == 0) {
        return 0.1;
    }
    return 5.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{//修改group之间的间距
    return 5.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//点击后恢复原有背景状态
    if (indexPath.section == 1) {
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if ([indexPath indexAtPosition:1] == 0) {//选择门店
            NSDictionary *storeDic = nil;
            if (self.bespeakInfoMutdic && [self.bespeakInfoMutdic objectForKey:@"store"]) {
                storeDic = [self.bespeakInfoMutdic objectForKey:@"store"];
            }
            QHCStoreListViewController *slvController = [[QHCStoreListViewController alloc] initWithProperty:storeDic isSelectedView:YES];
            slvController.delegate = self;
            [appDelegate.myRootController pushViewController:slvController animated:YES];
        } else if ([indexPath indexAtPosition:1] == 1) {//选择养生顾问
            NSDictionary *storeDic = [self.bespeakInfoMutdic objectForKey:@"store"];
            NSDictionary *masterDic = [self.bespeakInfoMutdic objectForKey:@"master"];
            MasterListViewController *mtController = [[MasterListViewController alloc] initWithProperty:masterDic storeID:[storeDic objectForKey:@"shopid"]  isSelectedView:YES];
            mtController.delegate = self;
            [appDelegate.myRootController pushViewController:mtController animated:YES];
        } else if ([indexPath indexAtPosition:1] == 2) {//选择时间
            NSDictionary *masterDic = [self.bespeakInfoMutdic objectForKey:@"master"];
            [self getBespeakDayTimeData:[masterDic objectForKey:@"salerid"]];
        }
    }
}
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
    if (indexPath.section == 0) {
        if ([indexPath indexAtPosition:1] == 1) {
            return 145;
        } else if ([indexPath indexAtPosition:1] == 2) {
            NSString *addr = [NSString stringWithFormat:@"地址：%@", [self.detailDataDic objectForKey:@"address"]];
            CGSize size = [AppDelegate getStringInLabelSize:addr andFont:[UIFont systemFontOfSize:13] andLabelWidth:tableView.frame.size.width - 20];
            return size.height + 20;
        }
    }
    return 38;
}

@end
