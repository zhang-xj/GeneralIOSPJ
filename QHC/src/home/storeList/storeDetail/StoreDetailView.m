//
//  StoreDetailView.m
//  QHC
//
//  Created by qhc2015 on 15/7/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "StoreDetailView.h"
#import "MyAlerView.h"
#import "LoadingView.h"
#import "JSONKit.h"
#import "QHCProjectListViewController.h"
#import "QHCProjectDetailViewController.h"
#import "AppDelegate.h"
#import "BWMCoverView.h"
#import "UIImageView+WebCache.h"
#import "MapViewController.h"
#import "MasterDetailViewController.h"

@implementation StoreDetailView

@synthesize myTableView;
@synthesize storeId;
@synthesize storeName;
@synthesize httpRequest;
@synthesize tableData;
@synthesize headView;

-(id)initWithFrame:(CGRect)frame andStoreName:(NSString*)name storeID:(NSString*)index {
    self = [super initWithFrame:frame];
    if (self) {
        self.storeId = index;
        self.storeName = name;
        
        [self getStoreDetailData];
        
        [self createHeadView];
        
    }
    return self;
}

-(void)createTableView {
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    self.myTableView.backgroundColor = [UIColor clearColor];
    [self addSubview:myTableView];
    self.myTableView.tableHeaderView = self.headView;
}

-(void)createHeadView {
    // 此数组用来保存BWMCoverViewModel
    NSMutableArray *realArray = [[NSMutableArray alloc] init];
    //pragma mark -- 可以通过更改 i 值来 改变图片滚动的数量
    for (int i = 0; i<3; i++) {
        NSString *imageStr = [NSString stringWithFormat:@"%@Image/ClientImage/storeDetailLogo%d.png", BASE_URL, i+1];
        //        NSString *imageStr = [NSString stringWithFormat:@"cover_image%d.png", i+1];
        [realArray addObject:imageStr];
    }
    
    /**
     * 快速创建BWMCoverView
     * models是一个包含BWMCoverViewModel的数组
     * placeholderImageNamed为图片加载前的本地占位图片名
     */
    CGRect cvFrame = CGRectMake(0.0, 0.0, self.frame.size.width, COVER_VIEW_H*(self.frame.size.width/320.0));
    BWMCoverView *coverView = [BWMCoverView coverViewWithModels:realArray andFrame:cvFrame andPlaceholderImageNamed:@"default_detail_img.png" andClickdCallBlock:^(NSInteger index) {
        
    }];
    
    // 滚动视图每一次滚动都会回调此方法
    [coverView setScrollViewCallBlock:^(NSInteger index) {
        //NSLog(@"当前滚动到第%d个页面", index);
    }];
    
    // 请打开下面的东西逐个调试
    [coverView setAutoPlayWithDelay:2.0]; // 设置自动播放
    
    self.headView = [[UIView alloc] initWithFrame:CGRectMake(cvFrame.origin.x, cvFrame.origin.y, cvFrame.size.width, cvFrame.size.height + 26)];
    [self.headView addSubview:coverView];
    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(15.0, cvFrame.origin.y + cvFrame.size.height + 3, 100, 18)];
    labelName.font = [UIFont boldSystemFontOfSize:16];
    labelName.text = self.storeName;
    [self.headView addSubview:labelName];
}

