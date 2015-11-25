//
//  QHCBespeakView.m
//  QHC
//
//  Created by qhc2015 on 15/6/5.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCBespeakView.h"
#import "UIImageView+WebCache.h"
#import "MyAlerView.h"
#import "LoadingView.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "QHCBespeakDetailViewController.h"

@implementation QHCBespeakView

@synthesize scrollView;

@synthesize contentView;

@synthesize httpRequest1;
@synthesize httpRequest2;
@synthesize httpRequest3;

@synthesize tabItem1;
@synthesize tabItem2;
@synthesize tabItem3;

@synthesize tableWaitToCarryOn;
@synthesize tableWaitToEvaluation;
@synthesize tableAllBespeakOrder;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createContentView];
        [self changeTabItemStatus:1];
        userSelectedTableViewIndex = -1;
        [self getContentTableViewInitData:PAGE_DATA_COUNT];
    }
    return self;
}

//创建内容视图
-(void)createContentView {
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:contentView];
    
    //创建tab选项菜单
    [self createTabItem:contentView];
    
    [self createBespeakListView:contentView yOffset:35];
}

-(UIView*)makeTabItemSelectedSign:(CGRect)frame bColor:(UIColor*)backColor tag:(NSInteger)viewTag{
    UIView *bView = [[UIView alloc] initWithFrame:frame];
    bView.backgroundColor = backColor;
    [bView setTag:viewTag];
    return bView;
}

//创建tab选项菜单
-(void)createTabItem:(UIView*) superView {
    float v_h = 35.0;
    UIView *tabItemSuperView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, superView.frame.size.width, v_h)];
    [superView addSubview:tabItemSuperView];
    
    UIFont *font = BUTTON_TEXT_FONT;
    
    self.tabItem1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/3, v_h)];
    [tabItem1 setTitle:@"待进行" forState:UIControlStateNormal];
    [tabItem1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [tabItem1 setTag:10001];
    tabItem1.titleLabel.font = font;
    [tabItem1 setTitleColor:LABEL_DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
    [tabItem1 addTarget:self action:@selector(tabItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [tabItemSuperView addSubview:tabItem1];
    UIView *selectedView = [self makeTabItemSelectedSign:CGRectMake(tabItem1.frame.origin.x + 10, tabItem1.frame.origin.y + tabItem1.frame.size.height - 2, tabItem1.frame.size.width - 20, 2) bColor:[UIColor clearColor] tag:1001];
    [tabItemSuperView addSubview:selectedView];
    
    self.tabItem2 = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/3, 0, self.frame.size.width/3, v_h)];
    [tabItem2 setTitle:@"待评价" forState:UIControlStateNormal];
    [tabItem2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [tabItem2 setTag:10002];
    tabItem2.titleLabel.font = font;
    [tabItem2 setTitleColor:LABEL_DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
    [tabItem2 addTarget:self action:@selector(tabItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [tabItemSuperView addSubview:tabItem2];
    selectedView = [self makeTabItemSelectedSign:CGRectMake(tabItem2.frame.origin.x + 10, tabItem2.frame.origin.y + tabItem2.frame.size.height - 2, tabItem2.frame.size.width - 20, 2) bColor:[UIColor clearColor] tag:1002];
    [tabItemSuperView addSubview:selectedView];
    
    self.tabItem3 = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width*2/3, 0, self.frame.size.width/3, v_h)];
    [tabItem3 setTitle:@"全    部" forState:UIControlStateNormal];
    [tabItem3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [tabItem3 setTag:10003];
    tabItem3.titleLabel.font = font;
    [tabItem3 setTitleColor:LABEL_DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
    [tabItem3 addTarget:self action:@selector(tabItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [tabItemSuperView addSubview:tabItem3];
    selectedView = [self makeTabItemSelectedSign:CGRectMake(tabItem3.frame.origin.x + 10, tabItem3.frame.origin.y + tabItem3.frame.size.height - 2, tabItem3.frame.size.width - 20, 2) bColor:[UIColor clearColor] tag:1003];
    [tabItemSuperView addSubview:selectedView];
    
}

//创建预约项目列表
-(void) createBespeakListView:(UIView*)superView yOffset:(float)y {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, superView.frame.size.width, superView.frame.size.height - (49 + y))];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;

    float rowHeight = 95;
    //待进行
    self.tableWaitToCarryOn = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height) rowHeight:rowHeight];
    tableWaitToCarryOn.delegate = self;
    [tableWaitToCarryOn setPageDataCount:PAGE_DATA_COUNT];
    tableWaitToCarryOn.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:tableWaitToCarryOn];
    //待评价
    self.tableWaitToEvaluation = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height) rowHeight:rowHeight];
    tableWaitToEvaluation.delegate = self;
    [tableWaitToEvaluation setPageDataCount:PAGE_DATA_COUNT];
    tableWaitToEvaluation.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:tableWaitToEvaluation];
    //全部
    self.tableAllBespeakOrder = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width*2, 0, scrollView.frame.size.width, scrollView.frame.size.height) rowHeight:rowHeight];
    tableAllBespeakOrder.delegate = self;
    [tableAllBespeakOrder setPageDataCount:PAGE_DATA_COUNT];
    tableAllBespeakOrder.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:tableAllBespeakOrder];
    
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width*3, scrollView.frame.size.height)];
    
    [superView addSubview:scrollView];
}

