//
//  MyCardPackageView_select.m
//  QHC
//
//  Created by qhc2015 on 15/8/2.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "MyCardPackageView_select.h"

#import "AppDelegate.h"
#import "MyAlerView.h"
#import "JSONKit.h"
#import "LoadingView.h"
#import "UIImageView+WebCache.h"

@implementation MyCardPackageView_select

@synthesize pageTitle;

@synthesize refreshTableView;

@synthesize httpRequest;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createContentView];
        [self getContentTableViewInitData:PAGE_DATA_COUNT];
        
        selectedIndex = -1;
    }
    return self;
}

-(void)backAction:(id)sender {
    [((AppDelegate*)([UIApplication sharedApplication].delegate)).myRootController popViewControllerAnimated:YES];
}

-(void)createContentView {
    
    self.refreshTableView = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height) rowHeight:-2];
    refreshTableView.delegate = self;
    [refreshTableView setPageDataCount:PAGE_DATA_COUNT];
    refreshTableView.backgroundColor = [UIColor clearColor];
    [self addSubview:refreshTableView];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(void)getContentTableViewInitData:(NSInteger)pageDataCount{
    [[LoadingView sharedLoadingView] show];
    NSString *pageDataCountStr = [NSString stringWithFormat:@"%ld", pageDataCount];
    [self getTableData:@"1" count:pageDataCountStr];
}

-(void)getTableData:(NSString*)page count:(NSString*)count {
    //创建异步请求
    NSString *urlStr = @"UserCardBag/List.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:@"userId"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:userId forKey:@"userid"];
    [param setObject:page forKey:@"index"];
    [param setObject:count forKey:@"size"];
    [param setObject:@"20" forKey:@"type"];//1：现金卷 2：优惠券 3：体验卷 -1：全部
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestCarkPackageFinish:)];
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

-(void) requestCarkPackageFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if ([responseInfo objectForKey:@"cardlist"]) {
            NSArray *tableDataList = [responseInfo objectForKey:@"cardlist"];
            [self.refreshTableView appendTableData:tableDataList];
            [self.refreshTableView reload];
        } else {
            self.refreshTableView.noMoreData = YES;
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
    return 120;
}

- (void) refreshData:(UITableView*)tableView oldDataCount:(NSInteger)oldDataCount onePageDataCount:(NSInteger)onePageDataCount{
    NSString *pageIndexStr = [NSString stringWithFormat:@"%ld", (oldDataCount / onePageDataCount + 1)];
    NSString *pageDataCountStr = [NSString stringWithFormat:@"%ld", onePageDataCount];
    [self getTableData:pageIndexStr count:pageDataCountStr];
}
- (void) tableView:(UITableView *)tableView didSelectRowData:(NSObject *)selectRowData andIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *selectCellDataDic = (NSDictionary*)selectRowData;
    selectedIndex = [indexPath indexAtPosition:1];
    [self.refreshTableView reload];
    
    if (self.delegate) {
        [self.delegate selectedResult:selectCellDataDic];
    }
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
        //卡卷图标
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 80, 80)];
        [imgView setTag:100];
        [cell addSubview:imgView];
        //卡卷标题
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.origin.x + imgView.frame.size.width + 10, 10, tableView.frame.size.width - (imgView.frame.origin.x + imgView.frame.size.width + 8 + 20), 15)];
        [labelName setTag:101];
        labelName.font = [UIFont boldSystemFontOfSize:15];
        [cell addSubview:labelName];
        //卡卷有效期
        UILabel *labelInfo1 = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelName.frame.origin.y + labelName.frame.size.height + 3, labelName.frame.size.width, 13)];
        [labelInfo1 setTag:102];
        labelInfo1.font = [UIFont systemFontOfSize:12];
        [cell addSubview:labelInfo1];
        //使用地点
        UILabel *labelInfo2 = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelInfo1.frame.origin.y + labelInfo1.frame.size.height + 3, labelName.frame.size.width, 13)];
        [labelInfo2 setTag:103];
        labelInfo2.font = [UIFont systemFontOfSize:12];
        [cell addSubview:labelInfo2];
        //使用条件
        UILabel *labelInfo3 = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelInfo2.frame.origin.y + labelInfo2.frame.size.height + 3, labelName.frame.size.width, 13)];
        [labelInfo3 setTag:104];
        labelInfo3.font = [UIFont systemFontOfSize:12];
        [cell addSubview:labelInfo3];
        //使用对象
        UILabel *labelInfo4 = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelInfo3.frame.origin.y + labelInfo3.frame.size.height + 3, labelName.frame.size.width, 13)];
        [labelInfo4 setTag:105];
        labelInfo4.font = [UIFont systemFontOfSize:12];
        [cell addSubview:labelInfo4];
        //使用项目
        UILabel *labelInfo5 = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelInfo4.frame.origin.y + labelInfo4.frame.size.height + 3, labelName.frame.size.width, 13)];
        [labelInfo5 setTag:106];
        labelInfo5.font = [UIFont systemFontOfSize:12];
        [cell addSubview:labelInfo5];
        
        UIButton *checkBox = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 60, 40, 40, 40)];
        [checkBox setTag:107];
        checkBox.userInteractionEnabled = NO;
        [cell addSubview:checkBox];
    }
    
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//添加向右剪头
    cell.backgroundColor = [UIColor tableViewBackgroundColor];
    
    if (cellData && [cellData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *cellDataDic = (NSDictionary*)cellData;
        //卡卷图标
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:100];
        [imgView setImage:[UIImage imageNamed:@"carkPackage.png"]];
        //卡卷标题
        UILabel *labelName = (UILabel*)[cell viewWithTag:101];
        labelName.text = [cellDataDic objectForKey:@"cardname"];
        //卡卷有效期
        UILabel *labelInfo1 = (UILabel*)[cell viewWithTag:102];
        labelInfo1.text = [NSString stringWithFormat:@"有效期至：%@", [cellDataDic objectForKey:@"validitydate"]];
        //使用地点
        UILabel *labelInfo2 = (UILabel*)[cell viewWithTag:103];
        labelInfo2.text = [NSString stringWithFormat:@"使用地点：%@", [cellDataDic objectForKey:@"useaddress"]];
        //使用条件
        UILabel *labelInfo3 = (UILabel*)[cell viewWithTag:104];
        labelInfo3.text = [NSString stringWithFormat:@"使用条件：%@", [cellDataDic objectForKey:@"useconditions"]];
        //使用对象
        UILabel *labelInfo4 = (UILabel*)[cell viewWithTag:105];
        labelInfo4.text = @"使用项目：女性";
        //        labelInfo5.text = [NSString stringWithFormat:@"使用项目：%@", [cellDataDic objectForKey:@""]];
        //使用项目
        UILabel *labelInfo5 = (UILabel*)[cell viewWithTag:106];
        labelInfo5.text = [NSString stringWithFormat:@"使用对象：%@", [cellDataDic objectForKey:@"cardprojectlist"]];
        
        UIButton *checkBox = (UIButton*)[cell viewWithTag:107];
        if (index == selectedIndex) {
            [checkBox setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
        } else {
            [checkBox setImage:[UIImage imageNamed:@"unCheck.png"] forState:UIControlStateNormal];
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
