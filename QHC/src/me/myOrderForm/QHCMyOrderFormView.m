//
//  QHCMyOrderFormView.m
//  QHC
//
//  Created by qhc2015 on 15/6/30.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCMyOrderFormView.h"
#import "AppDelegate.h"
#import "MyAlerView.h"
#import "JSONKit.h"
#import "LoadingView.h"
#import "UIImageView+WebCache.h"
#import "OrderFormDetailViewController.h"
#import "CheckBox.h"
#import "ConfirmOrderViewController.h"

@implementation QHCMyOrderFormView

@synthesize pageScrollView;
@synthesize segmentController;

@synthesize pageTitle;

@synthesize refreshTableView_doing;
@synthesize refreshTableView_waitPay;
@synthesize refreshTableView_all;

@synthesize httpRequest_doing;
@synthesize httpRequest_waitPay;
@synthesize httpRequest_all;

@synthesize selectedOrderListDic;

@synthesize footerView;

-(id)initWithFrame:(CGRect)frame andTitle:(NSString*)title type:(NSInteger)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.pageTitle = title;
        orderType = type;
        
        self.selectedOrderListDic = [[NSMutableDictionary alloc] init];
        
        [self createContentView];
//        [self getContentTableViewInitData:PAGE_DATA_COUNT];
        
        userSelectedTableViewIndex = -1;
    }
    return self;
}

-(void)createContentView {
    [self createSegment];
    
    self.pageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, CONTENT_OFFSET, self.frame.size.width, self.frame.size.height - CONTENT_OFFSET*2)];
    pageScrollView.pagingEnabled = YES;
    pageScrollView.delegate = self;
    [pageScrollView setContentSize:CGSizeMake(pageScrollView.frame.size.width*3, pageScrollView.frame.size.height)];
    [self addSubview:pageScrollView];
    
    self.refreshTableView_doing = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, pageScrollView.frame.size.width, pageScrollView.frame.size.height) rowHeight:-2];
    refreshTableView_doing.delegate = self;
    [refreshTableView_doing setPageDataCount:PAGE_DATA_COUNT];
    refreshTableView_doing.backgroundColor = [UIColor clearColor];
    [pageScrollView addSubview:refreshTableView_doing];
    
    self.refreshTableView_waitPay = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(pageScrollView.frame.size.width, 0.0, pageScrollView.frame.size.width, pageScrollView.frame.size.height - 50) rowHeight:-2];
    refreshTableView_waitPay.delegate = self;
    [refreshTableView_waitPay setPageDataCount:PAGE_DATA_COUNT];
    refreshTableView_waitPay.backgroundColor = [UIColor clearColor];
    [pageScrollView addSubview:refreshTableView_waitPay];
    
    self.refreshTableView_all = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(pageScrollView.frame.size.width*2, 0.0, pageScrollView.frame.size.width, pageScrollView.frame.size.height) rowHeight:-2];
    refreshTableView_all.delegate = self;
    [refreshTableView_all setPageDataCount:PAGE_DATA_COUNT];
    refreshTableView_all.backgroundColor = [UIColor clearColor];
    [pageScrollView addSubview:refreshTableView_all];
}

-(void)createSegment{
    NSArray *segmentArray = [[NSArray alloc] initWithObjects:@"进行中的",  @"待支付", @"全部", nil];
    
    self.segmentController = [[UISegmentedControl alloc] initWithItems:segmentArray];
    segmentController.frame = CGRectMake((self.frame.size.width - 240)/2, (CONTENT_OFFSET - 22)/2, 240, 22.0);
    [segmentController addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segmentController.selectedSegmentIndex = 0;
    segmentController.tintColor = RGBA(157, 80, 147, 255);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, CONTENT_OFFSET)];
    view.backgroundColor = [UIColor tableViewBackgroundColor];
    [view addSubview:segmentController];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, view.frame.size.height-1, view.frame.size.width, 1)];
    line.backgroundColor = RGBA(180, 180, 180, 255);
    [view addSubview:line];
    [self addSubview:view];
}

-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger index = Seg.selectedSegmentIndex;
    userSelectedTableViewIndex = index;
    [self changeShowTableView:index];
}