-(void) changeTabItemStatus:(NSInteger)selected{
    [tabItem1 setTitleColor:[UIColor buttonTitleColor_1] forState:UIControlStateNormal];
    [tabItem2 setTitleColor:[UIColor buttonTitleColor_1] forState:UIControlStateNormal];
    [tabItem3 setTitleColor:[UIColor buttonTitleColor_1] forState:UIControlStateNormal];
    [contentView viewWithTag:1001].backgroundColor = [UIColor clearColor];
    [contentView viewWithTag:1002].backgroundColor = [UIColor clearColor];
    [contentView viewWithTag:1003].backgroundColor = [UIColor clearColor];
    [contentView viewWithTag:1000+selected].backgroundColor = [UIColor titleBarBackgroundColor];
    switch (selected) {
        case 1:
            [tabItem1 setTitleColor:[UIColor titleBarBackgroundColor] forState:UIControlStateNormal];
            break;
        case 2:
            [tabItem2 setTitleColor:[UIColor titleBarBackgroundColor] forState:UIControlStateNormal];
            break;
        case 3:
            [tabItem3 setTitleColor:[UIColor titleBarBackgroundColor] forState:UIControlStateNormal];
            break;
    }
    
    [scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * (selected - 1), 0) animated:YES];
}

#pragma tabItem action
-(void)tabItemAction:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        userSelectedTableViewIndex = (int)(btn.tag - 10000);
        [self changeTabItemStatus:btn.tag - 10000];
//        switch (btn.tag) {
//            case 10001:
//                [self changeTabItemStatus:1];
//                break;
//            case 10002:
//                [self changeTabItemStatus:2];
//                break;
//            case 10003:
//                [self changeTabItemStatus:3];
//                break;
//        }
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)getContentTableViewInitData:(NSInteger)pageDataCount{
    refreshTableWaitToCarryOn = YES;
    refreshTableWaitToEvaluation = YES;
    refreshTableAllBespeakOrder = YES;
    
    self.tableWaitToCarryOn.noMoreData = NO;
    self.tableWaitToEvaluation.noMoreData = NO;
    self.tableAllBespeakOrder.noMoreData = NO;
    
    intArray[0] = -1;
    intArray[1] = -1;
    intArray[2] = -1;
    
    [[LoadingView sharedLoadingView] show];
    NSString *pageDataCountStr = [NSString stringWithFormat:@"%ld", pageDataCount];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:@"userId"];
    
    [self getTableCarryOnData:@"1" count:pageDataCountStr userId:userId];
    [self getTableEvaluationData:@"1" count:pageDataCountStr userId:userId];
    [self getTableAllData:@"1" count:pageDataCountStr userId:userId];
    
    if ([userDefaults objectForKey:NOT_RESERVATION]) {//还有未评价的预约单
        [self changeTabItemStatus:2];
    }
}

