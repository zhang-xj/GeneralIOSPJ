//
//  QHCQinghuaBeatView.m
//  QHC
//
//  Created by qhc2015 on 15/6/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCProjectDetailView.h"
#import "BWMCoverView.h"
#import "AppDelegate.h"
#import "QHCQinghuaBeatPicView.h"
#import "LoadingView.h"
#import "MyAlerView.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "CommentViewController.h"
#import "ConfirmOrderViewController.h"


@implementation QHCProjectDetailView

#ifndef FIRST
#define FIRST 8
#endif
#ifndef SINGLE
#define SINGLE 88
#endif
#ifndef MUL
#define MUL 888
#endif

@synthesize userClickPayButton;

@synthesize contentTableView;

@synthesize projectId;

@synthesize httpRequest;
@synthesize contentDataDic;
@synthesize bespeakInfoMutdic;
@synthesize bespeakDTArray;

@synthesize tableFooterView;

-(id)initWithFrame:(CGRect)frame withData:(NSDictionary*)dataDic {
    self = [super initWithFrame:frame];
    if (self) {
        if ([dataDic objectForKey:@"store"]) {
            self.bespeakInfoMutdic = [[NSMutableDictionary alloc] init];
            [bespeakInfoMutdic setObject:[dataDic objectForKey:@"store"] forKey:@"store"];
        }
        if ([dataDic objectForKey:@"master"]) {
            [bespeakInfoMutdic setObject:[dataDic objectForKey:@"master"] forKey:@"master"];
        }
        
        self.projectId = [dataDic objectForKey:@"projectid"];
        
        [self getProjectDetailData:projectId];

    }
    return self;
}

-(void)collectAction:(id)sender {
    [self collectThisProject];
}

-(void)initTableView {
    self.contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentTableView];
    
    [self createTableFooterView];
}

-(void)refreshFirstBuyBtnStatus {
    UIButton *firstBuy = (UIButton*)[self.tableFooterView viewWithTag:FIRST];
    UIButton *paySingle = (UIButton*)[self.tableFooterView viewWithTag:SINGLE];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:self.projectId]) {//如果已经购买过首次体验的，则改按钮不可用
        firstBuy.backgroundColor = RGBA(180, 180, 180, 255);
        firstBuy.userInteractionEnabled = NO;
        paySingle.backgroundColor = [UIColor titleBarBackgroundColor];
        paySingle.userInteractionEnabled = YES;
    } else {
        firstBuy.backgroundColor = [UIColor titleBarBackgroundColor];
        firstBuy.userInteractionEnabled = YES;
        paySingle.backgroundColor = RGBA(180, 180, 180, 255);
        paySingle.userInteractionEnabled = NO;
    }
}