-(void)changeShowTableView:(NSInteger)index {
    switch (index) {
        case 0:
            [self.pageScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
            break;
        case 1:
            [self.pageScrollView setContentOffset:CGPointMake(pageScrollView.frame.size.width, 0.0) animated:YES];
            break;
        case 2:
            [self.pageScrollView setContentOffset:CGPointMake(pageScrollView.frame.size.width*2, 0.0) animated:YES];
            break;
    }
}


-(void)selectOrder:(CheckBox*)checkBtn {
    NSDictionary *dataDic = [self.refreshTableView_waitPay.tableData objectAtIndex:checkBtn.checkedIndex];
    if ([self.selectedOrderListDic objectForKey:[dataDic objectForKey:@"orderid"]]) {
        [self.selectedOrderListDic removeObjectForKey:[dataDic objectForKey:@"orderid"]];
        [checkBtn setImage:[UIImage imageNamed:@"unCheck.png"] forState:UIControlStateNormal];
    } else {
        [self.selectedOrderListDic setObject:@"1" forKey:[dataDic objectForKey:@"orderid"]];
        [checkBtn setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
    }
}

//批量支付按钮
-(void)addBatchPayButton {
    if (self.refreshTableView_waitPay.tableData && self.refreshTableView_waitPay.tableData.count > 1) {
        if (!self.footerView) {
            self.footerView = [[UIView alloc] initWithFrame:CGRectMake(self.refreshTableView_waitPay.frame.origin.x, self.refreshTableView_waitPay.frame.size.height, self.refreshTableView_waitPay.frame.size.width, 50)];
            footerView.backgroundColor = [UIColor tableViewBackgroundColor];
            
            //批量支付
            UIButton *payBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 10, footerView.frame.size.width - 60, 30)];
            [payBtn setTitle:@"批量支付" forState:UIControlStateNormal];
            payBtn.layer.cornerRadius = 4;
            payBtn.backgroundColor = [UIColor titleBarBackgroundColor];
            [payBtn addTarget:self action:@selector(batchPay:) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:payBtn];
            [self.pageScrollView addSubview:footerView];
        }
    }
}

//批量支付，获取批量支付信息
-(void)batchPay:(id)sender {
    NSArray *keys = [self.selectedOrderListDic allKeys];
    if (keys && keys.count > 1) {
        NSMutableString *mutStr = [[NSMutableString alloc] init];
        for (int i = 0; i < keys.count; i++) {
            NSString *projectId = [keys objectAtIndex:i];
            [mutStr appendString:projectId];
            if (i < keys.count-1) {
                [mutStr appendString:@"|"];
            }
        }
        //创建异步请求
        NSString *urlStr = @"Order/AppendBigOrder.aspx";
        self.httpRequest_all = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userId = [userDefaults stringForKey:@"userId"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:userId forKey:@"userid"];
        [param setObject:mutStr forKey:@"orderidlist"];
        
        [httpRequest_all setDelegate:self];
        //设置请求完成的回调方法
        [httpRequest_all setRequestFinishCallBack:@selector(requestBatchOrderPayFinish:)];
        //设置请求失败的回调方法
        [httpRequest_all setRequestFailCallBack:@selector(requestFail:)];
        
        [httpRequest_all sendHttpRequestByPost:urlStr params:param];
    } else if (keys && keys.count == 1) {
        [[MyAlerView sharedAler] ViewShow:@"请勾选多于1个订单。"];
    } else {
        [[MyAlerView sharedAler] ViewShow:@"请勾选订单。"];
    }
}

-(void)getContentTableViewInitData:(NSInteger)pageDataCount{
    refreshView_doing = YES;
    refreshView_waitPay = YES;
    refreshView_all = YES;
    
    self.refreshTableView_doing.noMoreData = NO;
    self.refreshTableView_waitPay.noMoreData = NO;
    self.refreshTableView_all.noMoreData = NO;
    
    intArray[0] = -1;
    intArray[1] = -1;
    intArray[2] = -1;
    
    [[LoadingView sharedLoadingView] show];
    NSString *pageDataCountStr = [NSString stringWithFormat:@"%ld", pageDataCount];
    
    [self getTableData_doing:@"1" count:pageDataCountStr];
    [self getTableData_all:@"1" count:pageDataCountStr];
    [self getTableData_waitPay:@"1" count:pageDataCountStr];
}

