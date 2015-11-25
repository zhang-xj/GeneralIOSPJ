//
//  BatchConfirmOrder.m
//  QHC
//
//  Created by qhc2015 on 15/8/2.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "BatchConfirmOrder.h"
#import "UIImageView+WebCache.h"
#import "MyAlerView.h"
#import "LoadingView.h"
#import "JSONKit.h"
#import "WXPay.h"


@implementation BatchConfirmOrder

@synthesize orderFormDetailInfoDic;

@synthesize myTableView;
@synthesize payWaySignArray;

@synthesize httpRequest;
@synthesize payBtn;
@synthesize listKey;

-(id)initWithFrame:(CGRect)frame andOrderInfo:(NSDictionary*)orderDic {
    self = [super initWithFrame:frame];
    if (self) {
        self.orderFormDetailInfoDic = orderDic;
        listKey = @"orderlist";
        if ([self.orderFormDetailInfoDic objectForKey:@"isBatchBuy"]) {
            isBatchBuy = YES;
        } else {
            isBatchBuy = NO;
        }
        
        self.payWaySignArray = [[NSMutableArray alloc] init];
        
        [self createContentView];
        
        //微信支付结果回调
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        appDelegate.delegate = self;
    }
    return self;
}

//创建批量订单视图
-(void)createContentView {
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
    self.myTableView.backgroundColor = [UIColor clearColor];
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    [self addSubview:myTableView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 50)];
    self.payBtn = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 5, self.frame.size.width - 40.0, 34)];
    payBtn.backgroundColor = [UIColor titleBarBackgroundColor];
    payBtn.layer.cornerRadius = 4;
    [payBtn setTitle:@"去支付" forState:UIControlStateNormal];
    [payBtn addTarget:self action:@selector(payBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:payBtn];
    myTableView.tableFooterView = footerView;
}

//去支付
-(void)payBtnAction:(id)sender {
    if (selectedPayWay == 0) {//微信支付
        [self buildWXPayOrderFrom];
    } else if (selectedPayWay == 1) {//支付宝客户端支付
        APPayOrder *pay = [[APPayOrder alloc] init];
        pay.delegate = self;
        [pay payWithProductInfo:self.orderFormDetailInfoDic];
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
    [param setObject:[self.orderFormDetailInfoDic objectForKey:@"orderid"] forKey:@"orderid"];
    
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
    float totalPrice = ((NSString*)[self.orderFormDetailInfoDic objectForKey:@"total"]).floatValue;
    if (cardPrice >= totalPrice) {
        [[MyAlerView sharedAler] ViewShow:@"所选优惠券金额大于订单金额，请重新选择。"];
    } else {
        [self updateOrderInfo:[selectedCardDic objectForKey:@"cardid"]];
    }
}

//修改大订单信息
-(void)updateOrderInfo:(NSString*)cardId {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Order/UpdateBigOrder.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:[self.orderFormDetailInfoDic objectForKey:@"orderid"] forKey:@"orderid"];
    [param setObject:cardId forKey:@"cardid"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//修改大订单状态
-(void)changeOrderStatus {
    //    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Order/UpdateBigOrderStatus.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:[self.orderFormDetailInfoDic objectForKey:@"orderid"] forKey:@"orderid"];
    //    [param setObject:payType forKey:@"paytype"];
    [param setObject:@"10" forKey:@"status"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(changeOrderStatusFinish:)];
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
        self.orderFormDetailInfoDic = responseInfo;
        [self.myTableView reloadData];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
        self.payBtn.userInteractionEnabled = NO;
        self.payBtn.backgroundColor = RGBA(180, 180, 180, 255);
    }
    [[LoadingView sharedLoadingView] hidden];
}

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
    NSArray *orderArray = [self.orderFormDetailInfoDic objectForKey:listKey];
    if (section < orderArray.count) {
        return 28;
    }
    return 5;

}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{//修改group之间的间距
//    NSArray *orderArray = [self.orderFormDetailInfoDic objectForKey:listKey];
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//点击后恢复原有背景状态
    NSArray *orderArray = [self.orderFormDetailInfoDic objectForKey:listKey];
    if ((indexPath.section  == orderArray.count) && [indexPath indexAtPosition:1] == 1) {//选择优惠券
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"yes", nil] forKeys:[NSArray arrayWithObjects:@"selected", nil]];
        MyCardPackageViewController *cardPKController = [[MyCardPackageViewController alloc] initWithProperty:dic];
        cardPKController.delegate = self;
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate.myRootController pushViewController:cardPKController animated:YES];
    } else if (indexPath.section == orderArray.count + 1) {//选择支付方式
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
    NSArray *orderArray = [self.orderFormDetailInfoDic objectForKey:listKey];
    if (indexPath.section < orderArray.count) {
        return 90;
    }
    return 38;
}