-(void)createTableFooterView {
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 75)];
    float pading = 10.0;
    float butn_y = 37;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(pading, 0.0, tableFooterView.frame.size.width - 2*pading, 38)];
    label.font = LABEL_SMALL_TEXT_FONT;
    label.textColor = [UIColor priceTextColor];
    label.numberOfLines = 0;
    label.text = @"填写完整的门店、养生师和时间信息，购买成功后可自动生成预约单";
    [tableFooterView addSubview:label];
    
    //购买首次体验
    UIButton *firstBuy = [[UIButton alloc] initWithFrame:CGRectMake(pading, butn_y, (tableFooterView.frame.size.width-40)/3, 32)];
    [firstBuy setTag:FIRST];
    firstBuy.layer.cornerRadius = 4;
    [firstBuy setTitle:@"首次体验" forState:UIControlStateNormal];
    firstBuy.backgroundColor = [UIColor titleBarBackgroundColor];
    [firstBuy addTarget:self action:@selector(commitForm:) forControlEvents:UIControlEventTouchUpInside];
    
    //购买单次
    UIButton *paySingle = [[UIButton alloc] initWithFrame:CGRectMake(2*pading + firstBuy.frame.size.width, butn_y, (tableFooterView.frame.size.width-40)/3, 32)];
    [paySingle setTag:SINGLE];
    paySingle.backgroundColor = [UIColor titleBarBackgroundColor];
    paySingle.layer.cornerRadius = 4;
    [paySingle setTitle:@"购买单次" forState:UIControlStateNormal];
    [paySingle addTarget:self action:@selector(commitForm:) forControlEvents:UIControlEventTouchUpInside];
    //购买套餐
    UIButton *payMul = [[UIButton alloc] initWithFrame:CGRectMake(2*(pading + firstBuy.frame.size.width) + pading, butn_y, (tableFooterView.frame.size.width-40)/3, 32)];
    [payMul setTag:MUL];
    payMul.backgroundColor = [UIColor titleBarBackgroundColor];
    payMul.layer.cornerRadius = 4;
    [payMul setTitle:@"购买套餐" forState:UIControlStateNormal];
    [payMul addTarget:self action:@selector(commitForm:) forControlEvents:UIControlEventTouchUpInside];
    
    [tableFooterView addSubview:firstBuy];
    [tableFooterView addSubview:paySingle];
    [tableFooterView addSubview:payMul];
    [self refreshFirstBuyBtnStatus];
    self.contentTableView.tableFooterView = tableFooterView;
}

//创建label
-(UILabel*)createLabel:(CGPoint)point labelFont:(UIFont*)lFont textColor:(UIColor*)color labelText:(NSString*)text maxWidth:(float)max_w{
    CGSize lSize = [AppDelegate getStringInLabelSize:text andFont:lFont  andLabelWidth:max_w];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(point.x, point.y, lSize.width, lSize.height)];
    label.font = lFont;
    label.textColor = color;
    label.text = text;
    return label;
}

//提交订单
-(void)commitForm:(id)sender {
    UIButton *commitBtn = (UIButton*)sender;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    if (userId && userId.length > 0) {
//        if (![self.bespeakInfoMutdic objectForKey:@"store"]) {
//            [[MyAlerView sharedAler] ViewShow:@"请选择门店"];
//            return;
//        } else if(![self.bespeakInfoMutdic objectForKey:@"master"]) {
//            [[MyAlerView sharedAler] ViewShow:@"请选择养生顾问"];
//            return;
//        } else if(![self.bespeakInfoMutdic objectForKey:@"besTime"]) {
//            [[MyAlerView sharedAler] ViewShow:@"请选择预约时间"];
//            return;
//        }
        NSMutableDictionary *orderDetailDic = [NSMutableDictionary dictionaryWithDictionary:self.contentDataDic];
        if (self.bespeakInfoMutdic) {
            [orderDetailDic setValuesForKeysWithDictionary:self.bespeakInfoMutdic];
        }
        if (commitBtn.tag == SINGLE || commitBtn.tag == FIRST) {
            [orderDetailDic setObject:@"1" forKey:@"count"];
        } else if (commitBtn.tag == MUL) {
            [orderDetailDic setObject:[contentDataDic objectForKey:@"packagetimes"] forKey:@"count"];
        }
        //进入订单确认页面
        ConfirmOrderViewController *cforderViewController = [[ConfirmOrderViewController alloc] initWithOrderInfo:orderDetailDic];
        AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [appdelegate.myRootController pushViewController:cforderViewController animated:YES];
    } else {//去登录界面
        self.userClickPayButton = commitBtn;
        loginReponseType = 1;
        [self showLoginView];
    }
}

