//
//  HomeProductView.m
//  QHC
//
//  Created by qhc2015 on 15/7/25.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "HomeProductView.h"
#import "MyAlerView.h"
#import "LoadingView.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "ConfirmOrderViewController.h"
#import "AppDelegate.h"

@implementation HomeProductView

@synthesize myTableView;
@synthesize myTableView1;
@synthesize aomaDetailDic;
@synthesize haiDetailDic;
@synthesize httpRequest;
@synthesize httpRequest1;

-(id)initWithFrame:(CGRect)frame andProperty:(NSDictionary*)property{
    self = [super initWithFrame:frame];
    if (self) {
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 40.0, frame.size.width, frame.size.height -40) style:UITableViewStyleGrouped];
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        [self addSubview:myTableView];
        
        self.myTableView1 = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 40.0, frame.size.width, frame.size.height -40) style:UITableViewStyleGrouped];
        self.myTableView1.delegate = self;
        self.myTableView1.dataSource = self;
        [self addSubview:myTableView1];
        self.myTableView1.hidden = YES;
        
        [self getAoMaTableData];
        [self getHaiTableData];
        
        [self createTableHeadView];
    }
    return self;
}

-(void)createTableHeadView {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, myTableView.frame.size.width, 40)];
    
    NSArray *segmentArray = [[NSArray alloc] initWithObjects:@"奥玛面膜",  @"海自然洁面乳", nil];
    
    UISegmentedControl *segmentController = [[UISegmentedControl alloc] initWithItems:segmentArray];
    segmentController.frame = CGRectMake((self.frame.size.width - 180)/2, (headView.frame.size.height - 22)/2, 180, 22.0);
    [segmentController addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segmentController.selectedSegmentIndex = 0;
    segmentController.tintColor = RGBA(157, 80, 147, 255);
    [headView addSubview:segmentController];
    
    [self addSubview:headView];
}

-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger index = Seg.selectedSegmentIndex;
    switch (index) {
        case 0:
            self.myTableView.hidden = NO;
            self.myTableView1.hidden = YES;
            break;
        case 1:
            self.myTableView.hidden = YES;
            self.myTableView1.hidden = NO;
            break;
    }
}

//购买家具产品
-(void)buyHomeProduct:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    if (userId && userId.length > 0) {
        NSMutableDictionary *prodictDic;
        if (self.myTableView.hidden) {//购买海自然
            prodictDic = [NSMutableDictionary dictionaryWithDictionary:self.haiDetailDic];
            [prodictDic setObject:@"1" forKey:@"number"];
        } else {//购买奥玛面膜
            prodictDic = [NSMutableDictionary dictionaryWithDictionary:self.aomaDetailDic];
            [prodictDic setObject:@"28" forKey:@"number"];
        }
        
        ConfirmOrderViewController *cforderViewController = [[ConfirmOrderViewController alloc] initWithOrderInfo:prodictDic];
        AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [appdelegate.myRootController pushViewController:cforderViewController animated:YES];
    } else {
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

#pragma LoginSuccess delegate
-(void)loginSuccess:(UIView*)view{
    [self closeLoginView:nil];
    
}

-(void)getAoMaTableData {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSString *urlStr = @"Product/Details.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@"10200005" forKey:@"productid"];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestAoMaFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

-(void)getHaiTableData {
    //创建异步请求
    NSString *urlStr = @"Product/Details.aspx";
    self.httpRequest1 = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@"10200069" forKey:@"productid"];
    
    [httpRequest1 setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest1 setRequestFinishCallBack:@selector(requestHaiFinish:)];
    //设置请求失败的回调方法
    [httpRequest1 setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest1 sendHttpRequestByPost:urlStr params:param];
}

//请求失败代理方法
-(void) requestFail:(NSString*) responseStr
{
    [[LoadingView sharedLoadingView] hidden];
    NSLog(@"login request fail error = %@", responseStr);
    [[MyAlerView sharedAler] ViewShow:@"网络异常，请稍后重试"];
}

#pragma mark ASIHTTPRequestDelegate 异步请求代理方法--->请求代理方法
-(void) requestAoMaFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        self.aomaDetailDic = responseInfo;
        [self.myTableView reloadData];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}

