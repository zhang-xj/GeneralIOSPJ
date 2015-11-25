//
//  MasterSearchListView.m
//  QHC
//
//  Created by qhc2015 on 15/7/23.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "MasterSearchListView.h"
#import "AppDelegate.h"
#import "JSONKit.h"
#import "MyAlerView.h"
#import "LoadingView.h"
#import "UIImageView+WebCache.h"
#import "CheckBox.h"
#import "MasterDetailViewController.h"

@implementation MasterSearchListView

@synthesize mRfTableView;
@synthesize httpRequest;

@synthesize sortType;
@synthesize salerStar;
@synthesize searchKey;
@synthesize classSelectView;


-(id)initWithFrame:(CGRect)frame andSearchKey:(NSString*)search_key {
    self = [super initWithFrame:frame];
    if (self) {
        self.mRfTableView = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height) rowHeight:86];
        [self addTableHeadView];
        
        self.sortType = @"2";//排序方式标记  1：门店 2：星级  -1：综合排序
        self.salerStar = @"-1";//养生顾问星级  参数：1 2 3 4 5星 -1：全部
        self.searchKey = search_key;
        
        mRfTableView.delegate = self;
        [mRfTableView setPageDataCount:PAGE_DATA_COUNT];
        mRfTableView.backgroundColor = [UIColor clearColor];
        [self addSubview:mRfTableView];
        [self getContentTableViewInitData:PAGE_DATA_COUNT];
        
        [self createClassSelectView];
    }
    return self;
}

-(void)addTableHeadView {
    UIView *tableHeadView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.mRfTableView.frame.size.width, 40)];
    [tableHeadView setTag:300];
    tableHeadView.backgroundColor = [UIColor tableViewBackgroundColor];
    NSInteger count = 3;
    float item_w = tableHeadView.frame.size.width / 3;
    for (int i = 0; i < count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i*item_w, 0.0, item_w, tableHeadView.frame.size.height)];
        [button setTag:(500+i)];
        [button addTarget:self action:@selector(sortMasterList:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 70*(self.frame.size.width/320), 0, 0)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 25)];
        if (i == 0) {
            [button setTitle:@"星级排序" forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"sortBtnSign_s.png"] forState:UIControlStateNormal];
        } else if (i == 1) {
            [button setTitle:@"门店排序" forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"sortBtnSign.png"] forState:UIControlStateNormal];
        } else if (i == 2) {
            [button setTitle:@"分类筛选" forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"sortBtnSign1.png"] forState:UIControlStateNormal];
        }
        [tableHeadView addSubview:button];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20 + i*item_w, tableHeadView.frame.size.height - 2, item_w - 40, 2)];
        [imgView setTag:(600+i)];
        [imgView setImage:[UIImage imageNamed:@"btnbg_s.png"]];
        if (i != 0) {
            imgView.hidden = YES;
        }
        [tableHeadView addSubview:imgView];
    }
    
    self.mRfTableView.refreshTableView.tableHeaderView = tableHeadView;
}

-(void)sortMasterList:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.tag == 502) {//分类筛选
        [self showClassSelectView];
    } else {
        UIView *view = [self viewWithTag:300];
        [self resetView];
        [btn setImage:[UIImage imageNamed:@"sortBtnSign_s.png"] forState:UIControlStateNormal];
        if (btn.tag == 500) {//星级排序
            [view viewWithTag:600].hidden = NO;
            if(![sortType isEqualToString:@"2"] || ![self.salerStar isEqualToString:@"-1"]){
                self.salerStar = @"-1";
                self.sortType = @"2";
                [self getContentTableViewInitData:PAGE_DATA_COUNT];
            }
        } else if (btn.tag == 501) {//门店排序
            [view viewWithTag:601].hidden = NO;
            if(![sortType isEqualToString:@"1"] || ![self.salerStar isEqualToString:@"-1"]){
                self.salerStar = @"-1";
                self.sortType = @"1";
                [self getContentTableViewInitData:PAGE_DATA_COUNT];
            }
        }
    }
    
}

//把按钮状态都改为正常状态
-(void) resetView {
    UIView *view = [self viewWithTag:300];
    for (int i = 0; i < 3; i++) {
        [view viewWithTag:(600+i)].hidden = YES;
        UIButton *button = (UIButton*)[view viewWithTag:(500+i)];
        if (i == 0) {
            [button setImage:[UIImage imageNamed:@"sortBtnSign.png"] forState:UIControlStateNormal];
        } else if (i == 1) {
            [button setImage:[UIImage imageNamed:@"sortBtnSign.png"] forState:UIControlStateNormal];
        } else if (i == 2) {
            [button setImage:[UIImage imageNamed:@"sortBtnSign1.png"] forState:UIControlStateNormal];
        }
    }
}