-(void)getTableData_doing:(NSString*)page count:(NSString*)count {
    
    //创建异步请求
    NSString *urlStr = @"Order/List.aspx";
    self.httpRequest_doing = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:page forKey:@"index"];
    [param setObject:count forKey:@"size"];
    [param setObject:@"2" forKey:@"status"];
    
    [httpRequest_doing setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest_doing setRequestFinishCallBack:@selector(requestFinish_doing:)];
    //设置请求失败的回调方法
    [httpRequest_doing setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest_doing sendHttpRequestByPost:urlStr params:param];
}

-(void)getTableData_all:(NSString*)page count:(NSString*)count {
    
    //创建异步请求
    NSString *urlStr = @"Order/List.aspx";
    self.httpRequest_all = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:page forKey:@"index"];
    [param setObject:count forKey:@"size"];
    [param setObject:@"-1" forKey:@"status"];
    
    [httpRequest_all setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest_all setRequestFinishCallBack:@selector(requestFinish_all:)];
    //设置请求失败的回调方法
    [httpRequest_all setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest_all sendHttpRequestByPost:urlStr params:param];
}

-(void)getTableData_waitPay:(NSString*)page count:(NSString*)count {
    
    //创建异步请求
    NSString *urlStr = @"Order/List.aspx";
    self.httpRequest_waitPay = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:page forKey:@"index"];
    [param setObject:count forKey:@"size"];
    [param setObject:@"1" forKey:@"status"];
    
    [httpRequest_waitPay setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest_waitPay setRequestFinishCallBack:@selector(requestFinish_waitPay:)];
    //设置请求失败的回调方法
    [httpRequest_waitPay setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest_waitPay sendHttpRequestByPost:urlStr params:param];
}

#pragma mark ASIHTTPRequestDelegate
//请求失败代理方法
-(void) requestFail:(NSString*) responseStr
{
    [[LoadingView sharedLoadingView] hidden];
    NSLog(@"login request fail error = %@", responseStr);
    [[MyAlerView sharedAler] ViewShow:@"网络异常，请稍后重试"];
}

-(void) requestFinish_doing:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if (refreshView_doing) {
            [self.refreshTableView_doing.tableData removeAllObjects];
        }
        if ([responseInfo objectForKey:@"orderlist"]) {
            NSArray *tableDataList = [responseInfo objectForKey:@"orderlist"];
            [self.refreshTableView_doing appendTableData:tableDataList];
        } else {
            self.refreshTableView_doing.noMoreData = YES;
        }
        [self.refreshTableView_doing reload];
        intArray[0] = (int)self.refreshTableView_doing.tableData.count;
        [self finalShowTableView];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    refreshView_doing = NO;
    [[LoadingView sharedLoadingView] hidden];
}
-(void) requestFinish_all:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if (refreshView_all) {
            [self.refreshTableView_all clearTableData];
        }
        if ([responseInfo objectForKey:@"orderlist"]) {
            NSArray *tableDataList = [responseInfo objectForKey:@"orderlist"];
            [self.refreshTableView_all appendTableData:tableDataList];
        } else {
            self.refreshTableView_all.noMoreData = YES;
        }
        [self.refreshTableView_all reload];
        intArray[2] = (int)self.refreshTableView_all.tableData.count;
        [self finalShowTableView];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    refreshView_all = NO;
    [[LoadingView sharedLoadingView] hidden];
}
-(void) requestFinish_waitPay:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if (refreshView_waitPay) {
            [self.refreshTableView_waitPay clearTableData];
        }
        if ([responseInfo objectForKey:@"orderlist"]) {
            NSArray *tableDataList = [responseInfo objectForKey:@"orderlist"];
            [self.refreshTableView_waitPay appendTableData:tableDataList];
        } else {
            self.refreshTableView_waitPay.noMoreData = YES;
        }
        
        [self.refreshTableView_waitPay reload];
        if (self.refreshTableView_waitPay.tableData.count > 1) {//添加批量支付按钮
            [self addBatchPayButton];
        } else {//如果少于2条待支付的订单，则不显示批量支付按钮
            [self.footerView removeFromSuperview];
            self.footerView = nil;
        }
        intArray[1] = (int)self.refreshTableView_waitPay.tableData.count;
        [self finalShowTableView];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    
    refreshView_waitPay = NO;
    [[LoadingView sharedLoadingView] hidden];
}

