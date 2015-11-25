//
//  ConfirmOrder_product.m
//  QHC
//
//  Created by qhc2015 on 15/8/2.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "ConfirmOrder_product.h"
#import "UIImageView+WebCache.h"
#import "MyAlerView.h"
#import "LoadingView.h"
#import "JSONKit.h"
#import "WXPay.h"

@implementation ConfirmOrder_product

@synthesize orderFormDetailInfoDic;

@synthesize orderInfoDic;

@synthesize myTableView;
@synthesize payWaySignArray;

@synthesize httpRequest;
@synthesize payBtn;

@synthesize buyCountTextField;
@synthesize decBtn;
@synthesize addBtn;

-(id)initWithFrame:(CGRect)frame andOrderInfo:(NSDictionary*)orderDic {
    self = [super initWithFrame:frame];
    if (self) {
        self.orderFormDetailInfoDic = orderDic;
        self.payWaySignArray = [[NSMutableArray alloc] init];
        
        buyCount = 1;
        
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
        self.myTableView.backgroundColor = [UIColor clearColor];
        self.myTableView.dataSource = self;
        self.myTableView.delegate = self;
        [self addSubview:myTableView];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 80)];
        self.payBtn = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 5, frame.size.width - 40.0, 34)];
        payBtn.backgroundColor = [UIColor titleBarBackgroundColor];
        payBtn.layer.cornerRadius = 4;
        [payBtn setTitle:@"去支付" forState:UIControlStateNormal];
        [payBtn addTarget:self action:@selector(payBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:payBtn];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20.0, payBtn.frame.origin.y + payBtn.frame.size.height + 5, frame.size.width - 40, 36)];
        label.font = LABEL_SMALL_TEXT_FONT;
        label.numberOfLines = 0;
        label.textColor = [UIColor priceTextColor];
        label.text = @"支付成功后，可以到青花瓷任意门店领取该产品哦。";
        [footerView addSubview:label];
        
        myTableView.tableFooterView = footerView;
        
        [self getOrderInfo];
        
        //微信支付结果回调
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        appDelegate.delegate = self;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        [self addGestureRecognizer:tapGestureRecognizer];
        tapGestureRecognizer.delegate = self;
        self.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    //    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
    //        return NO;
    //    }
    //    return  YES;
    
    if (keyboardShow) {
        return YES;
    }
    return  NO;
}

-(void)hideKeyboard
{
    [self endEditing:YES];//关闭键盘
}

//去支付
-(void)payBtnAction:(UIButton*)button {
    NSInteger number = self.buyCountTextField.text.integerValue;
    if (buyCount != number) {//说明修改了购买数量，需要去修改订单信息
        [self updateOrderInfo:[self.orderInfoDic objectForKey:@"cardid"]];
    } else {
        if (selectedPayWay == 0) {//微信支付
            [self buildWXPayOrderFrom];
        } else if (selectedPayWay == 1) {//支付宝客户端支付
            APPayOrder *pay = [[APPayOrder alloc] init];
            pay.delegate = self;
            [pay payWithProductInfo:self.orderInfoDic];
        }
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

//获取订单信息
-(void)getOrderInfo {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Order/AppendProductOrder.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:[self.orderFormDetailInfoDic objectForKey:@"productid"] forKey:@"productid"];
    [param setObject:[self.orderFormDetailInfoDic objectForKey:@"number"] forKey:@"number"];
    
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
    NSString *urlStr = @"Order/UpdateProductOrder.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:[self.orderInfoDic objectForKey:@"orderid"] forKey:@"orderid"];
    if (cardId && cardId.length > 0) {
        [param setObject:cardId forKey:@"cardid"];
    } else {
        [param setObject:@"" forKey:@"cardid"];
    }
    
    NSInteger number = self.buyCountTextField.text.integerValue;
    if ([@"10200005" isEqualToString:[self.orderInfoDic objectForKey:@"productid"]]) {//奥玛面膜
        [param setObject:[NSString stringWithFormat:@"%lu", number*28] forKey:@"number"];
    } else {
        [param setObject:[NSString stringWithFormat:@"%lu", number] forKey:@"number"];
    }
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestFinish:)];
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
        self.orderInfoDic = responseInfo;
        [self.myTableView reloadData];
        buyCount = self.buyCountTextField.text.integerValue;
        [self.payBtn setTitle:@"去支付" forState:UIControlStateNormal];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
        self.payBtn.userInteractionEnabled = NO;
        self.payBtn.backgroundColor = RGBA(180, 180, 180, 255);
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
    } else if (indexPath.section == 1) {//选择支付方式
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
    }
    return 40;
}

