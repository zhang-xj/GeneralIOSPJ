//
//  BodyCareView.m
//  QHC
//
//  Created by qhc2015 on 15/6/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCProjectListView.h"
#import "BWMCoverView.h"
#import "AppDelegate.h"
#import "LoadingView.h"
#import "MyAlerView.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "QHCProjectDetailViewController.h"
#import "QHBeatDetailProjectViewController.h"
#import "CheckBox.h"
#import "ConfirmOrderViewController.h"

@implementation QHCProjectListView

@synthesize bundleDataDic;
@synthesize httpRequest;
@synthesize projectArray;
@synthesize selectedProjectListDic;

-(id)initWithFrame:(CGRect)frame withData:(NSDictionary*)dataDic{
    self = [super initWithFrame:frame];
    if (self) {
        self.bundleDataDic = dataDic;
        
        self.selectedProjectListDic = [[NSMutableDictionary alloc] init];
        //获取服务项目数据
        [self getProjectListData:@"1" count:@"200"];
    }
    return self;
}

-(void)createProjectListView:(UIView*)superView projectListData:(NSArray*)proListData {
    if ([superView subviews].count > 0) {
        for (UIView *subView in [superView subviews]) {
            [subView removeFromSuperview];
        }
    }
    
    NSInteger dataCount = [proListData count];
    float item_w = (self.frame.size.width - 45)/2;
    float item_h = item_w + 60.0;
    float pading = 15.0;
    for (NSInteger i = 0; i < dataCount; i++) {
        NSDictionary *dataDic = [proListData objectAtIndex:i];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i%2*item_w + pading*(i%2+1), i/2*(item_h + pading), item_w, item_h)];
        view.layer.cornerRadius = 4.0;
        view.backgroundColor = [UIColor tableViewBackgroundColor];
        view.clipsToBounds = YES;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, item_w, item_w)];
        [imgView sd_setImageWithURL:[NSURL URLWithString:[dataDic objectForKey:@"img"]] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
        [imgView setTag:(100+i)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction:)];
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:tapGesture];
        [view addSubview:imgView];
        
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(5.0, item_w+5, item_w-10.0, 18.0)];
        [labelName setText:[dataDic objectForKey:@"name"]];
        labelName.font = LABEL_LARGE_TEXT_FONT;
        labelName.textColor = LABEL_TITLE_TEXT_COLOR;
        [view addSubview:labelName];
        
        UILabel *labelPrice = [[UILabel alloc] initWithFrame:CGRectMake(5.0, item_w + 25.0, item_w-10.0, 15.0)];
        [labelPrice setText:[NSString stringWithFormat:@"¥%.0f元/%ld次", ((NSString*)[dataDic objectForKey:@"packageprice"]).floatValue, ((NSString*)[dataDic objectForKey:@"packagetimes"]).integerValue]];
        labelPrice.font = LABEL_DEFAULT_TEXT_FONT;
        labelPrice.textColor = [UIColor priceTextColor];
        [view addSubview:labelPrice];

        UILabel *labelSales = [[UILabel alloc] initWithFrame:CGRectMake(5.0, labelPrice.frame.origin.y + labelPrice.frame.size.height + 2, item_w-10.0, 18.0)];
        [labelSales setText: [NSString stringWithFormat:@"%@人已购买", [dataDic objectForKey:@"sales"] ]];
        labelSales.font = LABEL_SMALL_TEXT_FONT;
        labelSales.textColor = LABEL_GRAY_TEXT_COLOR;
        [view addSubview:labelSales];
        
        CheckBox *checkBtn = [[CheckBox alloc] initWithFrame:CGRectMake(view.frame.size.width - 40, labelPrice.frame.origin.y, 40, 40)];
        [checkBtn setImage:[UIImage imageNamed:@"unCheck.png"] forState:UIControlStateNormal];
        checkBtn.checkedIndex = i;
        [checkBtn addTarget:self action:@selector(selectProject:) forControlEvents:UIControlEventTouchUpInside];
        [checkBtn setTag:(2000+i)];
        [view addSubview:checkBtn];
        
        if ([self.bundleDataDic objectForKey:@"isCollect"]) {//如果是收藏项目 则添加删除按钮
            CheckBox *deleteBtn = [[CheckBox alloc] initWithFrame:CGRectMake(view.frame.size.width - 25, 0, 25, 25)];
            [deleteBtn setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
            deleteBtn.checkedIndex = i;
            [deleteBtn addTarget:self action:@selector(deleteCollect:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:deleteBtn];
        }
        
        [superView addSubview:view];
    }

    NSInteger rowCount = dataCount/2 + dataCount%2;
    CGRect rect = CGRectMake(self.frame.origin.x, self.frame.origin.y, superView.frame.size.width, rowCount*(item_h + pading) + pading);

    //一键购买
    if (dataCount > 1) {
        UIButton *buyBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, rect.size.height, rect.size.width - 60, 30)];
        [buyBtn setTitle:@"一键购买" forState:UIControlStateNormal];
        buyBtn.layer.cornerRadius = 4;
        buyBtn.backgroundColor = [UIColor titleBarBackgroundColor];
        [buyBtn addTarget:self action:@selector(buyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [superView addSubview:buyBtn];
    }
    rect.size.height += 40;
    
    self.frame = rect;
    if (self.delegate) {
        [self.delegate viewRealFrame:rect];
    }
}