//创建分类筛选界面
-(void)createClassSelectView {
    if (nil == self.classSelectView) {
        self.classSelectView= [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideClassSelectView)];
        [classSelectView addGestureRecognizer:tapGestureRecognizer];
        classSelectView.userInteractionEnabled = YES;
        classSelectView.hidden = YES;
        [self addSubview:classSelectView];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 40, self.frame.size.width, self.frame.size.height)];
        view.backgroundColor = [UIColor tableViewBackgroundColor];
        [classSelectView addSubview:view];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11.0, 11.0, view.frame.size.width, 15)];
        label.text = @"选择养生顾问星级";
        label.font = [UIFont systemFontOfSize:14];
        [view addSubview:label];
        
        NSInteger btn_count = 5;
        float btn_offset = 10.0;
        float btn_w = (view.frame.size.width - btn_offset*(btn_count+1))/btn_count;
        float btn_h = 38.0;
        for (int i = 0; i < 5; i++) {
            CheckBox *starBtn = [[CheckBox alloc] initWithFrame:CGRectMake(btn_offset+i*(btn_w + btn_offset), label.frame.origin.y + label.frame.size.height + btn_offset, btn_w, btn_h)];
            [view addSubview:starBtn];
            [starBtn setTitle:[NSString stringWithFormat:@"%d星", i+1] forState:UIControlStateNormal];
            starBtn.backgroundColor = [UIColor buttonBackgroundColor_unable];
            [starBtn setTag:i+1];
            starBtn.layer.cornerRadius = 4;
            starBtn.titleLabel.font = BUTTON_TEXT_FONT;
            [starBtn addTarget:self action:@selector(selectStarGrade:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, label.frame.size.height + label.frame.origin.y + btn_w + btn_offset, view.frame.size.width, 1)];
        line.backgroundColor = [UIColor viewBackgroundColor];
        [view addSubview:line];
        
        UIButton *commitStarBtn = [[UIButton alloc] initWithFrame:CGRectMake(btn_offset, line.frame.origin.y + btn_offset/2, view.frame.size.width - 2*btn_offset, btn_h)];
        [commitStarBtn setTitle:@"确定" forState:UIControlStateNormal];
        commitStarBtn.backgroundColor = [UIColor titleBarBackgroundColor];
        commitStarBtn.layer.cornerRadius = 4;
        commitStarBtn.titleLabel.font = BUTTON_TEXT_FONT;
        [commitStarBtn setTag:666];
        [commitStarBtn addTarget:self action:@selector(selectStarGrade:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:commitStarBtn];
    }
}

//显示分类筛选页面
-(void)showClassSelectView {
    [self bringSubviewToFront:classSelectView];
    self.classSelectView.hidden = NO;
}
//隐藏分类筛选页面
-(void)hideClassSelectView {
    self.salerStar = @"-1";
    self.classSelectView.hidden = YES;
}
//用户筛选星级养生顾问
-(void)selectStarGrade:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.tag == 666) {//分类筛选
        self.classSelectView.hidden = YES;
        [self resetView];
        UIView *view = [self viewWithTag:300];
        if ([self.salerStar isEqualToString:@"-1"]) {
            UIButton *btn = (UIButton*)[view viewWithTag:500];
            [btn setImage:[UIImage imageNamed:@"sortBtnSign_s.png"] forState:UIControlStateNormal];
            [view viewWithTag:600].hidden = NO;
        } else {
            UIButton *btn = (UIButton*)[view viewWithTag:502];
            [btn setImage:[UIImage imageNamed:@"sortBtnSign_s1.png"] forState:UIControlStateNormal];
            [view viewWithTag:602].hidden = NO;
        }
        self.sortType = @"2";
        [self getContentTableViewInitData:PAGE_DATA_COUNT];
    } else {
        for (int i = 0; i < 5; i++) {
            CheckBox *starBtn = (CheckBox*)[self.classSelectView viewWithTag:i+1];
            starBtn.backgroundColor = [UIColor buttonBackgroundColor_unable];
        }
        
        CheckBox *checkBtn = (CheckBox*)sender;
        if (!checkBtn.isChecked) {
            self.salerStar = [NSString stringWithFormat:@"%ld", btn.tag];
            btn.backgroundColor = [UIColor buttonBackgroundColor_2];
            checkBtn.isChecked = YES;
        } else {
            self.salerStar = @"-1";
            checkBtn.isChecked = NO;
        }
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
    [[LoadingView sharedLoadingView] show];
    refreshTable = YES;
    self.mRfTableView.noMoreData = NO;
    NSString *pageDataCountStr = [NSString stringWithFormat:@"%ld", (long)pageDataCount];
    [self getTableData:@"1" count:pageDataCountStr];
}