//进入登录页
-(void)showLoginView {
    LoginView *loginView = [[LoginView alloc ]initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    loginView.delegate = self;
    [self addSubview:loginView];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, CONTENT_OFFSET, CONTENT_OFFSET)];
    [closeBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeLoginView:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setTag:123];
    [self addSubview:closeBtn];
}
-(void)closeLoginView:(id)sender {
    [[self viewWithTag:LOGIN_VIEW_TAG] removeFromSuperview];
    [[self viewWithTag:123] removeFromSuperview];
}
//获取项目详情
-(void)getProjectDetailData:(NSString*)proId {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Project/Details.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:proId forKey:@"projectid"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(proDetailRequestFinish:)];
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
    [param setObject:self.projectId forKey:@"projectid"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(bespeakDTRequestFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//收藏这个项目
-(void)collectThisProject {
//    [[LoadingView sharedLoadingView] show];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    if (userId && userId.length > 0) {
        //创建异步请求
        NSString *urlStr = @"Favorites/Append.aspx";
        self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:userId forKey:@"userid"];
        [param setObject:@"1" forKey:@"type"];
        [param setObject:self.projectId forKey:@"id"];
    
        [httpRequest setDelegate:self];
        //设置请求完成的回调方法
        [httpRequest setRequestFinishCallBack:@selector(collectFinish:)];
        //设置请求失败的回调方法
        [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
        [httpRequest sendHttpRequestByPost:urlStr params:param];
    } else {//去登录界面
        loginReponseType = 2;
        [self showLoginView];
        
    }
}

#pragma mark ASIHTTPRequestDelegate
//请求失败代理方法
-(void) requestFail:(NSString*) responseStr
{
    [[LoadingView sharedLoadingView] hidden];
    NSLog(@"login request fail error = %@", responseStr);
    [[MyAlerView sharedAler] ViewShow:@"网络异常，请稍后重试"];
}

-(void) proDetailRequestFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        self.contentDataDic = responseInfo;
        //        [self.contentTableView reloadData];
        [self initTableView];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}

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

-(void) collectFinish:(NSData*)responseData {
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if (responseInfo && ((NSString*)[responseInfo objectForKey:@"status"]).integerValue == 1) {
            [[MyAlerView sharedAler] ViewShow:@"收藏成功"];
        } else {
            [[MyAlerView sharedAler] ViewShow:@"服务器忙，请稍候再试"];
        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }

}

#pragma mark QHCStoreListViewControllerDelegate
-(void)selectedStoreInfo:(NSDictionary *)storeInfoDic {
    if (nil == self.bespeakInfoMutdic) {
        self.bespeakInfoMutdic = [[NSMutableDictionary alloc] init];
    } else {
        [self.bespeakInfoMutdic removeAllObjects];//重新选择门店后需要重新选择养生顾问和时间
    }
    [bespeakInfoMutdic setObject:storeInfoDic forKey:@"store"];
    [self.contentTableView reloadData];
    //滚到最底部
    [self.contentTableView setContentOffset:CGPointMake(0.0, self.contentTableView.contentSize.height - self.contentTableView.frame.size.height)];
    
}
#pragma mark MasterListViewControllerDelegate
-(void)selectedMasterInfo:(NSDictionary*)masterInfoDic {
    [self.bespeakInfoMutdic removeObjectForKey:@"besTime"];//重新选择养生顾问后需要重新选择时间
    [self.bespeakInfoMutdic setObject:masterInfoDic forKey:@"master"];
    [self.contentTableView reloadData];
    //滚到最底部
    [self.contentTableView setContentOffset:CGPointMake(0.0, self.contentTableView.contentSize.height - self.contentTableView.frame.size.height)];
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
    [self.contentTableView reloadData];
    //滚到最底部
    [self.contentTableView setContentOffset:CGPointMake(0.0, self.contentTableView.contentSize.height - self.contentTableView.frame.size.height)];
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
    if (indexPath.section == 4) {//选择栏
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
        } else {//选择日期时间
            NSDictionary *masterDic = [self.bespeakInfoMutdic objectForKey:@"master"];
            [self getBespeakDayTimeData:[masterDic objectForKey:@"salerid"]];
        }
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
    if (indexPath.section == 0) {
        if ([indexPath indexAtPosition:1] == 0) {
            return 155;
        } else if ([indexPath indexAtPosition:1] == 1) {
            return 100;
        }
    } else if (indexPath.section == 1) {
        if ([indexPath indexAtPosition:1] == 0) {
            NSString *text = [contentDataDic objectForKey:@"efficacies"];
            CGSize lSize = [AppDelegate getStringInLabelSize:text andFont:LABEL_DEFAULT_TEXT_FONT  andLabelWidth:tableView.frame.size.width - 30];
            return lSize.height + 20 + 28;
        }
    } else if (indexPath.section == 2) {
        if ([indexPath indexAtPosition:1] == 0) {
            return 36;
        } else {
            NSString *text = [contentDataDic objectForKey:@"operationprocess"];
            CGSize lSize = [AppDelegate getStringInLabelSize:text andFont:LABEL_DEFAULT_TEXT_FONT  andLabelWidth:tableView.frame.size.width - 30];
            return lSize.height + 20;
        }
    } else if (indexPath.section == 3) {
        if ([indexPath indexAtPosition:1] == 0) {
            return 36;
        } else {
            NSString *text = [contentDataDic objectForKey:@"projectdescription"];
            CGSize lSize = [AppDelegate getStringInLabelSize:text andFont:LABEL_DEFAULT_TEXT_FONT  andLabelWidth:tableView.frame.size.width - 30];
            return lSize.height + 20;
        }
    }
    return 38;
}

