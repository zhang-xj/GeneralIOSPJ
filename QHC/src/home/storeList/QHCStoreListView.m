//
//  QHCStoreListView.m
//  QHC
//
//  Created by qhc2015 on 15/6/17.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCStoreListView.h"
#import "AppDelegate.h"
#import "LoadingView.h"
#import "MyAlerView.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "CheckBox.h"
#import "StoreDetailViewController.h"
#import "MapViewController.h"

@implementation QHCStoreListView

#ifndef PAGE_DATA_COUNT
#define PAGE_DATA_COUNT 10
#endif

@synthesize mRfTableView;
@synthesize httpRequest;
@synthesize propertyDic;
@synthesize oldSelectedBox;
@synthesize classSelectView;
@synthesize areaArray;
@synthesize areaName;
@synthesize storeName;

-(id)initWithFrame:(CGRect)frame andProperty:(NSDictionary*)property isSelectedView:(BOOL)selected{
    self = [super initWithFrame:frame];
    if (self) {
        self.propertyDic = property;
        self.areaName = @"*";
        self.storeName = @"";
        
        keyboardShow = NO;

        isSelected = selected;
        selectCellIndex = -1;

        if ([propertyDic objectForKey:@"isCollect"]) {//如果是收藏列表
            self.mRfTableView = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height - 40) rowHeight:-2];
        } else {
            [self createSearchView];
            self.mRfTableView = [[MyRefreshTableView alloc] initWithFrame:CGRectMake(0.0, 40.0, frame.size.width, frame.size.height - 40) rowHeight:-2];
        }
        mRfTableView.delegate = self;
        [mRfTableView setPageDataCount:PAGE_DATA_COUNT];        
        mRfTableView.backgroundColor = [UIColor clearColor];
        [self addSubview:mRfTableView];
        
        [self getContentTableViewInitData:PAGE_DATA_COUNT];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        [self addGestureRecognizer:tapGestureRecognizer];
        tapGestureRecognizer.delegate = self;
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


//
-(void)hideKeyboard
{
    [self endEditing:YES];//关闭键盘
}

-(void)createSearchView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 40)];
    view.backgroundColor = [UIColor tableViewBackgroundColor];
    [self addSubview:view];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 7.0, 90, 26)];
    [button addTarget:self action:@selector(getCityAreaList:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 70, 0, 0)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 25)];
    [button setTitle:@"分类筛选" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"sortBtnSign1.png"] forState:UIControlStateNormal];
    [view addSubview:button];
    
    UITextField *searchField = [[UITextField alloc] initWithFrame:CGRectMake(button.frame.size.width + button.frame.origin.x + 10, 7, 150, 26)];
    [view addSubview:searchField];
    searchField.backgroundColor = RGBA(242, 207, 206, 255);
    searchField.layer.borderColor = [UIColor viewBackgroundColor].CGColor;
    searchField.layer.borderWidth = 1;
    searchField.layer.cornerRadius = 4;
    [searchField setReturnKeyType:UIReturnKeySearch];//设置return键类型
    [searchField setTag:7777];
    [searchField setFont:LABEL_DEFAULT_TEXT_FONT];
    searchField.delegate = self;
    
    searchField.placeholder = @"请输入门店名";
}