-(void)getTableData:(NSString*)page count:(NSString*)count {
    
    //创建异步请求
    NSString *urlStr = @"Saler/List.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@"*" forKey:@"shopid"];
    [param setObject:searchKey forKey:@"salername"];
    [param setObject:page forKey:@"index"];
    [param setObject:count forKey:@"size"];
    [param setObject:salerStar forKey:@"salerstar"];
    [param setObject:sortType forKey:@"sorttype"];
    //获取用户目前所在的城市（可能是默认的，可能是定位的，可能是用户选择的）
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *cityName = [userDefaults stringForKey:DEFAULT_CITY];
    if ([userDefaults objectForKey:USER_SELECTED_CITY]) {//如果用户已经选择过城市了，那么就显示用户选择的城市
        cityName = [userDefaults stringForKey:USER_SELECTED_CITY];
    } else if ([userDefaults objectForKey:LOCATION_CITY]) {//如果用户没有选择过城市，但定位到了城市，就显示定位的城市
        cityName = [userDefaults stringForKey:LOCATION_CITY];
    }
    [param setObject:cityName forKey:@"city"];
    
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
    refreshTable = NO;
}

-(void) requestFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if ([responseInfo objectForKey:@"salerlist"]) {
            NSArray *tableDataList = [responseInfo objectForKey:@"salerlist"];
            if (refreshTable) {
                [self.mRfTableView clearTableData];
            }
            [self.mRfTableView appendTableData:tableDataList];
            [self.mRfTableView reload];
        } else {
            if (refreshTable) {//如果是刷新列表
                [[MyAlerView sharedAler] ViewShow:@"没有符合条件的结果"];
            } else {//否则就是加载更多数据
                self.mRfTableView.noMoreData = YES;
            }
        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    
    refreshTable = NO;
    [[LoadingView sharedLoadingView] hidden];
}

#pragma table delegate

- (void) refreshData:(UITableView*)tableView oldDataCount:(NSInteger)oldDataCount onePageDataCount:(NSInteger)onePageDataCount{
    NSString *pageIndexStr = [NSString stringWithFormat:@"%ld", (oldDataCount / onePageDataCount + 1)];
    NSString *pageDataCountStr = [NSString stringWithFormat:@"%ld", (long)onePageDataCount];
    [self getTableData:pageIndexStr count:pageDataCountStr];
}
- (void) tableView:(UITableView *)tableView didSelectRowData:(NSObject *)selectRowData andIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *selectCellDataDic = (NSDictionary*)selectRowData;
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    //    if (isSelected) {
    //        [appDelegate.myRootController pushViewController:appDelegate.mapViewController animated:YES];
    //    } else {
    MasterDetailViewController *mdvController = [[MasterDetailViewController alloc] initWithData:selectCellDataDic];
    [appDelegate.myRootController pushViewController:mdvController animated:YES];
    //    }
    NSLog(@"selected");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellsData:(NSObject*)cellData cellForRowAtIndex:(NSInteger)index{
    static NSString * showUserInfoCellIdentifier = @"showMoreInfo";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];
    if (cell == nil)
    {
        float cellHeight = 86;
        UIFont *font = [UIFont systemFontOfSize:14];
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];
        //头像
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (cellHeight - 60)/2, 60, 60)];
        [imageView setTag:100];
        [cell addSubview:imageView];
        //名字
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 10, imageView.frame.origin.y, 200, 20)];
        [labelName setTag:101];
        labelName.font = font;
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
        [signImg setImage:[UIImage imageNamed:@"serviceNum.png"]];
        [view addSubview:signImg];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(signImg.frame.origin.x + signImg.frame.size.width + 3, 1.0, view.frame.size.width / 2, 20)];
        [label setTag:106];
        label.font = font;
        [view addSubview:label];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//添加向右剪头
    cell.backgroundColor = [UIColor tableViewBackgroundColor];
    
    if (cellData && [cellData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *cellDataDic = (NSDictionary*)cellData;
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
        for (int i = 0; i < 5; i++) {
            UIImageView *starsImg = (UIImageView*)[cell viewWithTag:(160+i)];
            if (i < starsCount) {
                starsImg.hidden = NO;
            } else {
                starsImg.hidden = YES;
            }
        }
    }
    
    return cell;
}

@end