#pragma table dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.orderFormDetailInfoDic) {
        NSArray *orderArray = [self.orderFormDetailInfoDic objectForKey:listKey];
        if (orderArray && orderArray.count > 0) {
            return orderArray.count + 2;
        }
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *orderArray = [self.orderFormDetailInfoDic objectForKey:listKey];
    if (section < orderArray.count) {
        NSDictionary *subOrderDic = [orderArray objectAtIndex:section];
        if (isBatchBuy) {
            return [NSString stringWithFormat:@"子订单：%@", [subOrderDic objectForKey:@"orderid"]];
        } else {
            return [NSString stringWithFormat:@"订单：%@", [subOrderDic objectForKey:@"orderid"]];
        }
    }
    
//    if (section == orderArray.count - 2) {
//        
//    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *orderArray = [self.orderFormDetailInfoDic objectForKey:listKey];
    if (section < orderArray.count) {
        return 1;
    } else if (section == orderArray.count) {
        if (isBatchBuy) {
            return 3;
        }
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
    
    NSArray *orderArray = [self.orderFormDetailInfoDic objectForKey:listKey];
    if (cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];
        
        float l_r_padding = 10.0;
        float fontSize = 15.0;
        if (indexPath.section  < orderArray.count) {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(l_r_padding, 10, 70, 70)];
                [imgView setTag:subViewTag];
                [cell addSubview:imgView];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding + imgView.frame.size.width + 8, 12, tableView.frame.size.width - l_r_padding*2 - imgView.frame.size.width - 8, 18)];
                [cell addSubview:label];
                [label setTag:subViewTag+1];
            label.font = LABEL_TITLE_TEXT_FONT;
            
                UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y + label.frame.size.height + 5 , label.frame.size.width, 18)];
                [cell addSubview:label1];
                [label1 setTag:subViewTag+2];
                label1.textColor = [UIColor priceTextColor];
            label1.font = LABEL_DEFAULT_TEXT_FONT;
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x, label1.frame.origin.y + label1.frame.size.height + 5 , label.frame.size.width, 18)];
            [cell addSubview:label2];
            [label2 setTag:subViewTag+3];
            label2.textColor = [UIColor priceTextColor1];
            label2.font = LABEL_DEFAULT_TEXT_FONT;
        } else if (indexPath.section  == orderArray.count) {
//            if ([indexPath indexAtPosition:1] == 0) {
//                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding, 10, tableView.frame.size.width - l_r_padding*2, 18)];
//                [cell addSubview:label];
//                [label setTag:subViewTag];
//                label.font = [UIFont systemFontOfSize:fontSize];
//                
//                UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding, 10, tableView.frame.size.width - l_r_padding*2 - 25, 18)];
//                [cell addSubview:label1];
//                label1.textAlignment = NSTextAlignmentRight;
//                label1.textColor = [UIColor priceTextColor];
//                [label1 setTag:subViewTag+1];
//                label1.font = [UIFont systemFontOfSize:fontSize];
//            } else if ([indexPath indexAtPosition:1] == 1) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding, 10, tableView.frame.size.width - l_r_padding*2, 18)];
                [cell addSubview:label];
                [label setTag:subViewTag];
                label.font = [UIFont systemFontOfSize:fontSize];
                
                UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding, 10, tableView.frame.size.width - l_r_padding*2 - 25, 18)];
                [cell addSubview:label1];
                label1.textAlignment = NSTextAlignmentRight;
            if ([indexPath indexAtPosition:1] == 2) {
                label1.textColor = [UIColor priceTextColor1];
            } else if ([indexPath indexAtPosition:1] == 1) {
                if (isBatchBuy) {
                    label1.textColor = [UIColor priceTextColor];
                } else {
                    label1.textColor = [UIColor priceTextColor1];
                }
            } else {
                label1.textColor = [UIColor priceTextColor];
            }
                [label1 setTag:subViewTag+1];
                label1.font = [UIFont systemFontOfSize:fontSize];
