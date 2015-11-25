//
//  OrderFormView.m
//  QHC
//
//  Created by qhc2015 on 15/7/14.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "OrderFormDetailView.h"
#import "LoadingView.h"
#import "MyAlerView.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "WXPay.h"

@implementation OrderFormDetailView

@synthesize orderID;

@synthesize orderInfoDic;

@synthesize myTableView;
@synthesize payWaySignArray;

@synthesize httpRequest;

@synthesize bespeakInfoMutdic;

@synthesize bespeakDTArray;

@synthesize payBtn;

@synthesize cannelBtn;

@synthesize besBtn;

-(id)initWithFrame:(CGRect)frame andOrderInfo:(NSDictionary*)orderDic {
    self = [super initWithFrame:frame];
    if (self) {
        self.orderID = [orderDic objectForKey:@"orderid"];
        orderStatus = ((NSString*)[orderDic objectForKey:@"status"]).integerValue;//订单状态 1:未支付 2:已支付
        self.payWaySignArray = [[NSMutableArray alloc] init];
        self.bespeakInfoMutdic = [[NSMutableDictionary alloc] init];
        
        if (orderStatus == 1) {//未支付
            self.payBtn = [[UIButton alloc] initWithFrame:CGRectMake(15.0, frame.size.height - 42, (frame.size.width - 40.0)/2, 34)];
            payBtn.backgroundColor = [UIColor titleBarBackgroundColor];
            payBtn.layer.cornerRadius = 4;
            [payBtn setTitle:@"去支付" forState:UIControlStateNormal];
            [payBtn addTarget:self action:@selector(payBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:payBtn];
            
            self.cannelBtn = [[UIButton alloc] initWithFrame:CGRectMake(payBtn.frame.origin.x + payBtn.frame.size.width + 10, frame.size.height - 42, (frame.size.width - 40.0)/2, 34)];
            cannelBtn.backgroundColor = [UIColor titleBarBackgroundColor];
            cannelBtn.layer.cornerRadius = 4;
            [cannelBtn setTitle:@"删除订单" forState:UIControlStateNormal];
            [cannelBtn addTarget:self action:@selector(cannelBntAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cannelBtn];
        } else if (orderStatus == 2 || orderStatus == 4){//已支付 已完成
            self.besBtn = [[UIButton alloc] initWithFrame:CGRectMake(15.0, frame.size.height - 42, frame.size.width - 40.0, 34)];
            besBtn.backgroundColor = [UIColor titleBarBackgroundColor];
            besBtn.layer.cornerRadius = 4;
            [besBtn setTitle:@"预约" forState:UIControlStateNormal];
            [besBtn addTarget:self action:@selector(besBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:besBtn];
//        } else if () {
//            
        }
        
        thisTimeAddBesOrderCount = 0;
        
        [self getOrderInfo];
        
        //微信支付结果回调
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        appDelegate.delegate = self;
    }
    return self;
}

-(void)createTableView {
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height - 40) style:UITableViewStyleGrouped];
    self.myTableView.backgroundColor = [UIColor clearColor];
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    [self addSubview:myTableView];
}

//去支付
-(void)payBtnAction:(id)sender {
    if (selectedPayWay == 0) {//微信支付
        [self buildWXPayOrderFrom];
    } else if (selectedPayWay == 1) {//支付宝客户端支付
        APPayOrder *pay = [[APPayOrder alloc] init];
        pay.delegate = self;
        [pay payWithProductInfo:self.orderInfoDic];
    }
}
//取消订单
-(void)cannelBntAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          
                          initWithTitle:@"取消确认"
                          
                          message:@"亲，真的要删除这个订单吗？"
                          
                          delegate: self
                          
                          cancelButtonTitle:@"不要"
                          
                          otherButtonTitles:@"是的",nil];
    
    [alert show]; //显示
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self cannelOrderStatus:@"0"];
    }
}