////取消订单
//-(void)deleteCollect:(CheckBox*)deleteBtn {
//    UIAlertView *alert = [[UIAlertView alloc]
//                          
//                          initWithTitle:@"取消确认"
//                          
//                          message:@"亲，真的要取消这个收藏吗？"
//                          
//                          delegate: self
//                          
//                          cancelButtonTitle:@"不要"
//                          
//                          otherButtonTitles:@"是的",nil];
//    
//    [alert show]; //显示
//}
//
//#pragma mark UIAlertViewDelegate
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//        [self changeOrderStatus:@"0"];
//    }
//}

//取消收藏
-(void)deleteCollect:(CheckBox*)deleteBtn {
    NSDictionary *dataDic = [self.projectArray objectAtIndex:deleteBtn.checkedIndex];
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    
    NSString *urlStr = @"Favorites/Delete.aspx";
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [param setObject:[userDefaults objectForKey:@"userId"] forKey:@"userid"];
    [param setObject:@"1" forKey:@"type"];
    [param setObject:[dataDic objectForKey:@"projectid"] forKey:@"id"];
    
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestDeleteFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

//一键购买
-(void)buyBtnAction:(id)sender{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    if (userId && userId.length > 1) {
        NSArray *keys = [self.selectedProjectListDic allKeys];
        if (keys && keys.count > 0) {
            NSMutableString *mutStr = [[NSMutableString alloc] init];
            for (int i = 0; i < keys.count; i++) {
                NSString *projectId = [keys objectAtIndex:i];
                [mutStr appendString:projectId];
                if (i < keys.count-1) {
                    [mutStr appendString:@"|"];
                }
            }
            [self batchBuy:mutStr];
        } else if (keys && keys.count == 1) {
            [[MyAlerView sharedAler] ViewShow:@"请勾选多个项目。"];
        } else {
            [[MyAlerView sharedAler] ViewShow:@"请勾选要购买的项目。"];
        }
    } else {//去登录界面
        if (self.delegate) {
            [self.delegate showLoginView];
        }
    }
}

//勾选项目动作
-(void)selectProject:(CheckBox*)checkBtn {
    BOOL isCecked = !checkBtn.isChecked;
    NSDictionary *dataDic = [self.projectArray objectAtIndex:checkBtn.checkedIndex];
    checkBtn.isChecked = isCecked;
    if (isCecked) {
        [self.selectedProjectListDic setObject:@"1" forKey:[dataDic objectForKey:@"projectid"]];
        [checkBtn setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
    } else {
        [self.selectedProjectListDic removeObjectForKey:[dataDic objectForKey:@"projectid"]];
        [checkBtn setImage:[UIImage imageNamed:@"unCheck.png"] forState:UIControlStateNormal];
    }
}

-(void)touchAction:(id)sender{
    //这里进入项目详情页
    UIView * view = [((UITapGestureRecognizer*)sender) view];//这个就是被单击的视图
    NSInteger viewTag = view.tag;
    NSInteger index = viewTag - 100;
    
    NSDictionary *proDic = [self.projectArray objectAtIndex:index];
    
    NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] init];
    [paramsDic setObject:[proDic objectForKey:@"name"] forKey:@"title"];
    [paramsDic setObject:[proDic objectForKey:@"projectid"] forKey:@"projectid"];
    if ([self.bundleDataDic objectForKey:@"store"]) {
        [paramsDic setObject:[self.bundleDataDic objectForKey:@"store"] forKey:@"store"];
    }
    
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    if ([@"10100026" isEqualToString:[proDic objectForKey:@"projectid"]]) {
        QHBeatDetailProjectViewController *beatController = [[QHBeatDetailProjectViewController alloc] initWithData:paramsDic];
        [appDelegate.myRootController pushViewController:beatController animated:YES];
    } else {
        QHCProjectDetailViewController *bdvController = [[QHCProjectDetailViewController alloc] initWithData:paramsDic];
        [appDelegate.myRootController pushViewController:bdvController animated:YES];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//批量购买项目
-(void)batchBuy:(NSString*)projectIdListStr {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求

    NSString *urlStr = @"Order/AppendBigProjectOrder.aspx";
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [param setObject:[userDefaults objectForKey:@"userId"] forKey:@"userid"];
    [param setObject:projectIdListStr forKey:@"projectidlist"];
    
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestBatchBuyFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

-(void)getProjectListData:(NSString*)page count:(NSString*)count {
    [[LoadingView sharedLoadingView] show];
    //创建异步请求
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[self.bundleDataDic objectForKey:@"type"] forKey:@"type"];
    [param setObject:page forKey:@"index"];
    [param setObject:count forKey:@"size"];
    NSString *urlStr = @"Project/List.aspx";
    if ([self.bundleDataDic objectForKey:@"isCollect"]) {//如果是收藏项目 则需要修改请求地址和参数
        urlStr = [self.bundleDataDic objectForKey:@"isCollect"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [param setObject:[userDefaults objectForKey:@"userId"] forKey:@"userid"];
    }
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
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
        if ([responseInfo objectForKey:@"projectlist"]) {
            self.projectArray = [responseInfo objectForKey:@"projectlist"];
            [self createProjectListView:self projectListData:projectArray];
        } else {
            if ([bundleDataDic objectForKey:@"isCollect"]) {//如果是收藏页面 则刷新view，不提示
                self.projectArray = [[NSArray alloc] init];
                [self createProjectListView:self projectListData:projectArray];
            }
        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    
    [[LoadingView sharedLoadingView] hidden];
}

//批量支付
-(void) requestBatchBuyFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        NSInteger status = ((NSString*)[responseInfo objectForKey:@"status"]).integerValue;
        if (status == 1) {
            //进入订单确认页面
            NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:responseInfo];
            [paramsDic setObject:@"true" forKey:@"isBatchBuy"];
            ConfirmOrderViewController *cforderViewController = [[ConfirmOrderViewController alloc] initWithOrderInfo:paramsDic];
            AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [appdelegate.myRootController pushViewController:cforderViewController animated:YES];
            
            [self resetCheckBoxStatus];
        } else {
            [[MyAlerView sharedAler] ViewShow:@"生成订单失败，请稍候重试"];
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
            [self getProjectListData:@"1" count:@"200"];
        } else {
            [[MyAlerView sharedAler] ViewShow:@"服务器忙，请稍候重试"];
        }
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    
    
}

//重置选择框状态
-(void)resetCheckBoxStatus{
    [self.selectedProjectListDic removeAllObjects];
    for (NSInteger i = 0; i < self.projectArray.count; i++) {
        CheckBox *checkBox = (CheckBox*)[self viewWithTag:(2000 + i)];
        checkBox.isChecked = NO;
        [checkBox setImage:[UIImage imageNamed:@"unCheck.png"] forState:UIControlStateNormal];
    }
}
@end
