//
//  ConfirmOrderView.m
//  QHC
//
//  Created by qhc2015 on 15/7/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "ConfirmOrderView.h"
#import "UIImageView+WebCache.h"
#import "MyAlerView.h"
#import "LoadingView.h"
#import "JSONKit.h"
#import "WXPay.h"

@implementation ConfirmOrderView

@synthesize orderFormDetailInfoDic;

@synthesize orderInfoDic;

@synthesize myTableView;
@synthesize payWaySignArray;

@synthesize httpRequest;
@synthesize payBtn;

-(id)initWithFrame:(CGRect)frame andOrderInfo:(NSDictionary*)orderDic {
    self = [super initWithFrame:frame];
    if (self) {
        self.orderFormDetailInfoDic = orderDic;
        self.payWaySignArray = [[NSMutableArray alloc] init];
        
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
        self.myTableView.backgroundColor = [UIColor clearColor];
        self.myTableView.dataSource = self;
        self.myTableView.delegate = self;
        [self addSubview:myTableView];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 50)];
        self.payBtn = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 5, frame.size.width - 40.0, 34)];
        payBtn.backgroundColor = [UIColor titleBarBackgroundColor];
        payBtn.layer.cornerRadius = 4;
        [payBtn setTitle:@"去支付" forState:UIControlStateNormal];
        [payBtn addTarget:self action:@selector(payBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:payBtn];
        myTableView.tableFooterView = footerView;
        
        [self getOrderInfo];
        
        //微信支付结果回调
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        appDelegate.delegate = self;
    }
    return self;
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

#pragma mark APPayOrderDelegate
//支付宝支付结果回调
-(void)payResponse:(NSDictionary *)payResult {
    NSString *payResultStatus = [payResult objectForKey:@"resultStatus"];
    if (payResultStatus.integerValue == 9000) {
        [[MyAlerView sharedAler] ViewShow:@"支付成功"];
        self.payBtn.userInteractionEnabled = NO;
        [self.payBtn setTitle:@"已支付" forState:UIControlStateNormal];
        self.payBtn.backgroundColor = RGBA(180, 180, 180, 250);
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
            [self changeOrderStatus];
            break;
        default:
            [[MyAlerView sharedAler] ViewShow:@"支付失败"];
            break;
    }
}
#pragma end


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

//获取订单信息
-(void)getOrderInfo {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Order/Append.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:[self.orderFormDetailInfoDic objectForKey:@"projectid"] forKey:@"projectid"];
    [param setObject:[self.orderFormDetailInfoDic objectForKey:@"count"] forKey:@"number"];
    NSDictionary *storeDic = [self.orderFormDetailInfoDic objectForKey:@"store"];
    NSDictionary *masterDic = [self.orderFormDetailInfoDic objectForKey:@"master"];
    NSString *dateTime = [((NSDictionary*)[self.orderFormDetailInfoDic objectForKey:@"besTime"]) objectForKey:@"commitStr"];
    if ([self.orderFormDetailInfoDic objectForKey:@"besTime"]) {
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
    [httpRequest setRequestFinishCallBack:@selector(requestFinish:)];
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
    [param setObject:cardId forKey:@"cardid"];
    NSDictionary *storeDic = [self.orderFormDetailInfoDic objectForKey:@"store"];
    NSDictionary *masterDic = [self.orderFormDetailInfoDic objectForKey:@"master"];
    NSString *dateTime = [((NSDictionary*)[self.orderFormDetailInfoDic objectForKey:@"besTime"]) objectForKey:@"commitStr"];
    if ([self.orderFormDetailInfoDic objectForKey:@"besTime"]) {
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
    NSInteger statusCode = ((NSString*)[responseInfo objectForKey:@"status"]).integerValue;
    if (resultCode == 1 && statusCode == 1) {//成功
        self.orderInfoDic = responseInfo;
        NSInteger isExperience = ((NSString*)[self.orderInfoDic objectForKey:@"isexperience"]).integerValue;
        if (isExperience == 1) {// 1:是首次体验; 0:不是首次体验; 如果这个是第一次购买（首次体验）；那么记录下项目id 和订单id
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[self.orderInfoDic objectForKey:@"orderid"] forKey:[self.orderInfoDic objectForKey:@"projectid"]];
            //同时将key纪录
            NSMutableArray *userCacheKeys;
            if ([userDefaults objectForKey:USER_CACHE_KEYS]) {
                userCacheKeys  = [NSMutableArray arrayWithArray:[userDefaults objectForKey:USER_CACHE_KEYS]];
            } else {
                userCacheKeys = [[NSMutableArray alloc] init];
            }
            [userCacheKeys addObject:[self.orderInfoDic objectForKey:@"projectid"]];
            [userDefaults setObject:userCacheKeys forKey:USER_CACHE_KEYS];
        }
        [self.myTableView reloadData];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
        self.payBtn.userInteractionEnabled = NO;
        self.payBtn.backgroundColor = RGBA(180, 180, 180, 255);
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
            return 90;
        }
    } else if (indexPath.section == 1) {
        if ([indexPath indexAtPosition:1] == 3) {
            NSDictionary *storeDic = [self.orderFormDetailInfoDic objectForKey:@"store"];
            NSString *textStr = [NSString stringWithFormat:@"门店地址：%@", [storeDic objectForKey:@"address"]];
            CGSize lSize = [AppDelegate getStringInLabelSize:textStr andFont:[UIFont systemFontOfSize:15] andLabelWidth:tableView.frame.size.width - 20];
            return lSize.height + 20;
        }
    } else if (indexPath.section == 2) {
        return 40;
    }
    return 38;
}