//提交预约信息  新增预约单
-(void)besBtnAction:(id)sender {
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
    NSString *urlStr = @"Reservation/Append.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:[self.orderInfoDic objectForKey:@"orderid"] forKey:@"orderid"];
    [param setObject:[self.orderInfoDic objectForKey:@"projectid"] forKey:@"projectid"];
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
    [httpRequest setRequestFinishCallBack:@selector(besOrderFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

#pragma mark APPayOrderDelegate
//支付宝支付结果回调
-(void)payResponse:(NSDictionary *)payResult {
    NSString *payResultStatus = [payResult objectForKey:@"resultStatus"];
    if (payResultStatus.integerValue == 9000) {
        [[MyAlerView sharedAler] ViewShow:@"支付成功"];
        self.payBtn.userInteractionEnabled = NO;
        [self.payBtn setTitle:@"已支付" forState:UIControlStateNormal];
        self.payBtn.backgroundColor = RGBA(180, 180, 180, 250);
        self.cannelBtn.userInteractionEnabled = NO;
        self.cannelBtn.backgroundColor = RGBA(180, 180, 180, 250);
        [self changeOrderStatus];
    } else {
        [[MyAlerView sharedAler] ViewShow:@"支付失败"];
    }
}
#pragma end

#pragma mark WXPayResultDelegate
-(void)WXPayResult:(NSInteger)resultColde{
    //微信支付结果处理
    switch (resultColde) {
        case WXSuccess:
            [[MyAlerView sharedAler] ViewShow:@"支付成功"];
            self.payBtn.userInteractionEnabled = NO;
            [self.payBtn setTitle:@"已支付" forState:UIControlStateNormal];
            self.payBtn.backgroundColor = RGBA(180, 180, 180, 250);
            self.cannelBtn.userInteractionEnabled = NO;
            self.cannelBtn.backgroundColor = RGBA(180, 180, 180, 250);
            [self changeOrderStatus];
            break;
        default:
            [[MyAlerView sharedAler] ViewShow:@"支付失败"];
            break;
    }
}
#pragma end

//获取养生顾问可预约时间列表
-(void)getBespeakDayTimeData:(NSString*)mastId {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Saler/Freetime.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:mastId forKey:@"salerid"];
    [param setObject:[self.orderInfoDic objectForKey:@"projectid"] forKey:@"projectid"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(bespeakDTRequestFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//获取微信支付单信息
-(void)buildWXPayOrderFrom {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Pay/AppendWeiXinOrder.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:[self.orderInfoDic objectForKey:@"orderid"] forKey:@"orderid"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(getWXPayOrderFromFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//修改订单信息
-(void)updateOrderInfo:(NSString*)cardId {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Order/Update.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:[self.orderInfoDic objectForKey:@"orderid"] forKey:@"orderid"];
    if (cardId && cardId.length > 0) {
        [param setObject:cardId forKey:@"cardid"];
    }
    if ([self.bespeakInfoMutdic objectForKey:@"besTime"]) {
        NSDictionary *storeDic = [self.bespeakInfoMutdic objectForKey:@"store"];
        NSDictionary *masterDic = [self.bespeakInfoMutdic objectForKey:@"master"];
        NSString *dateTime = [((NSDictionary*)[self.bespeakInfoMutdic objectForKey:@"besTime"]) objectForKey:@"commitStr"];
        [param setObject:[storeDic objectForKey:@"shopid"] forKey:@"shopid"];
        [param setObject:[masterDic objectForKey:@"salerid"] forKey:@"salerid"];
        NSArray *array = [dateTime componentsSeparatedByString:@"&"];
        [param setObject:[array objectAtIndex:0] forKey:@"date"];
        [param setObject:[array objectAtIndex:1] forKey:@"time"];
    } else {
        [param setObject:@"" forKey:@"shopid"];
        [param setObject:@"" forKey:@"salerid"];
        [param setObject:@"" forKey:@"date"];
        [param setObject:@"" forKey:@"time"];
    }
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestUpdateOrderInfoFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//修改订单状态
-(void)changeOrderStatus {
    //    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Order/UpdateStatus.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:[self.orderInfoDic objectForKey:@"orderid"] forKey:@"orderid"];
    //    [param setObject:payType forKey:@"paytype"];
    [param setObject:@"10" forKey:@"status"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(changeOrderStatusFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//取消订单
-(void)cannelOrderStatus:(NSString*)status {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Order/UpdateStatus.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:[self.orderInfoDic objectForKey:@"orderid"] forKey:@"orderid"];
    [param setObject:@"" forKey:@"paytype"];
    [param setObject:status forKey:@"status"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(cannelOrderStatusFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//获取订单信息
-(void)getOrderInfo {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Order/Details.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *userId = [userDefaults objectForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    [param setObject:userId forKey:@"userid"];
    [param setObject:self.orderID forKey:@"orderid"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestOrderDerailFinish:)];
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

//获得养生顾问可预约时间结果
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

//获取订单详情结果
-(void) requestOrderDerailFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        
        self.orderInfoDic = responseInfo;
        NSString *stopidStr = [self.orderInfoDic objectForKey:@"shopid"];
        if (stopidStr && (id)stopidStr != [NSNull null] && stopidStr.length > 0) {
            NSDictionary *storeDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:stopidStr, [self.orderInfoDic objectForKey:@"shopname"], nil] forKeys:[NSArray arrayWithObjects:@"shopid", @"name", nil]];
            [self.bespeakInfoMutdic setObject:storeDic forKey:@"store"];
            
            NSString *masterIdStr = [self.orderInfoDic objectForKey:@"salerid"];
            if (masterIdStr && (id)masterIdStr != [NSNull null] && masterIdStr.length > 0) {
                NSDictionary *masterDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:masterIdStr, [self.orderInfoDic objectForKey:@"salername"], nil] forKeys:[NSArray arrayWithObjects:@"salerid", @"name", nil]];
                [self.bespeakInfoMutdic setObject:masterDic forKey:@"master"];
            }
        }
        
        [self createTableView];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}

//取消订单
-(void) cannelOrderStatusFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        [[MyAlerView sharedAler] ViewShow:@"取消成功"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults objectForKey:[self.orderInfoDic objectForKey:@"projectid"]]) {//如果取消的是首次体验订单
            NSString *orderid = [userDefaults objectForKey:[self.orderInfoDic objectForKey:@"projectid"]];
            if (orderid && [orderid isEqualToString:[self.orderInfoDic objectForKey:@"orderid"]]) {
                [userDefaults removeObjectForKey:[self.orderInfoDic objectForKey:@"projectid"]];
            }
            //同时将key删除
            NSMutableArray *userCacheKeys = [NSMutableArray arrayWithArray:[userDefaults objectForKey:USER_CACHE_KEYS]];
            [userCacheKeys removeObject:[self.orderInfoDic objectForKey:@"projectid"]];
            [userDefaults setObject:userCacheKeys forKey:USER_CACHE_KEYS];
        }
        [((AppDelegate*)([UIApplication sharedApplication].delegate)).myRootController popViewControllerAnimated:YES];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}

//修改订单状态结果
-(void) changeOrderStatusFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        
    } else {//服务器报错
        //        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        //        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}

//修改订单信息结果
-(void) requestUpdateOrderInfoFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        self.orderInfoDic = responseInfo;
        [self.myTableView reloadData];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}

//获取微信订单信息结果
-(void)getWXPayOrderFromFinish:(NSData*)responseData {
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        [[[WXPay alloc] init] sendPay:responseInfo];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}
//新增预约单结果
-(void) besOrderFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if (((NSString*)[responseInfo objectForKey:@"status"]).integerValue == 1) {
            [[MyAlerView sharedAler] ViewShow:@"预约成功"];
            [self.bespeakInfoMutdic removeObjectForKey:@"besTime"];
            thisTimeAddBesOrderCount ++;
            [self.myTableView reloadData];
        } else {
            [[MyAlerView sharedAler] ViewShow:@"服务器异常，请稍候再试"];
        }
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

#pragma mark MyCardPackageViewControllerDelegate
-(void) selectedCardPackageResult:(NSDictionary*)selectedCardDic {
    float cardPrice = ((NSString*)[selectedCardDic objectForKey:@"number"]).floatValue;
    float totalPrice = ((NSString*)[self.orderInfoDic objectForKey:@"total"]).floatValue;
    if (cardPrice >= totalPrice) {
        [[MyAlerView sharedAler] ViewShow:@"所选优惠券金额大于订单金额，请重新选择。"];
    } else {
        [self updateOrderInfo:[selectedCardDic objectForKey:@"cardid"]];
    }
}

#pragma table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{//修改group之间的间距
    if (section == 0) {
        return 0.1;
    } else {
        return 5.0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{//修改group之间的间距
    return 5.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//点击后恢复原有背景状态
    if (indexPath.section == 0 && [indexPath indexAtPosition:1] == 1) {//选择优惠券
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"yes", nil] forKeys:[NSArray arrayWithObjects:@"selected", nil]];
        MyCardPackageViewController *cardPKController = [[MyCardPackageViewController alloc] initWithProperty:dic];
        cardPKController.delegate = self;
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate.myRootController pushViewController:cardPKController animated:YES];
    } else if (indexPath.section == 1) {//选择预约信息
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if ([indexPath indexAtPosition:1] == 0) {//选择门店
            NSDictionary *storeDic = nil;
            if (self.bespeakInfoMutdic) {
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
    } else if (indexPath.section == 2) {//选择支付方式
        for (int i = 0; i < payWaySignArray.count; i++) {
            UIView *view = [payWaySignArray objectAtIndex:i];
            if ([indexPath indexAtPosition:1] == i) {
                view.hidden = NO;
                selectedPayWay = i;
            } else {
                view.hidden = YES;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
    if (indexPath.section == 0) {
        if ([indexPath indexAtPosition:1] == 0) {
            return 110;
        }
    } else if (indexPath.section == 1) {
        if ([indexPath indexAtPosition:1] == 3) {
            NSString *storeAddr = [self.orderInfoDic objectForKey:@"shopaddress"];
            NSString *textStr = [NSString stringWithFormat:@"门店地址：%@", storeAddr];
            CGSize lSize = [AppDelegate getStringInLabelSize:textStr andFont:[UIFont systemFontOfSize:15]  andLabelWidth:tableView.frame.size.width - 20];
            return lSize.height + 20;
        }
    } else if (indexPath.section == 2) {
        return 40;
    }
    return 38;
}

#pragma table dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (orderStatus == 1) {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if(section == 1){
        if ([self.bespeakInfoMutdic allKeys].count == 3) {
            return [bespeakInfoMutdic allKeys].count;
        }
        return [self.bespeakInfoMutdic allKeys].count + 1;
    } else if(section == 2){
        return 2;
    }
    return 2;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * showUserInfoCellIdentifier = [NSString stringWithFormat:@"masterDetailCell%ld%lu", (long)indexPath.section, (unsigned long)[indexPath indexAtPosition:1]] ;
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];
    
    NSInteger subViewTag = (indexPath.section + 3) * 100 + [indexPath indexAtPosition:1];
    if (cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];
        
        float l_r_padding = 10.0;
        float fontSize = 15.0;
        if (indexPath.section == 0) {
            if ([indexPath indexAtPosition:1] == 0)  {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(l_r_padding, 10, 70, 70)];
                [imgView setTag:subViewTag];
                [cell addSubview:imgView];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding + imgView.frame.size.width + 8, 12, tableView.frame.size.width - l_r_padding*2 - imgView.frame.size.width - 8, 18)];
                [cell addSubview:label];
                [label setTag:subViewTag+1];
                label.font = LABEL_TITLE_TEXT_FONT;
                
                UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y + label.frame.size.height + 8 , label.frame.size.width, 18)];
                [cell addSubview:label1];
                [label1 setTag:subViewTag+2];
                label1.textColor = [UIColor priceTextColor];
                label1.font = LABEL_DEFAULT_TEXT_FONT;

                UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(label1.frame.origin.x, label1.frame.origin.y + label1.frame.size.height + 8 , label1.frame.size.width, 18)];
                [cell addSubview:label3];
                [label3 setTag:subViewTag+4];
                label3.textColor = RGBA(180, 0, 190, 255);
                label3.font = LABEL_DEFAULT_TEXT_FONT;
                
                UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + 3, imgView.frame.origin.y + imgView.frame.size.height + 8 , tableView.frame.size.width - l_r_padding*2 - 8, 18)];
                [cell addSubview:label2];
                [label2 setTag:subViewTag+3];
                label2.textColor = LABEL_DEFAULT_TEXT_COLOR;
                label2.font = LABEL_DEFAULT_TEXT_FONT;
            } else if ([indexPath indexAtPosition:1] == 1) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding, 10, tableView.frame.size.width - l_r_padding*2, 18)];
                [cell addSubview:label];
                [label setTag:subViewTag];
                label.font = [UIFont systemFontOfSize:fontSize];
                
                UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding, 10, tableView.frame.size.width - l_r_padding*2 - 25, 18)];
                [cell addSubview:label1];
                label1.textAlignment = NSTextAlignmentRight;
                label1.textColor = [UIColor priceTextColor];
                [label1 setTag:subViewTag+1];
                label1.font = [UIFont systemFontOfSize:fontSize];
            } else if ([indexPath indexAtPosition:1] == 2) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding, 10, tableView.frame.size.width - l_r_padding*2, 18)];
                [cell addSubview:label];
                [label setTag:subViewTag];
                label.font = [UIFont systemFontOfSize:fontSize];
                
                UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding, 10, tableView.frame.size.width - l_r_padding*2 - 50, 18)];
                [cell addSubview:label1];
                label1.textAlignment = NSTextAlignmentRight;
                label1.textColor = [UIColor priceTextColor1];
                [label1 setTag:subViewTag+1];
                label1.font = [UIFont systemFontOfSize:fontSize];
                
                UIImageView *payTypeImg = [[UIImageView alloc] initWithFrame:CGRectMake(label1.frame.origin.x + label1.frame.size.width + 2, 7.5, 23, 23)];
                [payTypeImg setTag:subViewTag + 2];
                payTypeImg.hidden = YES;
                [cell addSubview:payTypeImg];
            }
        } else if (indexPath.section == 1) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(l_r_padding, 9, 20.5, 19.5)];
            [imgView setTag:subViewTag+1];
            [cell addSubview:imgView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 8, 10, tableView.frame.size.width - l_r_padding*2, 18)];
            [cell addSubview:label];
            [label setTag:subViewTag];
            label.textColor = LABEL_TITLE_TEXT_COLOR;
            label.font = [UIFont systemFontOfSize:15];
        } else if (indexPath.section == 2) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(l_r_padding, 5, 30, 30)];
            [imgView setTag:subViewTag];
            [cell addSubview:imgView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding + imgView.frame.size.width + 8, 11, tableView.frame.size.width - l_r_padding*2 - imgView.frame.size.width - 8, 18)];
            [cell addSubview:label];
            [label setTag:subViewTag+1];
            label.font = [UIFont systemFontOfSize:fontSize];
            
            UIImageView *selectedImg = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 45, 15, 15, 10)];
            [selectedImg setTag:subViewTag + 2];
            [cell addSubview:selectedImg];
            if ([indexPath indexAtPosition:1] != 0) {
                selectedImg.hidden = YES;
            }
            [self.payWaySignArray addObject:selectedImg];
        }
    }
    
    cell.userInteractionEnabled = NO;
    cell.backgroundColor = [UIColor tableViewBackgroundColor];
    
    if (indexPath.section == 0) {
        if ([indexPath indexAtPosition:1] == 0) {
            UIImageView *imgView = (UIImageView*)[cell viewWithTag:subViewTag];
            [imgView sd_setImageWithURL:[NSURL URLWithString:[self.orderInfoDic objectForKey:@"img"]] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
            
            UILabel *label = (UILabel*)[cell viewWithTag:subViewTag+1];
//            label.text = [NSString stringWithFormat:@"项目：%@", [self.orderInfoDic objectForKey:@"projectname"]];
            label.text = [self.orderInfoDic objectForKey:@"projectname"];
            
            UILabel *label1 = (UILabel*)[cell viewWithTag:subViewTag+2];
            if (self.orderInfoDic) {
                label1.text = [NSString stringWithFormat:@"价格：¥%.2f元/%@次", ((NSString*)[self.orderInfoDic objectForKey:@"total"]).floatValue, [self.orderInfoDic objectForKey:@"number"]];
            }
            
            UILabel *label2 = (UILabel*)[cell viewWithTag:subViewTag+3];
            if (self.orderInfoDic) {
                label2.text = [NSString stringWithFormat:@"订单号：%@", [self.orderInfoDic objectForKey:@"orderid"]];
            }
            
            //使用状态（如果是未支付 已取消状态 则直接显示状态信息）
            UILabel *payStatus = (UILabel*)[cell viewWithTag:subViewTag +4];
            //预约信息 包括上一次预约的门店 养生顾问 以及默认的写一次预约时间 如果未支付，则是需要支付的金额信息 如果是已取消订单 则不显示
            //        UILabel *labelBesInfo = (UILabel*)[cell viewWithTag:104];
            //一键预约按钮  如果是已取消订单 则不显示
            //        UIButton *button = (UIButton*)[cell viewWithTag:105];
            NSString *statusStr = (NSString*)[self.orderInfoDic objectForKey:@"status"];
            if (statusStr && (id)statusStr != [NSNull null]) {
                NSInteger status = [statusStr intValue];
                if (status == 2 || status == 4) {//已支付 或 所有服务已预约完成
                    NSInteger remaining = ((NSString*)[self.orderInfoDic objectForKey:@"remaining"]).integerValue;
                    NSInteger used = ((NSString*)[self.orderInfoDic objectForKey:@"number"]).integerValue - remaining;
                    NSString *str = (NSString*)[self.orderInfoDic objectForKey:@"reservationnumber"];
                    NSInteger reservationNumber = str.integerValue;
                    statusStr = [NSString stringWithFormat:@"服务完成%lu次,剩余:%lu次(已预约%ld次)", (long)used, (long)remaining, (long)reservationNumber + thisTimeAddBesOrderCount];
                    if (remaining <= reservationNumber + thisTimeAddBesOrderCount) {
                        self.besBtn.backgroundColor = RGBA(180, 180, 180, 255);
                        self.besBtn.userInteractionEnabled = NO;
                    }
                } else if (status == 1) {//未支付
                    statusStr = @"未支付";
                } else if (status == 4) {
                    statusStr = @"该订单所有服务已完成";
                    self.besBtn.backgroundColor = RGBA(180, 180, 180, 255);
                    self.besBtn.userInteractionEnabled = NO;
                }
                payStatus.text = statusStr;
            }
        } else if ([indexPath indexAtPosition:1] == 1) {
            NSString *statusStr = (NSString*)[self.orderInfoDic objectForKey:@"status"];
            if (statusStr && (id)statusStr != [NSNull null]) {
                NSInteger status = [statusStr intValue];
                if (status == 1) {//未支付
                    cell.userInteractionEnabled = YES;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//箭头
                }
            }

            UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
            label.text = @"优惠券：";
            
            UILabel *label1 = (UILabel*)[cell viewWithTag:subViewTag+1];
            if (self.orderInfoDic) {
                label1.text = [NSString stringWithFormat:@"¥%.2f元", ((NSString*)[self.orderInfoDic objectForKey:@"cardmoney"]).floatValue];
            }
        } else if ([indexPath indexAtPosition:1] == 2) {
            UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
            label.text = @"实付金额：";
            
            UILabel *label1 = (UILabel*)[cell viewWithTag:subViewTag+1];
            if (self.orderInfoDic) {
                label1.text = [NSString stringWithFormat:@"¥%.2f元", ((NSString*)[self.orderInfoDic objectForKey:@"realpay"]).floatValue];
            }
            
            UIImageView *payTypeImg = (UIImageView*)[cell viewWithTag:subViewTag+2];
            NSString *statusStr = (NSString*)[self.orderInfoDic objectForKey:@"status"];
            if (statusStr && (id)statusStr != [NSNull null]) {
                NSInteger status = [statusStr intValue];
                if (status == 2 || status == 4) {//已支付 已完成
                    NSInteger payType = ((NSString*)[self.orderInfoDic objectForKey:@"paytype"]).integerValue;
                    if (payType == 1) {//微信支付
                        [payTypeImg setImage:[UIImage imageNamed:@"payWay1.png"]];
                    } else {//支付宝支付
                        [payTypeImg setImage:[UIImage imageNamed:@"payWay2.png"]];
                    }
                    payTypeImg.hidden = NO;
                } else {
                    payTypeImg.hidden = YES;
                    CGRect rect = label1.frame;
                    rect.size.width += 25;
                    label1.frame = rect;
                }
            } else {
                payTypeImg.hidden = YES;
                CGRect rect = label1.frame;
                rect.size.width += 25;
                label1.frame = rect;
            }
        }
    } else if (indexPath.section == 1) {
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//添加剪头
        
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:subViewTag+1];
        UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
        
        if ([indexPath indexAtPosition:1] == 1) {
            [imgView setImage:[UIImage imageNamed:@"master.png"]];
            NSDictionary *masterDic = [self.bespeakInfoMutdic objectForKey:@"master"];
            if (masterDic) {
                label.text = [NSString stringWithFormat:@"预约养生顾问：%@", [masterDic objectForKey:@"name"]];
            } else {
                label.text = @"预约养生顾问：请选择";
            }
        } else if ([indexPath indexAtPosition:1] == 2) {
            [imgView setImage:[UIImage imageNamed:@"time.png"]];
            NSDictionary *besTime = [self.bespeakInfoMutdic objectForKey:@"besTime"];
            if (besTime) {
                label.text = [NSString stringWithFormat:@"预约时间：%@", [besTime objectForKey:@"showStr"]];
            } else {
                label.text = @"预约时间：请选择";
            }
        } else if ([indexPath indexAtPosition:1] == 0) {
            [imgView setImage:[UIImage imageNamed:@"addr.png"]];
            NSDictionary *store = [self.bespeakInfoMutdic objectForKey:@"store"];
            if (store) {
                label.text = [NSString stringWithFormat:@"预约门店：%@", [store objectForKey:@"name"]];
            } else {
                label.text = @"预约门店：请选择";
            }

        } else {
            label.numberOfLines = 0;
            NSString *storeAddr = [self.orderInfoDic objectForKey:@"shopaddress"];
            NSString *textStr = [NSString stringWithFormat:@"门店地址：%@", storeAddr];
            CGSize lSize = [AppDelegate getStringInLabelSize:textStr andFont:label.font  andLabelWidth:label.frame.size.width];
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, lSize.width, lSize.height);
            label.text = textStr;
        }
    } else if (indexPath.section == 2) {
        cell.userInteractionEnabled = YES;
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:subViewTag];
        if ([indexPath indexAtPosition:1] == 0) {
            [imgView setImage:[UIImage imageNamed:@"payWay1.png"]];
        } else {
            [imgView setImage:[UIImage imageNamed:@"payWay2.png"]];
        }

        
        UIImageView *selectedImg = (UIImageView*)[cell viewWithTag:subViewTag+2];
        [selectedImg setImage:[UIImage imageNamed:@"selected.png"]];
        
        UILabel *label = (UILabel*)[cell viewWithTag:subViewTag+1];
        if ([indexPath indexAtPosition:1] == 0) {
            label.text = @"微信支付";
        } else if ([indexPath indexAtPosition:1] == 1) {
            label.text = @"支付宝支付";
        }
    }
    
    return cell;
}
@end