-(void) requestBatchOrderPayFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        NSInteger status = ((NSString*)[responseInfo objectForKey:@"status"]).integerValue;
        if (status == 1) {
            [self.selectedOrderListDic removeAllObjects];
            userSelectedTableViewIndex = 1;
            //进入订单确认页面
            ConfirmOrderViewController *cforderViewController = [[ConfirmOrderViewController alloc] initWithOrderInfo:responseInfo];
            AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [appdelegate.myRootController pushViewController:cforderViewController animated:YES];
        } else {
            [[MyAlerView sharedAler] ViewShow:@"获取订单详情失败，请稍候再试"];
        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}


#pragma table delegate

-(float) getTableCellHeight:(NSObject*)cellData {
//    NSDictionary *cellDataDic = (NSDictionary*)cellData;
//    NSInteger status = [((NSString*)[cellDataDic objectForKey:@"status"]) intValue];
//    if (status == -1) {//已取消
        return 106;
//    } else {
//        return 116;
//    }
}

- (void) refreshData:(UITableView*)tableView oldDataCount:(NSInteger)oldDataCount onePageDataCount:(NSInteger)onePageDataCount{
    NSString *pageIndexStr = [NSString stringWithFormat:@"%ld", (oldDataCount / onePageDataCount + 1)];
    NSString *pageDataCountStr = [NSString stringWithFormat:@"%ld", onePageDataCount];
    if (tableView == self.refreshTableView_doing.refreshTableView) {
        [self getTableData_doing:pageIndexStr count:pageDataCountStr];
    } else if (tableView == self.refreshTableView_waitPay.refreshTableView) {
        [self getTableData_waitPay:pageIndexStr count:pageDataCountStr];
    } else if (tableView == self.refreshTableView_all.refreshTableView) {
        [self getTableData_all:pageIndexStr count:pageDataCountStr];
    }
}
- (void) tableView:(UITableView *)tableView didSelectRowData:(NSObject *)selectRowData andIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *selectCellDataDic = (NSDictionary*)selectRowData;
    if (tableView == self.refreshTableView_doing.refreshTableView) {
        userSelectedTableViewIndex = 0;
    } else if (tableView == self.refreshTableView_waitPay.refreshTableView) {
        userSelectedTableViewIndex = 1;
    } else if (tableView == self.refreshTableView_all.refreshTableView) {
        userSelectedTableViewIndex = 2;
    }
    OrderFormDetailViewController *ofDetailController = [[OrderFormDetailViewController alloc] initWithOrderInfo:selectCellDataDic];
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.myRootController pushViewController:ofDetailController animated:YES];
    NSLog(@"selected");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellsData:(NSObject*)cellData cellForRowAtIndex:(NSInteger)index{
    static NSString * showUserInfoCellIdentifier = @"myOrderFormCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];
    if (cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];
        //订单号
        UILabel *labelOrderNO = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, tableView.frame.size.width - 60, 15)];
        [labelOrderNO setTag:105];
        labelOrderNO.textColor = [UIColor grayColor];
        labelOrderNO.font = LABEL_DEFAULT_TEXT_FONT;
        [cell addSubview:labelOrderNO];
        
        //项目图片
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, labelOrderNO.frame.origin.y + labelOrderNO.frame.size.height + 6, 66, 66)];
        [imgView setTag:100];
        [cell addSubview:imgView];
        //项目名字
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 8, imgView.frame.origin.y + 3, tableView.frame.size.width - (imgView.frame.origin.x + imgView.frame.size.width + 8 + 25), 17)];
        [labelName setTag:101];
        labelName.font = LABEL_LARGE_TEXT_FONT;
        labelName.textColor = LABEL_TITLE_TEXT_COLOR;
        [cell addSubview:labelName];
        //需要支付的金额
        UILabel *labelTotalPrice = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelName.frame.origin.y + labelName.frame.size.height + 3, labelName.frame.size.width, 15)];
        [labelTotalPrice setTag:102];
        labelTotalPrice.textColor = [UIColor priceTextColor];
        labelTotalPrice.font = LABEL_DEFAULT_TEXT_FONT;
        [cell addSubview:labelTotalPrice];
        
        //使用状态（如果是未支付 已取消状态 则直接显示状态信息）
        UILabel *payStatus = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelTotalPrice.frame.origin.y + labelTotalPrice.frame.size.height + 8, labelName.frame.size.width, 15)];
        [payStatus setTag:103];
        payStatus.font = LABEL_SMALL_TEXT_FONT;
        payStatus.textColor = RGBA(180, 0, 190, 255);
        [cell addSubview:payStatus];
        if (tableView == self.refreshTableView_waitPay.refreshTableView) {
            CheckBox *checkBox = [[CheckBox alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 68, -6, 50, 50)];
            [checkBox setTag:104];
            [cell addSubview:checkBox];
        }
        