-(void)getStoreDetailData {
    //创建异步请求
    NSString *urlStr = @"Shop/Details.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:self.storeId forKey:@"shopid"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}
#pragma mark ASIHTTPRequestDelegate 异步请求代理方法--->请求代理方法
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
        self.tableData = responseInfo;
        [self createTableView];
        [self.myTableView reloadData];
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
    }
    return 5.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{//修改group之间的间距
    return 5.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//点击后恢复原有背景状态
    NSInteger allCellCount = 3;
    if (self.tableData) {
        if ([self.tableData objectForKey:@"salerlist"]) {
            allCellCount = ((NSArray *)[self.tableData objectForKey:@"salerlist"]).count + 3;
        }
        if ([indexPath indexAtPosition:1] == 0) {
            //进入地图
            //门店名 门店地址 纬度 经度
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[self.tableData objectForKey:@"name"], [self.tableData objectForKey:@"address"], [self.tableData objectForKey:@"positiony"], [self.tableData objectForKey:@"positionx"], nil] forKeys:[NSArray arrayWithObjects:@"name", @"addr", @"latitude", @"longitude", nil]];
            MapViewController *mapViewController = [[MapViewController alloc] initWithProperty:dic];
            AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
            [appDelegate.myRootController pushViewController:mapViewController animated:YES];
        } else if ([indexPath indexAtPosition:1] < allCellCount - 2) {
            NSDictionary *selectCellDataDic = [((NSArray *)[self.tableData objectForKey:@"salerlist"]) objectAtIndex:[indexPath indexAtPosition:1]-1];
            AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
            MasterDetailViewController *mdvController = [[MasterDetailViewController alloc] initWithData:selectCellDataDic];
            [appDelegate.myRootController pushViewController:mdvController animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
    NSInteger allCellCount = 2;
    if (self.tableData) {
        if ([self.tableData objectForKey:@"salerlist"]) {
            allCellCount = ((NSArray *)[self.tableData objectForKey:@"salerlist"]).count + 2;
        }
        if ([indexPath indexAtPosition:1] == 0) {
            NSString *adrStr = [NSString stringWithFormat:@"地址：%@", [self.tableData objectForKey:@"address"]];
            CGSize size = [AppDelegate getStringInLabelSize:adrStr andFont:[UIFont systemFontOfSize:13] andLabelWidth:tableView.frame.size.width-45];
            return size.height + 35;
        } else if ([indexPath indexAtPosition:1] < allCellCount - 1) {
            return 86;
        } else {//门店荣誉 介绍
            NSString *adrStr;
            if ([indexPath indexAtPosition:1] == allCellCount - 1) {
//                adrStr = [self.tableData objectForKey:@"honor"];
                adrStr = [self.tableData objectForKey:@"content"];
            } else {
//                adrStr = [self.tableData objectForKey:@"content"];
            }
            if (!adrStr || (id)adrStr == [NSNull null]) {
                adrStr = @"-";
            }
            CGSize size = [AppDelegate getStringInLabelSize:adrStr andFont:[UIFont systemFontOfSize:13] andLabelWidth:tableView.frame.size.width-30];
            
            return size.height + 35;
        }
    }
    return 38;
}

#pragma table dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.tableData objectForKey:@"salerlist"]) {
        return ((NSArray *)[self.tableData objectForKey:@"salerlist"]).count + 2;
    }
    return 2;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * showUserInfoCellIdentifier = [NSString stringWithFormat:@"storeDetailCell%ld%lu", (long)indexPath.section, (unsigned long)[indexPath indexAtPosition:1]] ;
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];

    NSInteger allCellCount = 2;
    if ([self.tableData objectForKey:@"salerlist"]) {
        allCellCount = ((NSArray *)[self.tableData objectForKey:@"salerlist"]).count + 2;
    }
    NSInteger subViewTag = (indexPath.section + 3) * 100 + [indexPath indexAtPosition:1];
    if (cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];
        float l_r_pading = 15.0;

        if ([indexPath indexAtPosition:1] == 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l_r_pading, 10, tableView.frame.size.width - 45, 15)];
            [label setTag:subViewTag];
            label.numberOfLines = 0;
            [cell addSubview:label];
            label.font = [UIFont systemFontOfSize:13];
            
            UILabel *labelPhone = [[UILabel alloc] initWithFrame:CGRectMake(l_r_pading, label.frame.origin.y + label.frame.size.height + 3, tableView.frame.size.width - 45, 15)];
            [labelPhone setTag:subViewTag+1];
            [cell addSubview:labelPhone];
            labelPhone.font = [UIFont systemFontOfSize:13];
        } else if ([indexPath indexAtPosition:1] < allCellCount - 1) {
            float cellHeight = 86;
            UIFont *font = [UIFont systemFontOfSize:14];
            // Create a cell to display an ingredient.
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:showUserInfoCellIdentifier];
            //头像
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(l_r_pading, (cellHeight - 60)/2, 60, 60)];
            [imageView setTag:100];
            [cell addSubview:imageView];
            //名字
            UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 10, imageView.frame.origin.y, 200, 20)];
            [labelName setTag:101];
            labelName.font = [UIFont boldSystemFontOfSize:14];
            [cell addSubview:labelName];
            //星星
            UIImage *star = [UIImage imageNamed:@"start_master.png"];
            for (int i = 0; i < 5; i++) {
                UIImageView *starsImg = [[UIImageView alloc] initWithFrame:CGRectMake(labelName.frame.origin.x + i*25, labelName.frame.origin.y + labelName.frame.size.height + 2, 20, 20)];
                [starsImg setImage:star];
                starsImg.hidden = YES;
                [starsImg setTag:(160+i)];
                [cell addSubview:starsImg];
            }
            //
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, cellHeight - 32, tableView.frame.size.width - labelName.frame.origin.x - 35, 18)];
            [cell addSubview:view];
            
            UIImageView *signImg = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 4, 13.5, 13.5)];
            [signImg setImage:[UIImage imageNamed:@"serviceNum.png"]];
            [view addSubview:signImg];
            
            font = [UIFont systemFontOfSize:12];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(signImg.frame.origin.x + signImg.frame.size.width + 3, 1.0, view.frame.size.width / 2 - (signImg.frame.origin.x + signImg.frame.size.width + 3), 20)];
            [label setTag:104];
            label.font = font;
            [view addSubview:label];
            
            signImg = [[UIImageView alloc] initWithFrame:CGRectMake(label.frame.origin.x + label.frame.size.width, 4.0, 13.5, 13.5)];
            [signImg setImage:[UIImage imageNamed:@"evaluateSign.png"]];
            [view addSubview:signImg];
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(signImg.frame.origin.x + signImg.frame.size.width + 3, 1.0, view.frame.size.width / 2, 20)];
            [label setTag:106];
            label.font = font;
            [view addSubview:label];
        } else {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(l_r_pading, 5, 100, 14)];
            [label setTag:subViewTag];
            label.font = [UIFont systemFontOfSize:14];
            [cell addSubview:label];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(l_r_pading, label.frame.size.height + label.frame.origin.y + 5, tableView.frame.size.width - 2*l_r_pading, 13)];
            [label1 setTag:subViewTag+1];
            label1.numberOfLines = 0;
            label1.font = [UIFont systemFontOfSize:13];
            [cell addSubview:label1];
        }
    }
    
    cell.userInteractionEnabled = NO;
    cell.backgroundColor = [UIColor tableViewBackgroundColor];
    
    if ([indexPath indexAtPosition:1] == 0) {//详细地址 点击查看地图
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//添加剪头
        cell.userInteractionEnabled = YES;
        UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
        NSString *adrStr = [NSString stringWithFormat:@"地址：%@", [self.tableData objectForKey:@"address"]];
        CGSize size = [AppDelegate getStringInLabelSize:adrStr andFont:label.font andLabelWidth:label.frame.size.width];
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, size.height);
        label.text = adrStr;
        
        UILabel *labelPhone = (UILabel*)[cell viewWithTag:subViewTag+1];
        labelPhone.frame = CGRectMake(labelPhone.frame.origin.x, label.frame.origin.y + label.frame.size.height + 3, labelPhone.frame.size.width, labelPhone.frame.size.height);
        labelPhone.text = [NSString stringWithFormat:@"电话：%@", [self.tableData objectForKey:@"phone"]];
    } else if ([indexPath indexAtPosition:1] < allCellCount - 1) {
        cell.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//添加剪头
        if ([self.tableData objectForKey:@"salerlist"]) {
            NSArray *masterArray = (NSArray*)[self.tableData objectForKey:@"salerlist"];
            NSDictionary *cellDataDic = (NSDictionary*)[masterArray objectAtIndex:([indexPath indexAtPosition:1]-1)];
            
            UIImageView *headImgView = (UIImageView*)[cell viewWithTag:100];
            //使用SDWebImage图片缓存
            [headImgView sd_setImageWithURL:[cellDataDic objectForKey:@"img"] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
            
            UILabel *labelName = (UILabel*)[cell viewWithTag:101];
            //        NSString *name_store = [NSString stringWithFormat:@"%@ (%@)", [cellDataDic objectForKey:@"name"], [cellDataDic objectForKey:@"shopname"]];
            //        labelName.text = name_store;
            labelName.text = [cellDataDic objectForKey:@"name"];
            
            UILabel *label = (UILabel*)[cell viewWithTag:104];
            NSString *textStr = [NSString stringWithFormat:@"接单%@次", [cellDataDic objectForKey:@"ordercount"]];
            label.text = textStr;
            
            label = (UILabel*)[cell viewWithTag:106];
            textStr = [NSString stringWithFormat:@"顾客评价(%@)", [cellDataDic objectForKey:@"commentcount"]];
            label.text = textStr;
            
            NSInteger starsCount = [((NSString*)[cellDataDic objectForKey:@"salerstar"]) integerValue];
            for (int i = 0; i < starsCount; i++) {
                UIImageView *starsImg = (UIImageView*)[cell viewWithTag:(160+i)];
                starsImg.hidden = NO;
            }
        }
//    } else if ([indexPath indexAtPosition:1] == allCellCount - 2) {//门店荣誉
//        cell.backgroundColor = RGBA(193, 193, 193, 255);
//        UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
//        label.text = @"门店荣誉";
//        
//        UILabel *label1 = (UILabel*)[cell viewWithTag:subViewTag+1];
//        label1.font = LABEL_DEFAULT_TEXT_FONT;
//        NSString *adrStr = [self.tableData objectForKey:@"honor"];
//        if (!adrStr || (id)adrStr == [NSNull null]) {
//            adrStr = @"-";
//        }
//        CGSize size = [AppDelegate getStringInLabelSize:adrStr andFont:label1.font andLabelWidth:label1.frame.size.width];
//        label1.frame = CGRectMake(label1.frame.origin.x, label1.frame.origin.y, label1.frame.size.width, size.height);
//        label1.text = adrStr;
    } else if ([indexPath indexAtPosition:1] == allCellCount - 1) {//门店介绍
        cell.backgroundColor = RGBA(193, 193, 193, 255);
        UILabel *label = (UILabel*)[cell viewWithTag:subViewTag];
        label.text = @"门店介绍：";
        
        UILabel *label1 = (UILabel*)[cell viewWithTag:subViewTag+1];
        label1.font = LABEL_DEFAULT_TEXT_FONT;
        NSString *adrStr = [self.tableData objectForKey:@"content"];
        if (!adrStr || (id)adrStr == [NSNull null]) {
            adrStr = @"-";
        }
        CGSize size = [AppDelegate getStringInLabelSize:adrStr andFont:label1.font andLabelWidth:label1.frame.size.width];
        label1.frame = CGRectMake(label1.frame.origin.x, label1.frame.origin.y, label1.frame.size.width, size.height);
        label1.text = adrStr;
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