-(void) requestHaiFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        self.haiDetailDic = responseInfo;
        [self.myTableView1 reloadData];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}

#pragma table dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * showUserInfoCellIdentifier = [NSString stringWithFormat:@"showMeInfo%ld%lu", indexPath.section, [indexPath indexAtPosition:1]];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:showUserInfoCellIdentifier];

    if (cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:showUserInfoCellIdentifier];
//        cell.userInteractionEnabled = NO;
        float button_w = 260 * (tableView.frame.size.width/320);
        if (indexPath.section == 0) {
            
            if (tableView == self.myTableView) {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 240)];
                [imgView setTag:100];
                [cell addSubview:imgView];
                
                UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, imgView.frame.size.height, tableView.frame.size.width, 220)];
                [imgView1 setTag:101];
                [cell addSubview:imgView1];
                
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((tableView.frame.size.width - button_w)/2, 419, button_w, 30)];
                [button setTag:103];
                [cell addSubview:button];
            } else {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 240)];
                [imgView setTag:100];
                [cell addSubview:imgView];
                
                UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, imgView.frame.size.height, tableView.frame.size.width, 250.5)];
                [imgView1 setTag:101];
                [cell addSubview:imgView1];
                
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((tableView.frame.size.width - button_w)/2, 453, button_w, 30)];
                [button setTag:103];
                [cell addSubview:button];
            }
            
        } else if(indexPath.section == 1) {
            if (tableView == self.myTableView) {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 538.5)];
                [imgView setTag:104];
                [cell addSubview:imgView];
            } else {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 509)];
                [imgView setTag:104];
                [cell addSubview:imgView];
            }
        } else if(indexPath.section == 2) {
            if (tableView == self.myTableView) {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 582)];
                [imgView setTag:105];
                [cell addSubview:imgView];
            } else {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 547.5)];
                [imgView setTag:105];
                [cell addSubview:imgView];
            }
        }
    }
    
    
    NSDictionary *dataDic = self.aomaDetailDic;
    if (tableView == self.myTableView1) {
        dataDic = self.haiDetailDic;
    }
    if (dataDic) {
        if (indexPath.section == 0) {
            UIImageView *imgView = (UIImageView*)[cell viewWithTag:100];
            [imgView sd_setImageWithURL:[NSURL URLWithString:[dataDic objectForKey:@"img1"]]];
            
            UIImageView *imgView1 = (UIImageView*)[cell viewWithTag:101];
            [imgView1 sd_setImageWithURL:[NSURL URLWithString:[dataDic objectForKey:@"img2"]]];
            
            UIButton *button = (UIButton*)[cell viewWithTag:103];
            button.backgroundColor = RGBA(167, 105, 159, 255);
            button.layer.cornerRadius = 6;
            button.titleLabel.font = BUTTON_TEXT_FONT;
            [button setTitle:@"选中该产品" forState:UIControlStateNormal];
            button.userInteractionEnabled = YES;
            [button addTarget:self action:@selector(buyHomeProduct:) forControlEvents:UIControlEventTouchUpInside];
        } else if(indexPath.section == 1) {
            UIImageView *imgView = (UIImageView*)[cell viewWithTag:104];
            [imgView sd_setImageWithURL:[NSURL URLWithString:[dataDic objectForKey:@"img3"]]];
        } else if(indexPath.section == 2) {
            UIImageView *imgView = (UIImageView*)[cell viewWithTag:105];
            [imgView sd_setImageWithURL:[NSURL URLWithString:[dataDic objectForKey:@"img5"]]];
        }
    }
    return cell;
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
    
    
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
    if (tableView == self.myTableView) {
        if (indexPath.section == 0) {
            return 460;
        } else if(indexPath.section == 1) {
            return 538.5;
        } else if(indexPath.section == 2) {
            return 582;
        }
    } else {
        if (indexPath.section == 0) {
            return 490.5;
        } else if(indexPath.section == 1) {
            return 509;
        } else if(indexPath.section == 2) {
            return 547.5;
        }
    }

    return 40;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