//        //预约信息 包括上一次预约的门店 养生顾问 以及默认的写一次预约时间 如果未支付，则是需要支付的金额信息 如果是已取消订单 则不显示一下两项
//        UILabel *labelBesInfo = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x, imgView.frame.origin.y + imgView.frame.size.height + 10, tableView.frame.size.width - imgView.frame.origin.x - 115, 15)];
//        [labelBesInfo setTag:104];
//        labelBesInfo.textAlignment = NSTextAlignmentRight;
//        labelBesInfo.font = [UIFont systemFontOfSize:14];
//        [cell addSubview:labelBesInfo];
//        //一键预约按钮
//        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 110, labelBesInfo.frame.origin.y - 8, 90, 28)];
//        [button setTitleColor:RGBA(190, 31, 193, 255) forState:UIControlStateNormal];
//        button.titleLabel.font = [UIFont systemFontOfSize:14];
//        [button setTag:105];
//        [button setBackgroundImage:[UIImage imageNamed:@"changeBtnBg.png"] forState:UIControlStateNormal];
//        [cell addSubview:button];
        
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//添加向右剪头
    cell.backgroundColor = [UIColor tableViewBackgroundColor];
    
    if (cellData && [cellData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *cellDataDic = (NSDictionary*)cellData;
        //项目图片
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:100];
        [imgView sd_setImageWithURL:[NSURL URLWithString:[cellDataDic objectForKey:@"img"]] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
        //项目名字
        UILabel *labelName = (UILabel*)[cell viewWithTag:101];
        labelName.text = [cellDataDic objectForKey:@"projectname"];
        //总价
        UILabel *labelTotalPrice = (UILabel*)[cell viewWithTag:102];
        NSString *labelBuyCountStr = [NSString stringWithFormat:@"¥%.2f元", ((NSString*)[cellDataDic objectForKey:@"realpay"]).floatValue];
        NSString *orderid = [cellDataDic objectForKey:@"orderid"];
        if ([orderid rangeOfString:@"P"].location != NSNotFound) {//如果是家具产品，则显示购买数量
            NSInteger number = ((NSString*)[cellDataDic objectForKey:@"number"]).integerValue;
            if ([@"10200005" isEqualToString:[cellDataDic objectForKey:@"projectid"]]) {//奥玛面膜
                labelBuyCountStr = [NSString stringWithFormat:@"%@/%lu盒", labelBuyCountStr, number/28];
            } else {
                labelBuyCountStr = [NSString stringWithFormat:@"%@/%lu瓶", labelBuyCountStr, number];
            }
        }
        labelTotalPrice.text = labelBuyCountStr;
        //使用状态（如果是未支付 已取消状态 则直接显示状态信息）
        UILabel *payStatus = (UILabel*)[cell viewWithTag:103];
        //预约信息 包括上一次预约的门店 养生顾问 以及默认的写一次预约时间 如果未支付，则是需要支付的金额信息 如果是已取消订单 则不显示
//        UILabel *labelBesInfo = (UILabel*)[cell viewWithTag:104];
        //一键预约按钮  如果是已取消订单 则不显示
//        UIButton *button = (UIButton*)[cell viewWithTag:105];
        NSString *statusStr = (NSString*)[cellDataDic objectForKey:@"status"];
        if (statusStr && (id)statusStr != [NSNull null]) {
            NSInteger status = [statusStr intValue];
            if (status == CANCEL) {//已取消
                cell.userInteractionEnabled = NO;
                cell.accessoryType = UITableViewAutomaticDimension;//移除向右剪头  已取消订单无详情
                statusStr = @"已取消";
            } else if (status == 2) {//已支付
                NSString *orderid = [cellDataDic objectForKey:@"orderid"];
                if ([orderid rangeOfString:@"P"].location != NSNotFound) {//如果是家具产品，则只显示是否已支付
                    statusStr = @"已支付";
                } else {
                    NSInteger remaining = ((NSString*)[cellDataDic objectForKey:@"remaining"]).integerValue;
                    NSInteger used = ((NSString*)[cellDataDic objectForKey:@"number"]).integerValue - remaining;
                    NSString *str = (NSString*)[cellDataDic objectForKey:@"reservationnumber"];
                    NSInteger reservationNumber = str.integerValue;
                    statusStr = [NSString stringWithFormat:@"服务完成%lu次，剩余:%lu次(已预约%d次)", (long)used, (long)remaining, reservationNumber];
                }
            } else if (status == 1) {//未支付
                statusStr = @"未支付";
            } else if (status == 4) {//已完成
                NSString *orderid = [cellDataDic objectForKey:@"orderid"];
                if ([orderid rangeOfString:@"P"].location != NSNotFound) {//如果是家具产品
                    statusStr = @"已领取";
                } else {
                    statusStr = @"已完成";
                }
            } else if (status == 10) {
                cell.userInteractionEnabled = NO;
                cell.accessoryType = UITableViewAutomaticDimension;//移除向右剪头  已取消订单无详情
                statusStr = @"等待商家确认支付信息";
            }
            payStatus.text = statusStr;
        }
        
        if (tableView == self.refreshTableView_waitPay.refreshTableView) {
            CheckBox *checkBox = (CheckBox*)[cell viewWithTag:104];
            checkBox.checkedIndex = index;
            if (self.selectedOrderListDic && [self.selectedOrderListDic allKeys].count > 0) {
                if ([self.selectedOrderListDic objectForKey:[cellDataDic objectForKey:@"orderid"]]) {
                    [checkBox setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
                } else {
                    [checkBox setImage:[UIImage imageNamed:@"unCheck.png"] forState:UIControlStateNormal];
                }
            } else {
                checkBox.isChecked = NO;
                [checkBox setImage:[UIImage imageNamed:@"unCheck.png"] forState:UIControlStateNormal];
            }
            [checkBox addTarget:self action:@selector(selectOrder:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //订单号
        UILabel *labelOrderNO = (UILabel*)[cell viewWithTag:105];
        labelOrderNO.text = [NSString stringWithFormat:@"订单号：%@", [cellDataDic objectForKey:@"orderid"]];
    }
    
    
    return cell;
}


#pragma UIScrollViewDelegate
// 滚动视图减速完成，滚动将停止时，调用该方法。一次有效滑动，只执行一次。
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //    NSLog([NSString stringWithFormat:@"scrollViewDidEndDecelerating scrollView.x = %f", scrollView.contentOffset.x]);
    NSInteger selectedIndex = (NSInteger)(scrollView.contentOffset.x / scrollView.frame.size.width);
    self.segmentController.selectedSegmentIndex = selectedIndex;
}


//该方法决定最终停留在哪个界面
-(void)finalShowTableView{
    if (userSelectedTableViewIndex != -1) {
        if (intArray[userSelectedTableViewIndex] > 0) {
            return;
        }
    }
    if (intArray[0] >= 0 && intArray[1] >= 0 && intArray[2] >= 0) {
        if (intArray[0] > 0) {
            self.segmentController.selectedSegmentIndex = 0;
            [self changeShowTableView:0];
        } else if (intArray[1] > 0) {
            self.segmentController.selectedSegmentIndex = 1;
            [self changeShowTableView:1];
        } else {
            self.segmentController.selectedSegmentIndex = 2;
            [self changeShowTableView:2];
        }
    }
}
@end