//先获取城市区域列表
-(void)getCityAreaList:(id)sender {
    if (self.classSelectView && self.areaArray && self.areaArray.count > 0) {
        [self showClassSelectView];
        return;
    }
    //创建异步请求
    NSString *urlStr = @"City/AreaList.aspx";
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    //获取用户目前所在的城市（可能是默认的，可能是定位的，可能是用户选择的）
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *cityName = [userDefaults stringForKey:DEFAULT_CITY];
    if ([userDefaults objectForKey:USER_SELECTED_CITY]) {//如果用户已经选择过城市了，那么就显示用户选择的城市
        cityName = [userDefaults stringForKey:USER_SELECTED_CITY];
    } else if ([userDefaults objectForKey:LOCATION_CITY]) {//如果用户没有选择过城市，但定位到了城市，就显示定位的城市
        cityName = [userDefaults stringForKey:LOCATION_CITY];
    }
    [param setObject:cityName forKey:@"city"];
    
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestGetAreaListFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//显示分类筛选页面
-(void)showClassSelectView {
    [self hideKeyboard];
    [self bringSubviewToFront:classSelectView];
    self.classSelectView.hidden = NO;
}
//隐藏分类筛选页面
-(void)hideClassSelectView {
    self.areaName = @"*";
    self.classSelectView.hidden = YES;
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
        label.text = @"选择门店所在区域";
        label.font = [UIFont systemFontOfSize:14];
        [view addSubview:label];
        
        
        NSInteger oneRowItemCount = 4;
        float btn_offset = 10.0;
        float btn_w = (view.frame.size.width - btn_offset*(oneRowItemCount+1))/oneRowItemCount;
        float btn_h = 32.0;
        float y_pading = 5;
        for (int i = 0; i < areaArray.count; i++) {
            NSInteger y = i / oneRowItemCount * (btn_h + y_pading) + label.frame.origin.y + label.frame.size.height + btn_offset;
            CheckBox *starBtn = [[CheckBox alloc] initWithFrame:CGRectMake(btn_offset+(i%oneRowItemCount)*(btn_w + btn_offset), y, btn_w, btn_h)];
            [view addSubview:starBtn];
            NSDictionary *areaDic = [areaArray objectAtIndex:i];
            [starBtn setTitle:[areaDic objectForKey:@"areaname"] forState:UIControlStateNormal];
            starBtn.backgroundColor = [UIColor buttonBackgroundColor_unable];
            [starBtn setTag:i+1];
            starBtn.layer.cornerRadius = 4;
            starBtn.titleLabel.font = BUTTON_TEXT_FONT;
            [starBtn addTarget:self action:@selector(selectStarGrade:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        float line_y = label.frame.size.height + label.frame.origin.y + btn_offset + (areaArray.count/4 + (areaArray.count % oneRowItemCount == 0? 0 : 1)) * (btn_h + y_pading) + 15;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, line_y, view.frame.size.width, 1)];
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

//用户筛选区域门店
-(void)selectStarGrade:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.tag == 666) {//分类筛选
        self.storeName = @"";
        self.classSelectView.hidden = YES;
        [self getContentTableViewInitData:PAGE_DATA_COUNT];
    } else {
        for (int i = 0; i < self.areaArray.count; i++) {
            UIButton *starBtn = (UIButton*)[self.classSelectView viewWithTag:i+1];
            starBtn.backgroundColor = [UIColor buttonBackgroundColor_unable];
        }
        CheckBox *checkBtn = (CheckBox*)sender;
        if (!checkBtn.isChecked) {
            self.areaName = checkBtn.titleLabel.text;
            checkBtn.backgroundColor = [UIColor buttonBackgroundColor_2];
            checkBtn.isChecked = YES;
        } else {
            self.areaName = @"*";
            checkBtn.isChecked = NO;
        }
        
    }
}

-(void)getContentTableViewInitData:(NSInteger)pageDataCount{
    refreshTabelView = YES;
    self.mRfTableView.noMoreData = NO;
    [[LoadingView sharedLoadingView] show];
    NSString *pageDataCountStr = [NSString stringWithFormat:@"%ld", pageDataCount];
    [self getTableData:@"1" count:pageDataCountStr];
}

-(void)lookMapAction:(id)sender{
    if (self.delegate) {
        //门店名 纬度 经度
        CheckBox *cBox = (CheckBox*)sender;
        NSDictionary *selectCellDataDic = [self.mRfTableView.tableData objectAtIndex:cBox.checkedIndex];
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[selectCellDataDic objectForKey:@"name"], [selectCellDataDic objectForKey:@"address"], [selectCellDataDic objectForKey:@"positiony"], [selectCellDataDic objectForKey:@"positionx"], nil] forKeys:[NSArray arrayWithObjects:@"name", @"addr", @"latitude", @"longitude", nil]];
        MapViewController *mapViewController = [[MapViewController alloc] initWithProperty:dic];
        AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
        [appDelegate.myRootController pushViewController:mapViewController animated:YES];
    }
}