//            } else if ([indexPath indexAtPosition:1] == 2) {
//                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding, 10, tableView.frame.size.width - l_r_padding*2, 18)];
//                [cell addSubview:label];
//                [label setTag:subViewTag];
//                label.font = [UIFont systemFontOfSize:fontSize];
//                
//                UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding, 10, tableView.frame.size.width - l_r_padding*2 - 25, 18)];
//                [cell addSubview:label1];
//                label1.textAlignment = NSTextAlignmentRight;
//                label1.textColor = [UIColor priceTextColor1];
//                [label1 setTag:subViewTag+1];
//                label1.font = [UIFont systemFontOfSize:fontSize];
//            }
        } else {
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
    
    if (indexPath.section < orderArray.count) {
        NSDictionary *subOrderDic = [orderArray objectAtIndex:indexPath.section];
        if (subOrderDic) {
            UIImageView *imgView = (UIImageView*)[cell viewWithTag:subViewTag];
            [imgView sd_setImageWithURL:[NSURL URLWithString:[subOrderDic objectForKey:@"img"]] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
            
            UILabel *label = (UILabel*)[cell viewWithTag:subViewTag+1];
//            label.text = [NSString stringWithFormat:@"项目：%@", [subOrderDic objectForKey:@"projectname"]];
            label.text = [subOrderDic objectForKey:@"projectname"];
            
            UILabel *label1 = (UILabel*)[cell viewWithTag:subViewTag+2];
            label1.text = [NSString stringWithFormat:@"价格：¥%.2f元/%@次", ((NSString*)[subOrderDic objectForKey:@"total"]).floatValue, [subOrderDic objectForKey:@"number"]];
            
            UILabel *label2 = (UILabel*)[cell viewWithTag:subViewTag+3];
            label2.text = [NSString stringWithFormat:@"优惠券：¥%.2f元     实付：%.2f元", ((NSString*)[subOrderDic objectForKey:@"cardmoney"]).floatValue, ((NSString*)[subOrderDic objectForKey:@"realpay"]).floatValue];
        }
    } else if (indexPath.section  == orderArray.count) {
        if ([indexPath indexAtPosition:1] == 0) {
            UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
            label.text = @"累计金额：";
            
            UILabel *label1 = (UILabel*)[cell viewWithTag:subViewTag+1];
            if (self.orderFormDetailInfoDic) {
                label1.text = [NSString stringWithFormat:@"¥%.2f元", ((NSString*)[self.orderFormDetailInfoDic objectForKey:@"total"]).floatValue];
            }
        } else if ([indexPath indexAtPosition:1] == 1) {
            if (isBatchBuy) {
                
                cell.userInteractionEnabled = YES;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//箭头
                UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
                label.text = @"优惠券：";
                
                UILabel *label1 = (UILabel*)[cell viewWithTag:subViewTag+1];
                if (self.orderFormDetailInfoDic) {
                    label1.text = [NSString stringWithFormat:@"¥%.2f元", ((NSString*)[self.orderFormDetailInfoDic objectForKey:@"cardmoney"]).floatValue];
                }
            } else {
                UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
                label.text = @"实付金额：";
                
                UILabel *label1 = (UILabel*)[cell viewWithTag:subViewTag+1];
                if (self.orderFormDetailInfoDic) {
                    label1.text = [NSString stringWithFormat:@"¥%.2f元", ((NSString*)[self.orderFormDetailInfoDic objectForKey:@"realpay"]).floatValue];
                }
            }
        } else if ([indexPath indexAtPosition:1] == 2) {
            UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
            label.text = @"实付金额：";
            
            UILabel *label1 = (UILabel*)[cell viewWithTag:subViewTag+1];
            if (self.orderFormDetailInfoDic) {
                label1.text = [NSString stringWithFormat:@"¥%.2f元", ((NSString*)[self.orderFormDetailInfoDic objectForKey:@"realpay"]).floatValue];
            }
        }
    } else {
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
