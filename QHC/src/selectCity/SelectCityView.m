//
//  SelectCityView.m
//  QHC
//
//  Created by qhc2015 on 15/7/22.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "SelectCityView.h"
#import "MyAlerView.h"
#import "LoadingView.h"
#import "JSONKit.h"
#import "AppDelegate.h"

@implementation SelectCityView
@synthesize httpRequest;
@synthesize cityTableView;
@synthesize cityArray;
@synthesize selCitySignArray;

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selCitySignArray = [[NSMutableArray alloc] init];
        
        self.cityTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
        self.cityTableView.dataSource = self;
        self.cityTableView.delegate = self;
        self.cityTableView.backgroundColor = [UIColor clearColor];
        [self addSubview:cityTableView];
        [self getCityListData];
    }
    return  self;
}

-(void)getCityListData {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"City/List.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
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
    if (resultCode == 1) {//成功
        if ([responseInfo objectForKey:@"citylist"]) {
            self.cityArray = [responseInfo objectForKey:@"citylist"];
            [self.cityTableView reloadData];
        } else {
            
        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}


#pragma table dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"GPS定位城市";
    } else if (section == 1) {
        return @"已有门店的城市";
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        if (cityArray) {
            return [cityArray count];
        } else {
            return 1;
        }
    }
    
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * showUserInfoCellIdentifier = @"showCityInfo";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];
    if (cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, tableView.frame.size.width - 30, cell.frame.size.height)];
        [label setTag:100];
        label.textColor = LABEL_TITLE_TEXT_COLOR;
        label.font = LABEL_DEFAULT_TEXT_FONT;
        [cell addSubview:label];
        
        if (indexPath.section == 1) {
            UIImageView *selectedImg = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 45, 15, 15, 10)];
            [selectedImg setTag:101];
            [cell addSubview:selectedImg];
            if ([indexPath indexAtPosition:1] != 0) {
                selectedImg.hidden = YES;
            }
            [self.selCitySignArray addObject:selectedImg];
        }
    }
    
    cell.backgroundColor = [UIColor tableViewBackgroundColor];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    UILabel *label = (UILabel*)[cell viewWithTag:100];
    if (indexPath.section == 0) {
        if ([userDefaults objectForKey:LOCATION_CITY]) {//如果用户没有选择过城市，但定位到了城市，就显示定位的城市
            label.text = [userDefaults stringForKey:LOCATION_CITY];
        } else {
            cell.userInteractionEnabled = NO;
            label.text = @"未能定位到您所在的城市";
        }
        
    } else if (indexPath.section == 1) {
        NSObject *cityDic = [cityArray objectAtIndex:[indexPath indexAtPosition:1]];
        if (cityDic && [cityDic isKindOfClass:[NSDictionary class]]) {
            label.text = [(NSDictionary*)cityDic objectForKey:@"cityname"];
        } else {
            label.text = (NSString*)cityDic;
        }

        
        UIImageView *selectedImg = (UIImageView*)[cell viewWithTag:101];
        [selectedImg setImage:[UIImage imageNamed:@"selected.png"]];
        
        NSString *cityName;
        if ([userDefaults objectForKey:USER_SELECTED_CITY]) {//如果用户已经选择过城市了，那么就显示用户选择的城市
            cityName = [userDefaults stringForKey:USER_SELECTED_CITY];
        } else if ([userDefaults objectForKey:LOCATION_CITY]) {//如果用户没有选择过城市，但定位到了城市，就显示定位的城市
            cityName = [userDefaults stringForKey:LOCATION_CITY];
        } else {//否则就是默认城市
            cityName = [userDefaults stringForKey:DEFAULT_CITY];
        }
        if ([label.text isEqualToString:cityName]) {
            selectedImg.hidden = NO;
        } else {
            selectedImg.hidden = YES;
        }
    }
    
    return cell;
}

#pragma table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{//修改group之间的间距
    if (section == 0) {
        return 30.0;
    }
    return 15.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{//修改group之间的间距
    return 15.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//点击后恢复原有背景状态
    if (indexPath.section == 1) {
        for (int i = 0; i < selCitySignArray.count; i++) {
            UIView *view = [selCitySignArray objectAtIndex:i];
            if ([indexPath indexAtPosition:1] == i) {
                view.hidden = NO;
            } else {
                view.hidden = YES;
            }
        }
        if (self.delegate) {
            NSObject *cityDic = [self.cityArray objectAtIndex:[indexPath indexAtPosition:1]];
            NSString *cityName;
            if (cityDic && [cityDic isKindOfClass:[NSDictionary class]]) {
                cityName = [(NSDictionary*)cityDic objectForKey:@"cityname"];
            } else {
                cityName = (NSString*)cityDic;
            }
            [self.delegate selected:cityName];
        }
    } else if (indexPath.section == 0) {
        if (self.delegate) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [self.delegate selected:[userDefaults stringForKey:LOCATION_CITY]];
        }
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{

    return 44.0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