-(void)getTableData:(NSString*)page count:(NSString*)count {
    //创建异步请求
    NSString *urlStr = @"Shop/List.aspx";
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if ([propertyDic objectForKey:@"isCollect"]) {//如果是收藏页面 则修改请求地址和参数
        urlStr = [propertyDic objectForKey:@"isCollect"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [param setObject:[userDefaults objectForKey:@"userId"] forKey:@"userid"];
        [param setObject:[propertyDic objectForKey:@"type"] forKey:@"type"];
    } else {
        [param setObject:self.storeName forKey:@"name"];
        [param setObject:@"1" forKey:@"positiony"];
        [param setObject:@"2" forKey:@"positionx"];
        //获取用户目前所在的城市（可能是默认的，可能是定位的，可能是用户选择的）
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *cityName = [userDefaults stringForKey:DEFAULT_CITY];
        if ([userDefaults objectForKey:USER_SELECTED_CITY]) {//如果用户已经选择过城市了，那么就显示用户选择的城市
            cityName = [userDefaults stringForKey:USER_SELECTED_CITY];
        } else if ([userDefaults objectForKey:LOCATION_CITY]) {//如果用户没有选择过城市，但定位到了城市，就显示定位的城市
            cityName = [userDefaults stringForKey:LOCATION_CITY];
        }
        [param setObject:cityName forKey:@"city"];
        [param setObject:self.areaName forKey:@"area"];
    }
    [param setObject:page forKey:@"index"];
    [param setObject:count forKey:@"size"];
    
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//取消收藏
-(void)deleteCollect:(CheckBox*)deleteBtn {
    NSDictionary *selectCellDataDic = [self.mRfTableView.tableData objectAtIndex:deleteBtn.checkedIndex];
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    
    NSString *urlStr = @"Favorites/Delete.aspx";
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [param setObject:[userDefaults objectForKey:@"userId"] forKey:@"userid"];
    [param setObject:@"3" forKey:@"type"];
    [param setObject:[selectCellDataDic objectForKey:@"shopid"] forKey:@"id"];
    
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestDeleteFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//请求失败代理方法
-(void) requestFail:(NSString*) responseStr
{
    [[LoadingView sharedLoadingView] hidden];
    NSLog(@"login request fail error = %@", responseStr);
    [[MyAlerView sharedAler] ViewShow:@"网络异常，请稍后重试"];
    refreshTabelView = NO;
}

#pragma mark ASIHTTPRequestDelegate 异步请求代理方法--->请求代理方法
-(void) requestFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if ([responseInfo objectForKey:@"shoplist"]) {
            NSArray *tableDataList = [responseInfo objectForKey:@"shoplist"];
            if (refreshTabelView) {
                [self.mRfTableView clearTableData];
            }
            [self.mRfTableView appendTableData:tableDataList];
        } else {
            if ([propertyDic objectForKey:@"isCollect"]) {//如果是收藏页面 则刷新tableview，不提示
                if (refreshTabelView) {
                    [self.mRfTableView clearTableData];
                }
                self.mRfTableView.noMoreData = YES;
            } else {
                if (refreshTabelView) {//如果是刷新列表
                    [[MyAlerView sharedAler] ViewShow:@"没有符合条件的结果"];
                } else {//否则就是加载更多数据
                    self.mRfTableView.noMoreData = YES;
                }
            }
        }
        [self.mRfTableView reload];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    refreshTabelView = NO;
    [[LoadingView sharedLoadingView] hidden];
}
//获取城市区域
-(void) requestGetAreaListFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        if ([responseInfo objectForKey:@"arealist"]) {
            self.areaArray = [responseInfo objectForKey:@"arealist"];
            [self createClassSelectView];
            [self showClassSelectView];
        } else {

        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    
    [[LoadingView sharedLoadingView] hidden];
}

//取消收藏结果
-(void) requestDeleteFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    [[LoadingView sharedLoadingView] hidden];
    if (resultCode == 1) {//成功
        NSInteger status = ((NSString*)[responseInfo objectForKey:@"status"]).integerValue;
        if (status == 1) {
            [self getContentTableViewInitData:PAGE_DATA_COUNT];
        } else {
            [[MyAlerView sharedAler] ViewShow:@"服务器忙，请稍候重试"];
        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    
    
}


#pragma table delegate

-(float) getTableCellHeight:(NSObject*)cellData {
    NSDictionary *cellDataDic = (NSDictionary*)cellData;
    NSString *textStr = (NSString*)[cellDataDic objectForKey:@"address"];
    CGSize size = [AppDelegate getStringInLabelSize:textStr andFont:[UIFont systemFontOfSize:12] andLabelWidth:self.frame.size.width - 65];
    return size.height + 65;
}

- (void) refreshData:(UITableView*)tableView oldDataCount:(NSInteger)oldDataCount onePageDataCount:(NSInteger)onePageDataCount{
    NSString *pageIndexStr = [NSString stringWithFormat:@"%lu", (oldDataCount / onePageDataCount + 1)];
    NSString *pageDataCountStr = [NSString stringWithFormat:@"%lu", onePageDataCount];
    [self getTableData:pageIndexStr count:pageDataCountStr];
}
- (void) tableView:(UITableView *)tableView didSelectRowData:(NSObject *)selectRowData andIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *selectCellDataDic = (NSDictionary*)selectRowData;
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    if (isSelected) {
        selectCellIndex = [indexPath indexAtPosition:1];
        [self.mRfTableView reload];
        [self.delegate selectedStore:selectCellDataDic];
    } else {
        StoreDetailViewController *sdvController = [[StoreDetailViewController alloc] initWithTitle:[selectCellDataDic objectForKey:@"name"] andStoreId:[selectCellDataDic objectForKey:@"shopid"]];
        [appDelegate.myRootController pushViewController:sdvController animated:YES];
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
        //
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 15, 15.5)];
        [imageView setTag:100];
        [cell addSubview:imageView];
        if (isSelected) {
            CheckBox *checkBox = [[CheckBox alloc] initWithFrame:CGRectMake(0, -4, 40, 40)];
            [checkBox setTag:104];
            checkBox.userInteractionEnabled = NO;
            [cell addSubview:checkBox];
            
            
            CheckBox *lookMap = [[CheckBox alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 110, 5, 70, 25)];
            [lookMap setTag:105];
            lookMap.layer.cornerRadius = 4;
            lookMap.layer.borderColor = RGBA(200, 200, 200, 255).CGColor;
            lookMap.layer.borderWidth = 1;
            lookMap.backgroundColor = [UIColor viewBackgroundColor];
            lookMap.titleLabel.font = BUTTON_TEXT_FONT;
            [lookMap setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [lookMap setTitle:@"查看地图" forState:UIControlStateNormal];
            [cell addSubview:lookMap];
        } else if ([self.propertyDic objectForKey:@"isCollect"]) {//如果是收藏项目 则添加删除按钮
            CheckBox *deleteBtn = [[CheckBox alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 50, 5, 25, 25)];
            [deleteBtn setTag:106];
            [cell addSubview:deleteBtn];
        }
        //门店名
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.size.width + imageView.frame.origin.x + 10, 8, tableView.frame.size.width - 100, 15)];
        [labelName setTag:101];
        labelName.font = [UIFont boldSystemFontOfSize:15];
        [cell addSubview:labelName];
        //门店地址
        UILabel *labelAddr = [[UILabel alloc] initWithFrame:CGRectMake(labelName.frame.origin.x, labelName.frame.origin.y + labelName.frame.size.height + 18, tableView.frame.size.width - labelName.frame.origin.x - 30, 13)];
        [labelAddr setTag:103];
        labelAddr.numberOfLines = 0;
        labelAddr.font = [UIFont systemFontOfSize:12];
        [cell addSubview:labelAddr];
        //门店电话
        UILabel *labelPhoneNum = [[UILabel alloc] initWithFrame:CGRectMake(labelAddr.frame.origin.x, labelAddr.frame.origin.y + labelAddr.frame.size.height + 4, tableView.frame.size.width - labelAddr.frame.origin.x - 30, 13)];
        [labelPhoneNum setTag:102];
        labelPhoneNum.font = [UIFont systemFontOfSize:12];
        [cell addSubview:labelPhoneNum];
        
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//添加向右剪头
    cell.backgroundColor = [UIColor tableViewBackgroundColor];
    
    if (cellData && [cellData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *cellDataDic = (NSDictionary*)cellData;
        
        UIImageView *headImgView = (UIImageView*)[cell viewWithTag:100];
        [headImgView setImage:[UIImage imageNamed:@"storeSign1.png"]];
        
        UILabel *labelName = (UILabel*)[cell viewWithTag:101];

        labelName.text = [NSString stringWithFormat:@"%@", [cellDataDic objectForKey:@"name"]];
        UILabel *labelAddr = (UILabel*)[cell viewWithTag:103];
        NSString *textStr = (NSString*)[cellDataDic objectForKey:@"address"];
        CGSize size = [AppDelegate getStringInLabelSize:textStr andFont:labelAddr.font andLabelWidth:labelAddr.frame.size.width];
        labelAddr.frame = CGRectMake(labelAddr.frame.origin.x, labelAddr.frame.origin.y, labelAddr.frame.size.width, size.height);
        labelAddr.text = textStr;
        
        //门店电话
        UILabel *labelPhoneNum = (UILabel*)[cell viewWithTag:102];
        labelPhoneNum.frame = CGRectMake(labelPhoneNum.frame.origin.x, labelAddr.frame.origin.y + labelAddr.frame.size.height + 4, labelPhoneNum.frame.size.width, labelPhoneNum.frame.size.height);
        labelPhoneNum.text = [NSString stringWithFormat:@"电话：%@", [cellDataDic objectForKey:@"phone"]];
    }
    if (isSelected) {
        CheckBox *checkBox = (CheckBox*)[cell viewWithTag:104];
        [checkBox setCheckedIndex:index];
        if (checkBox.checkedIndex == selectCellIndex) {
            [checkBox setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
        } else {
            [checkBox setImage:[UIImage imageNamed:@"unCheck.png"] forState:UIControlStateNormal];
        }
        
        CheckBox *lookMap = (CheckBox*)[cell viewWithTag:105];
        [lookMap addTarget:self action:@selector(lookMapAction:) forControlEvents:UIControlEventTouchUpInside];
        [lookMap setCheckedIndex:index];
    } else if ([self.propertyDic objectForKey:@"isCollect"]) {//如果是收藏项目 则添加删除按钮
        CheckBox *deleteBtn = (CheckBox*)[cell viewWithTag:106];
        [deleteBtn setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        deleteBtn.checkedIndex = index;
        [deleteBtn addTarget:self action:@selector(deleteCollect:) forControlEvents:UIControlEventTouchUpInside];
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

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // return NO to disallow editing.
    keyboardShow = YES;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    keyboardShow = NO;
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *text = textField.text;
    if (text) {
        text =[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//去前后空格
    }
    if (text.length > 0) {
        [textField resignFirstResponder];//隐藏软键盘
        self.storeName = textField.text;
    } else {
        self.storeName = @"";
    }
    [self getContentTableViewInitData:PAGE_DATA_COUNT];
    return YES;
}

@end