#pragma table dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 4){
        if (self.bespeakInfoMutdic) {
            NSInteger rowCount = [self.bespeakInfoMutdic allKeys].count;
            return rowCount + 1 > 3 ? 3 : rowCount+1;
        }
        return 1;
    }
    return 2;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * showUserInfoCellIdentifier = [NSString stringWithFormat:@"projectDetailCell%ld%ld", indexPath.section, [indexPath indexAtPosition:1]] ;
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];
    
    NSInteger subViewTag = (indexPath.section + 3) * 100 + [indexPath indexAtPosition:1];
    float labelLeftPading = 15.0;
    if (cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];

        if (indexPath.section == 0) {
            if ([indexPath indexAtPosition:1] == 0) {
                //项目图片
                UIImageView *proImg = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 155)];
                [proImg setTag:subViewTag];
                [cell addSubview:proImg];
            } else if([indexPath indexAtPosition:1] == 1) {
                //项目名称
                UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPading, 15.0, tableView.frame.size.width - 2*labelLeftPading, 16)];
                [labelName setTag:subViewTag];
                labelName.font = LABEL_TITLE_TEXT_FONT;
                labelName.textColor = LABEL_TITLE_TEXT_COLOR;
                [cell addSubview:labelName];
                //首次体验价格
                UILabel *priceSingle = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPading, labelName.frame.origin.y + labelName.frame.size.height + 10, tableView.frame.size.width - 2*labelLeftPading, 16)];
                priceSingle.textColor = LABEL_PRICE_TEXT_COLOR;
                priceSingle.font = LABEL_DEFAULT_TEXT_FONT;
                [priceSingle setTag:subViewTag+1];
                [cell addSubview:priceSingle];
                //套餐推广价
                UILabel *priceMul = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPading, priceSingle.frame.origin.y + priceSingle.frame.size.height + 3, 145, 15)];
                priceMul.textColor = LABEL_PRICE_TEXT_COLOR;
                priceMul.font = [UIFont systemFontOfSize:13];
                [priceMul setTag:subViewTag+2];
                [cell addSubview:priceMul];
                //套餐原价
                UILabel *priceMul1 = [[UILabel alloc] initWithFrame:CGRectMake(priceMul.frame.origin.x + priceMul.frame.size.width + 10, priceSingle.frame.origin.y + priceSingle.frame.size.height + 3, 145, 15)];
                priceMul1.textColor = [UIColor grayColor];
                priceMul1.font = [UIFont systemFontOfSize:13];
                [priceMul1 setTag:subViewTag+5];
                [cell addSubview:priceMul1];
                
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(priceMul1.frame.origin.x + 35, priceMul1.frame.origin.y + 8, priceMul1.frame.size.width - 45, 1)];
                view.backgroundColor = [UIColor grayColor];
                [cell addSubview:view];
                //已销售数量
                UILabel *sales = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPading, priceMul.frame.origin.y + priceMul.frame.size.height + 3, tableView.frame.size.width - 2*labelLeftPading, 15)];
                sales.textColor = [UIColor textColor_yellow];
                sales.font = [UIFont systemFontOfSize:12];
                [sales setTag:subViewTag+3];
                [cell addSubview:sales];
                //购买提示
                UILabel *payNotice = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPading, priceMul.frame.origin.y + priceMul.frame.size.height + 3, tableView.frame.size.width - 2*labelLeftPading, 15)];
                payNotice.textColor = [UIColor textColor_yellow];
                payNotice.font = [UIFont systemFontOfSize:12];
                payNotice.textAlignment = NSTextAlignmentRight;
                [payNotice setTag:subViewTag+4];
                [cell addSubview:payNotice];
            }
        } else if (indexPath.section == 1) {//项目介绍
            if ([indexPath indexAtPosition:1] == 0) {
                //项目介绍
                UILabel *effectTitle = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPading, labelLeftPading, tableView.frame.size.width - labelLeftPading*2, 18)];
                effectTitle.font = LABEL_TITLE_TEXT_FONT;
                effectTitle.textColor = LABEL_TITLE_TEXT_COLOR;
                effectTitle.text = @"项目介绍：";
                [cell addSubview:effectTitle];
                
                UILabel *effect = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPading, effectTitle.frame.origin.y + effectTitle.frame.size.height + 3, tableView.frame.size.width - labelLeftPading*2, cell.frame.size.height)];
                effect.font = LABEL_DEFAULT_TEXT_FONT;
                effect.textColor = LABEL_DEFAULT_TEXT_COLOR;
                effect.numberOfLines = 0;
                [effect setTag:subViewTag];
                [cell addSubview:effect];
            } else {
                UILabel *effect = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPading, 11.5, tableView.frame.size.width - labelLeftPading*2, 15)];
                effect.font = LABEL_DEFAULT_TEXT_FONT;
                effect.textColor = LABEL_DEFAULT_TEXT_COLOR;
                [effect setTag:subViewTag];
                [cell addSubview:effect];
            }
        } else if (indexPath.section == 2) {//服务内容
            if([indexPath indexAtPosition:1] == 0){
                //标题
                UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPading, labelLeftPading, tableView.frame.size.width - 2*labelLeftPading, 16)];
                labelTitle.font = LABEL_TITLE_TEXT_FONT;
                labelTitle.textColor = LABEL_TITLE_TEXT_COLOR;
                labelTitle.text = @"项目步骤";
                [cell addSubview:labelTitle];
            } else {
                //服务内容
                UILabel *serviceContent = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPading, labelLeftPading, tableView.frame.size.width - 2*labelLeftPading, 16)];
                serviceContent.font = LABEL_DEFAULT_TEXT_FONT;
                serviceContent.textColor = LABEL_DEFAULT_TEXT_COLOR;
                serviceContent.numberOfLines = 0;
                [serviceContent setTag:subViewTag];
                [cell addSubview:serviceContent];
            }
        } else if (indexPath.section == 3) {//项目说明
            if([indexPath indexAtPosition:1] == 0){
                //标题
                UILabel *labelProTitle = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPading, labelLeftPading, tableView.frame.size.width - 2*labelLeftPading, 16)];
                labelProTitle.font = LABEL_TITLE_TEXT_FONT;
                labelProTitle.textColor = LABEL_TITLE_TEXT_COLOR;
                labelProTitle.text = @"项目说明";
                [cell addSubview:labelProTitle];
            } else {
                //项目说明
                UILabel *labelProExplain = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPading, labelLeftPading, tableView.frame.size.width - 2*labelLeftPading, 16)];
                labelProExplain.font = LABEL_DEFAULT_TEXT_FONT;
                labelProExplain.textColor = LABEL_DEFAULT_TEXT_COLOR;
                labelProExplain.numberOfLines = 0;
                [labelProExplain setTag:subViewTag];
                [cell addSubview:labelProExplain];
            }
        } else if (indexPath.section == 4) {//选择门店 养生顾问 预约时间等
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(labelLeftPading, 9, 20.5, 19.5)];
            [imgView setTag:subViewTag+1];
            [cell addSubview:imgView];

            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 8, 11.5, tableView.frame.size.width - 2*labelLeftPading, 15)];
            label.font = LABEL_LARGE_TEXT_FONT;
            label.textColor = LABEL_TITLE_TEXT_COLOR;
            [label setTag:subViewTag];
            [cell addSubview:label];
        }
    }
    
    cell.backgroundColor = [UIColor tableViewBackgroundColor];
    cell.userInteractionEnabled = NO;
    if (indexPath.section == 0) {
        if ([indexPath indexAtPosition:1] == 0) {
            UIImageView *imgview = (UIImageView*)[cell viewWithTag:subViewTag];
            [imgview sd_setImageWithURL:[NSURL URLWithString:[contentDataDic objectForKey:@"img"]] placeholderImage:[UIImage imageNamed:@"cover_image1.png"]];
        } else if([indexPath indexAtPosition:1] == 1) {
            //项目名称
            UILabel *labelName = (UILabel*)[cell viewWithTag:subViewTag];
            labelName.text = [contentDataDic objectForKey:@"name"];
            //单次价格
            UILabel *priceSingle = (UILabel*)[cell viewWithTag:subViewTag+1];
            priceSingle.text = [NSString stringWithFormat:@"首次体验价：¥%.2f元/次", ((NSString*)[contentDataDic objectForKey:@"experienceprice"]).floatValue];
            //套餐推广价格
            UILabel *priceMul = (UILabel*)[cell viewWithTag:subViewTag+2];
            priceMul.text = [NSString stringWithFormat:@"推广价：¥%.0f元/%@次", ((NSString*)[contentDataDic objectForKey:@"packageprice"]).floatValue, [contentDataDic objectForKey:@"packagetimes"]];
            //套餐原价
            UILabel *priceMul1 = (UILabel*)[cell viewWithTag:subViewTag+5];
            priceMul1.text = [NSString stringWithFormat:@"原价：¥%.0f元/%@次", ((NSString*)[contentDataDic objectForKey:@"packagemarketprice"]).floatValue, [contentDataDic objectForKey:@"packagetimes"]];
            //购买数量
            UILabel *sales = (UILabel*)[cell viewWithTag:subViewTag+3];
            sales.text = [NSString stringWithFormat:@"%@人已购买", [contentDataDic objectForKey:@"sales"]];
            //购买提示
            UILabel *payNotice = (UILabel*)[cell viewWithTag:subViewTag+4];
            payNotice.text = @"仅为女性顾客提供服务";
        }
    } else if (indexPath.section == 1) {//项目介绍
        if ([indexPath indexAtPosition:1] == 0) {
            //项目介绍
            UILabel *effect = (UILabel*)[cell viewWithTag:subViewTag];
            NSString *text = [contentDataDic objectForKey:@"efficacies"];
            CGSize lSize = [AppDelegate getStringInLabelSize:text andFont:effect.font  andLabelWidth:tableView.frame.size.width - 2*labelLeftPading];
            effect.text = text;
            effect.frame = CGRectMake(effect.frame.origin.x, effect.frame.origin.y, effect.frame.size.width, lSize.height);
        } else {
            //耗时
            UILabel *labelTitle = (UILabel*)[cell viewWithTag:subViewTag];
            labelTitle.text = [NSString stringWithFormat:@"耗时：%@分钟", [contentDataDic objectForKey:@"servicetime"]];
        }
    } else if (indexPath.section == 2) {//服务内容
        if ([indexPath indexAtPosition:1] == 1) {
            //服务内容
            UILabel *serviceContent = (UILabel*)[cell viewWithTag:subViewTag];
            NSString *text = [contentDataDic objectForKey:@"operationprocess"];
            CGSize lSize = [AppDelegate getStringInLabelSize:text andFont:serviceContent.font  andLabelWidth:tableView.frame.size.width - 2*labelLeftPading];
            serviceContent.text = text;
            serviceContent.frame = CGRectMake(serviceContent.frame.origin.x, serviceContent.frame.origin.y, serviceContent.frame.size.width, lSize.height);

        }
    } else if (indexPath.section == 3) {//项目说明
        if([indexPath indexAtPosition:1] == 1){
            //项目说明
            UILabel *labelProExplain = (UILabel*)[cell viewWithTag:subViewTag];
            NSString *text = [contentDataDic objectForKey:@"projectdescription"];
            CGSize lSize = [AppDelegate getStringInLabelSize:text andFont:labelProExplain.font  andLabelWidth:tableView.frame.size.width - 2*labelLeftPading];
            labelProExplain.text = text;
            labelProExplain.frame = CGRectMake(labelProExplain.frame.origin.x, labelProExplain.frame.origin.y, labelProExplain.frame.size.width, lSize.height);
        }
    } else if (indexPath.section == 4) {//选择门店 养生顾问 预约时间等
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//添加剪头
        
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:subViewTag+1];
        UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
        if([indexPath indexAtPosition:1] == 0){
            //门店
            [imgView setImage:[UIImage imageNamed:@"addr.png"]];
            NSString *text = @"选择门店";
            if (self.bespeakInfoMutdic) {
                NSDictionary *store = [self.bespeakInfoMutdic objectForKey:@"store"];
                text = [store objectForKey:@"name"];
            }
            label.text = text;
        } else if([indexPath indexAtPosition:1] == 1){
            //养生顾问
            [imgView setImage:[UIImage imageNamed:@"master.png"]];
            NSString *text = @"选择养生顾问";
            NSDictionary *masterDic = [self.bespeakInfoMutdic objectForKey:@"master"];
            if (masterDic) {
                text = [masterDic objectForKey:@"name"];
            }
            label.text = text;
        } else if([indexPath indexAtPosition:1] == 2){
            //日期 时间
            [imgView setImage:[UIImage imageNamed:@"time.png"]];
            NSString *text = @"预约时间";
            NSDictionary *d_tDic = [self.bespeakInfoMutdic objectForKey:@"besTime"];
            if (d_tDic) {
                text = [NSString stringWithFormat:@"%@", [d_tDic objectForKey:@"showStr"]];
            }
            label.text = text;
        }
    }
    return cell;
}



#pragma LoginSuccess delegate
-(void)loginSuccess:(UIView*)view{
    if (loginReponseType == 1) {//进入订单确认页面
        if (self.userClickPayButton) {
            if (self.userClickPayButton.tag != FIRST) {
                [self commitForm:userClickPayButton];
            } else {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                if ([userDefaults objectForKey:self.projectId]) {//如果已经购买过首次体验的，则改按钮不可用
                    self.userClickPayButton.backgroundColor = RGBA(180, 180, 180, 255);
                    self.userClickPayButton.userInteractionEnabled = NO;
                } else {
                    [self commitForm:userClickPayButton];
                }
            }
            self.userClickPayButton = nil;
        }
    } else if (loginReponseType == 2) {//继续收藏动作
        [self collectThisProject];
    }
    [self closeLoginView:nil];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