//待进行
-(void)getTableCarryOnData:(NSString*)page count:(NSString*)count userId:(NSString*)user_id {
    
    //创建异步请求
    NSString *urlStr = @"Reservation/List.aspx";
    self.httpRequest1 = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:user_id forKey:@"userid"];
    [param setObject:@"*" forKey:@"orderid"];
    [param setObject:@"2" forKey:@"status"];
    [param setObject:page forKey:@"index"];
    [param setObject:count forKey:@"size"];
    
    [httpRequest1 setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest1 setRequestFinishCallBack:@selector(requestFinish_CarryOn:)];
    //设置请求失败的回调方法
    [httpRequest1 setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest1 sendHttpRequestByPost:urlStr params:param];
}

//待评价 已执行的
-(void)getTableEvaluationData:(NSString*)page count:(NSString*)count userId:(NSString*)user_id {
    
    //创建异步请求
    NSString *urlStr = @"Reservation/List.aspx";
    self.httpRequest2 = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:user_id forKey:@"userid"];
    [param setObject:@"*" forKey:@"orderid"];
    [param setObject:@"3" forKey:@"status"];
    [param setObject:page forKey:@"index"];
    [param setObject:count forKey:@"size"];
    
    [httpRequest2 setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest2 setRequestFinishCallBack:@selector(requestFinish_Evaluation:)];
    //设置请求失败的回调方法
    [httpRequest2 setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest2 sendHttpRequestByPost:urlStr params:param];
}

-(void)getTableAllData:(NSString*)page count:(NSString*)count userId:(NSString*)user_id {
    
    //创建异步请求
    NSString *urlStr = @"Reservation/List.aspx";
    self.httpRequest3 = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:user_id forKey:@"userid"];
    [param setObject:@"*" forKey:@"orderid"];
    [param setObject:@"-1" forKey:@"status"];
    [param setObject:page forKey:@"index"];
    [param setObject:count forKey:@"size"];
    
    [httpRequest3 setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest3 setRequestFinishCallBack:@selector(requestFinish_All:)];
    //设置请求失败的回调方法
    [httpRequest3 setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest3 sendHttpRequestByPost:urlStr params:param];
}

#pragma mark ASIHTTPRequestDelegate
//请求失败代理方法
-(void) requestFail:(NSString*) responseStr
{
    [[LoadingView sharedLoadingView] hidden];
    NSLog(@"login request fail error = %@", responseStr);
    [[MyAlerView sharedAler] ViewShow:@"网络异常，请稍后重试"];
}

-(void) requestFinish_CarryOn:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if (refreshTableWaitToCarryOn) {
            [self.tableWaitToCarryOn.tableData removeAllObjects];
        }
        if ([responseInfo objectForKey:@"reservationlist"]) {
            NSArray *tableDataList = [responseInfo objectForKey:@"reservationlist"];
            [self.tableWaitToCarryOn appendTableData:tableDataList];
        } else {
            self.tableWaitToCarryOn.noMoreData = YES;
        }
        [self.tableWaitToCarryOn reload];
        intArray[0] = (int)self.tableWaitToCarryOn.tableData.count;
        [self finalShowTableView];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    refreshTableWaitToCarryOn = NO;
    [[LoadingView sharedLoadingView] hidden];
}
-(void) requestFinish_Evaluation:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if (refreshTableWaitToEvaluation) {
            [self.tableWaitToEvaluation.tableData removeAllObjects];
        }
        if ([responseInfo objectForKey:@"reservationlist"]) {
            NSArray *tableDataList = [responseInfo objectForKey:@"reservationlist"];
            [self.tableWaitToEvaluation appendTableData:tableDataList];
            [userDefaults setObject:@"true" forKey:NOT_RESERVATION];
        } else {
            self.tableWaitToEvaluation.noMoreData = YES;
        }
        [self.tableWaitToEvaluation reload];
        intArray[1] = (int)self.tableWaitToEvaluation.tableData.count;
        if (intArray[1] <= 0) {//没有未评价的预约单了
            [userDefaults removeObjectForKey:NOT_RESERVATION];
        }
        [self finalShowTableView];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    refreshTableWaitToEvaluation = NO;
}
-(void) requestFinish_All:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if (refreshTableAllBespeakOrder) {
            [self.tableAllBespeakOrder.tableData removeAllObjects];
        }
        if ([responseInfo objectForKey:@"reservationlist"]) {
            NSArray *tableDataList = [responseInfo objectForKey:@"reservationlist"];
            [self.tableAllBespeakOrder appendTableData:tableDataList];
        } else {
            self.tableAllBespeakOrder.noMoreData = YES;
        }
        [self.tableAllBespeakOrder reload];
        intArray[2] = (int)self.tableAllBespeakOrder.tableData.count;
        [self finalShowTableView];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    refreshTableAllBespeakOrder = NO;
}