#pragma table dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
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
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(l_r_padding, 8, 70, 70)];
                [imgView setTag:subViewTag];
                [cell addSubview:imgView];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l_r_padding + imgView.frame.size.width + 8, 12, tableView.frame.size.width - l_r_padding*2 - imgView.frame.size.width - 8, 18)];
                [cell addSubview:label];
                [label setTag:subViewTag+1];
                label.font = [UIFont boldSystemFontOfSize:17];
                
                UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y + label.frame.size.height + 5 , label.frame.size.width, 18)];
                [cell addSubview:label1];
                [label1 setTag:subViewTag+2];
                label1.textColor = [UIColor priceTextColor1];
                label1.font = [UIFont systemFontOfSize:fontSize];
                //递减按钮
                self.decBtn = [[UIButton alloc] initWithFrame:CGRectMake(label1.frame.origin.x, label1.frame.origin.y + label1.frame.size.height , 40, 35)];
                [decBtn setTag:subViewTag + 3];
                [decBtn setTitle:@"－" forState:UIControlStateNormal];
                decBtn.titleLabel.font = [UIFont systemFontOfSize:18];
                [decBtn setTitleColor:[UIColor priceTextColor] forState:UIControlStateNormal];
                [decBtn addTarget:self action:@selector(decBuyCount:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:decBtn];
                
                self.buyCountTextField = [[UITextField alloc] initWithFrame:CGRectMake(decBtn.frame.origin.x + decBtn.frame.size.width + 10, decBtn.frame.origin.y + 5, 40, 26)];
                self.buyCountTextField.font = LABEL_DEFAULT_TEXT_FONT;
                self.buyCountTextField.layer.borderColor = RGBA(180, 180, 180, 255).CGColor;
                self.buyCountTextField.layer.borderWidth = 1;
                self.buyCountTextField.layer.cornerRadius = 3;
                self.buyCountTextField.keyboardType = UIKeyboardTypeNumberPad;
                self.buyCountTextField.textAlignment = NSTextAlignmentCenter;
                self.buyCountTextField.text = @"1";
                self.buyCountTextField.delegate = self;
                [cell addSubview:buyCountTextField];
                //递增按钮
                self.addBtn = [[UIButton alloc] initWithFrame:CGRectMake(buyCountTextField.frame.origin.x + buyCountTextField.frame.size.width + 10, decBtn.frame.origin.y, 40, 35)];
                [addBtn setTag:subViewTag + 4];
                [addBtn setTitle:@"+" forState:UIControlStateNormal];
                addBtn.titleLabel.font = [UIFont systemFontOfSize:18];
                [addBtn setTitleColor:[UIColor priceTextColor] forState:UIControlStateNormal];
                [addBtn addTarget:self action:@selector(addBuyCount:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:addBtn];
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
            cell.userInteractionEnabled = YES;
            UIImageView *imgView = (UIImageView*)[cell viewWithTag:subViewTag];
            [imgView sd_setImageWithURL:[NSURL URLWithString:[self.orderInfoDic objectForKey:@"img"]] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
            
            UILabel *label = (UILabel*)[cell viewWithTag:subViewTag+1];
//            label.text = [NSString stringWithFormat:@"产品：%@", [self.orderFormDetailInfoDic objectForKey:@"name"]];
            label.text = [self.orderInfoDic objectForKey:@"productname"];
            
            UILabel *label1 = (UILabel*)[cell viewWithTag:subViewTag+2];
            if (self.orderInfoDic) {
//                NSInteger number = ((NSString*)[self.orderInfoDic objectForKey:@"number"]).integerValue;
//                if ([@"10200005" isEqualToString:[self.orderFormDetailInfoDic objectForKey:@"productid"]]) {//奥玛面膜
//                    label1.text = [NSString stringWithFormat:@"价格：¥%.2f元/%lu盒(28片/盒)", ((NSString*)[self.orderInfoDic objectForKey:@"total"]).floatValue, number/28];
//                } else {
//                    label1.text = [NSString stringWithFormat:@"价格：¥%.2f元/%lu瓶(125g/瓶)", ((NSString*)[self.orderInfoDic objectForKey:@"total"]).floatValue, number];
//                }
                if ([@"10200005" isEqualToString:[self.orderFormDetailInfoDic objectForKey:@"productid"]]) {//奥玛面膜
                    label1.text = [NSString stringWithFormat:@"价格：¥%.2f元/%@盒(28片/盒)", ((NSString*)[self.orderInfoDic objectForKey:@"total"]).floatValue, self.buyCountTextField.text];
                } else {
                    label1.text = [NSString stringWithFormat:@"价格：¥%.2f元/%@瓶(125g/瓶)", ((NSString*)[self.orderInfoDic objectForKey:@"total"]).floatValue, self.buyCountTextField.text];
                }
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
//减少购买数量
-(void)decBuyCount:(id)sender {
    NSString *str = self.buyCountTextField.text;
    NSInteger count = str.integerValue;
    if (count > 1) {
        self.buyCountTextField.text = [NSString stringWithFormat:@"%ld", (long)count-1];
        if (buyCount == count-1) {
            [self.payBtn setTitle:@"去支付" forState:UIControlStateNormal];
        } else {
            [self.payBtn setTitle:@"确定" forState:UIControlStateNormal];
        }
    }
}
//增加购买数量
-(void)addBuyCount:(id)sender {
    NSString *str = self.buyCountTextField.text;
    NSInteger count = str.integerValue;
    if (count < 999) {
        self.buyCountTextField.text = [NSString stringWithFormat:@"%ld", (long)count+1];
        if (buyCount == count+1) {
            [self.payBtn setTitle:@"去支付" forState:UIControlStateNormal];
        } else {
            [self.payBtn setTitle:@"确定" forState:UIControlStateNormal];
        }
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.payBtn.userInteractionEnabled = NO;
    self.decBtn.userInteractionEnabled = NO;
    self.addBtn.userInteractionEnabled = NO;
    keyboardShow = YES;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    NSString *number = string;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    NSString *oldStr = textField.text;
    if (oldStr.length >= 3 && number.length > 0) {
        res = NO;
    }
    if (res) {
        //去刷新页面数据
    }
    return res;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *oldStr = textField.text;
    if (oldStr.length <= 0) {
        textField.text = @"1";
    }
    
    NSInteger number = textField.text.integerValue;
    if (number != buyCount) {//修改了购买数量，去修改订单信息
        [self updateOrderInfo:[self.orderInfoDic objectForKey:@"cardid"]];
    }
    keyboardShow = NO;
    self.payBtn.userInteractionEnabled = YES;
    self.decBtn.userInteractionEnabled = YES;
    self.addBtn.userInteractionEnabled = YES;
}
@end