#pragma table dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if(section == 1){
        return 4;
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
                label.font = [UIFont boldSystemFontOfSize:17];
                
                UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y + label.frame.size.height + 15 , label.frame.size.width, 18)];
                [cell addSubview:label1];
                [label1 setTag:subViewTag+2];
                label1.textColor = [UIColor priceTextColor1];
                label1.font = [UIFont systemFontOfSize:fontSize];
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
                
                UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding, 10, tableView.frame.size.width - l_r_padding*2 - 25, 18)];
                [cell addSubview:label1];
                label1.textAlignment = NSTextAlignmentRight;
                label1.textColor = [UIColor priceTextColor1];
                [label1 setTag:subViewTag+1];
                label1.font = [UIFont systemFontOfSize:fontSize];
            }
        } else if (indexPath.section == 1) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding, 10, tableView.frame.size.width - l_r_padding*2, 18)];
            [cell addSubview:label];
            [label setTag:subViewTag];
            label.font = [UIFont systemFontOfSize:fontSize];
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
            [imgView sd_setImageWithURL:[NSURL URLWithString:[self.orderFormDetailInfoDic objectForKey:@"img"]] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
            
            UILabel *label = (UILabel*)[cell viewWithTag:subViewTag+1];
//            label.text = [NSString stringWithFormat:@"项目：%@", [self.orderFormDetailInfoDic objectForKey:@"name"]];
            label.text = [self.orderFormDetailInfoDic objectForKey:@"name"];
            
            UILabel *label1 = (UILabel*)[cell viewWithTag:subViewTag+2];
            if (self.orderInfoDic) {
                label1.text = [NSString stringWithFormat:@"价格：¥%.2f元/%@次", ((NSString*)[self.orderInfoDic objectForKey:@"total"]).floatValue, [self.orderFormDetailInfoDic objectForKey:@"count"]];
            }
        } else if ([indexPath indexAtPosition:1] == 1) {
            cell.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//箭头
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
        }
    } else if (indexPath.section == 1) {
        if ([indexPath indexAtPosition:1] == 0) {
            UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
            NSDictionary *masterDic = [self.orderFormDetailInfoDic objectForKey:@"master"];
            if (masterDic) {
                label.text = [NSString stringWithFormat:@"预约养生顾问：%@", [masterDic objectForKey:@"name"]];
            } else {
                label.text = @"预约养生顾问：-";
            }
        } else if ([indexPath indexAtPosition:1] == 1) {
            UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
            NSDictionary *besTime = [self.orderFormDetailInfoDic objectForKey:@"besTime"];
            if (besTime) {
                label.text = [NSString stringWithFormat:@"预约时间：%@", [besTime objectForKey:@"showStr"]];
            } else {
                label.text = @"预约时间：-";
            }
        } else if ([indexPath indexAtPosition:1] == 2) {
            UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
            NSDictionary *store = [self.orderFormDetailInfoDic objectForKey:@"store"];
            if (store) {
                label.text = [NSString stringWithFormat:@"预约门店：%@", [store objectForKey:@"name"]];
            } else {
                label.text = @"预约门店：-";
            }
        } else {
            UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
            label.numberOfLines = 0;
            NSDictionary *storeDic = [self.orderFormDetailInfoDic objectForKey:@"store"];
            if (storeDic) {
            NSString *textStr = [NSString stringWithFormat:@"门店地址：%@", [storeDic objectForKey:@"address"]];
            CGSize lSize = [AppDelegate getStringInLabelSize:textStr andFont:label.font andLabelWidth:label.frame.size.width];
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, lSize.width, lSize.height);
            label.text = textStr;
            } else {
                label.text = @"门店地址：-";
            }
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