#pragma table delegate

- (void) refreshData:(UITableView*)tableView oldDataCount:(NSInteger)oldDataCount onePageDataCount:(NSInteger)onePageDataCount{
    NSString *pageIndexStr = [NSString stringWithFormat:@"%ld", (oldDataCount / onePageDataCount + 1)];
    NSString *pageDataCountStr = [NSString stringWithFormat:@"%ld", onePageDataCount];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:@"userId"];
    if (tableView == self.tableWaitToCarryOn.refreshTableView) {
        [self getTableCarryOnData:pageIndexStr count:pageDataCountStr userId:userId];
    } else if (tableView == self.tableWaitToEvaluation.refreshTableView) {
        [self getTableEvaluationData:pageIndexStr count:pageDataCountStr userId:userId];
    } else if (tableView == self.tableAllBespeakOrder.refreshTableView) {
        [self getTableAllData:pageIndexStr count:pageDataCountStr userId:userId];
    }
}
- (void) tableView:(UITableView *)tableView didSelectRowData:(NSObject *)selectRowData andIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *selectCellDataDic = (NSDictionary*)selectRowData;
    NSInteger status = ((NSString*)[selectCellDataDic objectForKey:@"status"]).intValue;
    if(status == CANCEL) {
        [[MyAlerView sharedAler] ViewShow:@"该订单已取消"];
    } else {
        if (tableView == self.tableWaitToCarryOn.refreshTableView) {
            userSelectedTableViewIndex = 1;
        } else if (tableView == self.tableWaitToEvaluation.refreshTableView) {
            userSelectedTableViewIndex = 2;
        } else if (tableView == self.tableAllBespeakOrder.refreshTableView) {
            userSelectedTableViewIndex = 3;
        }
        QHCBespeakDetailViewController *viewController = [[QHCBespeakDetailViewController alloc] initWithData:selectCellDataDic];
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [delegate.myRootController pushViewController:viewController animated:YES];
    }
    NSLog(@"selected");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellsData:(NSObject*)cellData cellForRowAtIndex:(NSInteger)index{
    static NSString * showUserInfoCellIdentifier = @"showMoreInfo";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];
    if (cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];
        
        //预约单号
        UILabel *labelOrderNO = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, tableView.frame.size.width - 60, 15)];
        [labelOrderNO setTag:105];
        labelOrderNO.textColor = [UIColor grayColor];
        labelOrderNO.font = LABEL_DEFAULT_TEXT_FONT;
        [cell addSubview:labelOrderNO];
        //
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(labelOrderNO.frame.origin.x, labelOrderNO.frame.origin.y + labelOrderNO.frame.size.height + 6, 50, 50)];
        [imageView setTag:100];
        [cell addSubview:imageView];
        //
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 5, imageView.frame.origin.y + 2, tableView.frame.size.width - (imageView.frame.origin.x + imageView.frame.size.width + 5 + 30), 16)];
        [labelName setTag:101];
        labelName.font = LABEL_LARGE_TEXT_FONT;
        labelName.textColor = LABEL_DEFAULT_TEXT_COLOR;
        [cell addSubview:labelName];
        //
        UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelName.frame.origin.y + labelName.frame.size.height + 8, labelName.frame.size.width, 14)];
        [labelTime setTag:103];
        labelTime.font = LABEL_DEFAULT_TEXT_FONT;
        labelTime.textColor = LABEL_GRAY_TEXT_COLOR;
        [cell addSubview:labelTime];
        //
        UILabel *labelStatus = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelTime.frame.origin.y +labelTime.frame.size.height + 4, labelName.frame.size.width, 14)];
        [labelStatus setTag:104];
        labelStatus.textColor = [UIColor priceTextColor];
        labelStatus.font = LABEL_SMALL_TEXT_FONT;
        [cell addSubview:labelStatus];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//添加向右剪头
    cell.backgroundColor = [UIColor tableViewBackgroundColor];
    
    if (cellData && [cellData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *cellDataDic = (NSDictionary*)cellData;
        
        //预约单号
        UILabel *labelOrderNO = (UILabel*)[cell viewWithTag:105];
        labelOrderNO.text = [NSString stringWithFormat:@"预约单号：%@", [cellDataDic objectForKey:@"reservationid"]];
        
        UIImageView *headImgView = (UIImageView*)[cell viewWithTag:100];
        //使用SDWebImage图片缓存
        [headImgView sd_setImageWithURL:[cellDataDic objectForKey:@"img"] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
        
        UILabel *labelName = (UILabel*)[cell viewWithTag:101];
        NSString *name_store = [NSString stringWithFormat:@"%@-%@", [cellDataDic objectForKey:@"projectname"], [cellDataDic objectForKey:@"salername"]];
        labelName.text = name_store;
//        UILabel *labelStore = (UILabel*)[cell viewWithTag:102];
//        labelStore.text = [cellDataDic objectForKey:@"shopname"];
        UILabel *labelTime = (UILabel*)[cell viewWithTag:103];
        labelTime.text = [NSString stringWithFormat:@"预约时间：%@ %@", [cellDataDic objectForKey:@"date"], [cellDataDic objectForKey:@"time"]];
        UILabel *labelStatus = (UILabel*)[cell viewWithTag:104];
        NSInteger status = ((NSString*)[cellDataDic objectForKey:@"status"]).intValue;
        if(status == CANCEL){//预约已取消
            labelStatus.text = @"已取消";
        } else if (status == WAIT_CONFIRM) {//等待养生顾问确认
//            labelStatus.text = @"等待确认";
        } else if (status == CONFIRMED) {//养生顾问已确认
            labelStatus.text = @"待进行";
        } else if (status == WAIT_COMMENT) {//已经使用了 但还没评价
            labelStatus.text = @"去评价";
        } else if (status == COMMENTED) {//已经评价了
            labelStatus.text = @"已完成";
        }
        
    }
    
    
    return cell;
}

#pragma UIScrollViewDelegate
// 滚动视图减速完成，滚动将停止时，调用该方法。一次有效滑动，只执行一次。
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scView{
//    NSLog([NSString stringWithFormat:@"scrollViewDidEndDecelerating scrollView.x = %f", scrollView.contentOffset.x]);
    NSInteger selectedIndex = (NSInteger)(scView.contentOffset.x / 320 + 1);
    [self changeTabItemStatus:selectedIndex];
}


//该方法决定最终停留在哪个界面
-(void)finalShowTableView{
    if (userSelectedTableViewIndex != -1) {
        if (intArray[userSelectedTableViewIndex-1] > 0) {
            return;
        }
    }
    if (intArray[0] >= 0 && intArray[1] >= 0 && intArray[2] >= 0) {
        if (intArray[0] > 0) {
            [self changeTabItemStatus:1];
        } else if (intArray[1] > 0) {
            [self changeTabItemStatus:2];
        } else {
            [self changeTabItemStatus:3];
        }
    }
}
@end
